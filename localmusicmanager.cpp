#include "localmusicmanager.h"
#include <QtConcurrent/QtConcurrent>
#include <QStandardPaths>

/* 为什么 scanTask 需要建立新的连接？

Qt 机制限制（核心）： Qt 的 SQL 模块维护了一个全局的连接池。名为 "main_connection" 的连接是在主线程初始化的，其底层资源属于主线程。Qt 禁止在子线程中复用主线程创建的连接，否则会导致竞争条件和程序崩溃。

静态函数限制： scanTask 是 static 函数，无法访问类的实例。即使主线程有现成的连接，子线程也无法直接获取。

主线程：注册 "main_connection" 后，在需要读取时通过 QSqlDatabase::database("main_connection") 获取连接句柄。

子线程：必须使用 addDatabase 创建属于自己的临时独立连接（如 "worker_connection"），用完即销毁 (removeDatabase)，从而实现完全的线程隔离和并发安全。 */
LocalMusicManager::LocalMusicManager(QObject *parent)
    : QObject{parent} {
    //标准应用数据目录
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir dir(docPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    m_databasePath = dir.filePath("local_music.db");
    initializeDatabase();
    refreshData();//加载已经有的数据
    //监听异步任务结束
    connect(&m_watcher, &QFutureWatcher<void>::finished, this, [this]() {
        isLoading = false;
        emit isLoadingChanged();
        refreshData();//重新从数据库加载数据
        emit scanFinished(m_data.count());
        qDebug() << "后台扫描任务完成";
    });
}
LocalMusicManager::~LocalMusicManager() {
    if (m_watcher.isRunning()) {
        m_watcher.waitForFinished();
    }
    //主线程连接关闭
    QSqlDatabase db = QSqlDatabase::database("main_connection");
    if (db.isOpen()) {
        db.close();
    }
}
bool LocalMusicManager::initializeDatabase() {
    //主线程连接，用于读取
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "main_connection");
    db.setDatabaseName(m_databasePath);
    if (!db.open()) {
        qCritical() << "无法打开数据库" << db.lastError().text();
        return false;
    }
    return createTable();
}

bool LocalMusicManager::createTable() {
    QSqlDatabase db = QSqlDatabase::database("main_connection");
    QSqlQuery query(db);
    QString createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS local_music (
            path TEXT PRIMARY KEY,
            name TEXT,
            artist TEXT,
            album TEXT,
            size TEXT,
            duration TEXT,
            create_time DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    )";
    if (!query.exec(createTableSQL)) return false;

    query.exec("CREATE INDEX IF NOT EXISTS idx_name ON local_music (name)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_artist ON local_music (artist)");
    return true;

}

void LocalMusicManager::scanDirectory(const QString &path) {
    if (isLoading)return;
    isLoading = true;
    emit isLoadingChanged();

    QString cleanPath = path;
    //移除路径开头的 file:// 前缀（文件 URL 协议头），得到纯本地文件路径
    if (cleanPath.startsWith("file://")) {
        cleanPath.replace("file://", "");
    }
    //在后台线程启动扫描文件夹任务，传递文件和数据库路径，跨线程不能传递 QSqlDatabase 对象
    QFuture<void> future = QtConcurrent::run(LocalMusicManager::scanTask, cleanPath, m_databasePath);
    m_watcher.setFuture(future);

}

//-----静态函数，运行在子线程中----

void LocalMusicManager::scanTask(const QString &folderPath, const QString &dbPath) {
    //在当前进程中创建独立的数据库连接
    //连接名唯一防止冲突
    QString connectionName = QString("worker_connection_%1").arg((quint64)QThread::currentThreadId()); //线程专属的唯一数据库连接名，worker_connection_进程id


    {
        //人为创建局部作用域，强制 QSqlDatabase 和 QSqlQuery 对象在执行 removeDatabase 之前被销毁
        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", connectionName);
        db.setDatabaseName(dbPath);
        if (!db.open()) {
            qCritical() << "子线程无法打开数据库";
            return;
        }
        QSqlQuery query(db);
        query.prepare(R"(
                INSERT OR REPLACE INTO local_music (path, name, artist, album, size, duration)
                VALUES (:path, :name, :artist, :album, :size, :duration)
            )");

        //开启事务，提升性能（减少磁盘IO次数）
        db.transaction();

        //初始化文件迭代器
        // folderPath: 目标文件夹路径
        // QStringList(...): 只找 mp3, flac, wav, m4a 后缀的文件
        // QDir::Files: 只找文件，不找文件夹
        // QDir::NoDotAndDotDot: 忽略 "." (当前目录) 和 ".." (上级目录)防止死循环和混乱，这两个东西并不是真正的文件和文件夹
        // QDirIterator::Subdirectories: 递归查找所有子文件夹
        QDirIterator it(folderPath, QStringList() << "*.mp3" << "*.flac" << "*.wav" << "*.m4a", QDir::Files | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);

        int batchCount = 0;
        while (it.hasNext()) {
            it.next();
            QFileInfo fileInfo = it.fileInfo();
            //解析元数据
            QVariantMap meta = extractMetaData(fileInfo);
            query.bindValue(":path", fileInfo.absoluteFilePath());
            query.bindValue(":name", meta["name"]);
            query.bindValue(":artist", meta["artist"]);
            query.bindValue(":album", meta["album"]);
            query.bindValue(":size", meta["size"]);
            query.bindValue(":duration", meta["duration"]);

            query.exec();//数据进入内存缓存，并未写入磁盘

            //每300条提交一次事务，防止内存占用过高
            batchCount++;
            if (batchCount >= 300) {
                db.commit();//将300条数据一次性写入磁盘
                db.transaction();//开启下一轮新事务
                batchCount = 0;
            }
        }

        db.commit();
        db.close();
    }
    QSqlDatabase::removeDatabase(connectionName);
}

//----辅助函数 元数据解析-----
QVariantMap LocalMusicManager::extractMetaData(const QFileInfo &fileInfo) {
    QVariantMap map;
    QString fileName = fileInfo.baseName();
    //默认值
    map["name"] = fileName;
    map["artists"] = "未知歌手";
    map["album"] = "本地音乐";
    map["duration"] = "00:00";
    //格式化大小
    double sizeMb = fileInfo.size() / 1024.0 / 1024.0;
    map["size"] = QString::number(sizeMb, 'f', 1) + " MB";

    //解析文件名
    if (fileName.contains("-")) {
        QStringList parts = fileName.split("-");
        if (parts.length() >= 2) {
            map["artists"] = parts[0].trimmed();
            map["name"] = parts[1].trimmed();
        }
    }
    return map;
}

void LocalMusicManager::refreshData() {
    QSqlDatabase db = QSqlDatabase::database("main_connection");
    if (!db.isOpen() && !initializeDatabase()) {
        return;
    }
    QSqlQuery query(db);
    if (query.exec("SELECT * FROM local_music ORDER BY name ASC")) {
        QVariantList newList;
        while (query.next()) {
            QVariantMap map;
            map["path"] = query.value("path");
            map["name"] = query.value("name");
            map["artist"] = query.value("artist");
            map["album"] = query.value("album");
            map["size"] = query.value("size");
            map["duration"] = query.value("duration");
            newList.append(map);
        }

        if (m_data != newList) {
            m_data = newList;
            emit dataChanged();
        }
    }
}

QVariantList LocalMusicManager::getData()const {
    return m_data;
}

bool LocalMusicManager::getIsLoading()const {
    return isLoading;
}

int LocalMusicManager::getMusicCount()const {
    return m_data.count();
}
