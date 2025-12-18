#include "musicdownload.h"

//数据库存储歌曲元数据和其音频文件对应的存储路径，底层downloadtask下载的是歌曲音频数据，存储在本地文件夹中

MusicDownload::MusicDownload(QObject* parent): QObject(parent) {
    initDatabase();
    m_data = loadAllDownloads();
    connect(this, &MusicDownload::dataChanged, this, &MusicDownload::onDataChanged);
}

MusicDownload::~MusicDownload() {
    for (const auto taskInfo : m_downloadInfos.values()) {
        if (taskInfo) {
            taskInfo->deleteLater();
        }
    }
}

int MusicDownload::getCount()const {
    return m_count;
}
void MusicDownload::setCount(int newCount) {
    if (m_count != newCount) {
        m_count = newCount;
    } else {
        return;
    }
}
QMap<QString, DownloadTaskThread*> MusicDownload::getDownloadInfos()const {
    return m_downloadInfos;
}
void MusicDownload::setDownloadInfos(const QMap<QString, DownloadTaskThread*>& newDownloadInfos) {
    if (m_downloadInfos != newDownloadInfos) {
        m_downloadInfos = newDownloadInfos;
        emit downloadInfosChanged();
    } else {
        return;
    }
}
QString MusicDownload::getDownloadSavePath()const {
    return m_downloadSavePath;
}
void MusicDownload::setDownloadSavePath(const QString &newDownloadSavePath) {
    if (m_downloadSavePath != newDownloadSavePath) {
        m_downloadSavePath = newDownloadSavePath;
        emit downloadSavePathChanged();
    } else {
        return;
    }
}
void MusicDownload::startDownload(const QString& taskId, const QVariantMap& obj) { //传入任务id和歌曲元数据
    if (m_downloadInfos.find(taskId) == m_downloadInfos.end()) {
        qDebug() << "无此任务";
        return;
    }
    m_downloadInfos[taskId]->start();

    // 先断开之前的连接，防止重复连接
    disconnect(m_downloadInfos[taskId], &DownloadTaskThread::downloadRelay, this, nullptr);
    connect(m_downloadInfos[taskId], &DownloadTaskThread::downloadRelay, this, [this, taskId, obj](const QString & fileName, const QString & savePath) {
        if (this->localExist(obj["id"].toString())) {//该歌曲是否已经下载过
            return;
        }
        //将元数据和下载好的音频文件路径写入数据库
        addDownload(obj, savePath);
        this->moveTask(taskId);
        emit dataChanged();
    });//写入数据信号

}

void MusicDownload::pauseDownload(const QString &taskId) {
    if (m_downloadInfos.find(taskId) == m_downloadInfos.end()) {
        return;
    }
    m_downloadInfos[taskId]->pause();
}

void MusicDownload::cancelDownload(const QString &taskId) {
    moveTask(taskId);
}

void MusicDownload::addTask(const QString &url, const QString &fileName, const QString &taskId) {
    std::lock_guard<std::mutex> locker(m_mutex);
    if (m_downloadInfos.find(taskId) != m_downloadInfos.end()) {
        return;
    }
    m_downloadInfos.insert(taskId, new DownloadTaskThread(url, m_downloadSavePath, fileName));
    setCount(m_downloadInfos.count());
    qDebug() << "已添加任务" << "当前任务数：" << m_count;
}

void MusicDownload::moveTask(const QString &taskId) {
    std::lock_guard<std::mutex> locker(m_mutex);
    if (m_downloadInfos.find(taskId) == m_downloadInfos.end()) {
        return;
    }
    DownloadTaskThread* task = m_downloadInfos.take(taskId);
    task->deleteLater();
    setCount(m_downloadInfos.count());
}

bool MusicDownload::initDatabase() {
    QFileInfo fileInfo(m_savePath);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    m_database = QSqlDatabase::addDatabase("QSQLITE", "downloads_connection");
    m_database.setDatabaseName(m_savePath);
    if (!m_database.open()) {
        qDebug() << "数据库打开失败";
        return false;
    } else {
        qDebug() << "数据库打开成功";
    }
    return createTable();
}
bool MusicDownload::createTable() {
    QSqlQuery query(m_database);
    QString createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS downloads (
            id TEXT PRIMARY KEY,
            savePath Text,
            name TEXT NOT NULL,
            artists TEXT,
            album TEXT,
            coverImg TEXT,
            url TEXT,
            allTime TEXT,
            create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
            update_time DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    )";
    if (!query.exec(createTableSQL)) {
        qDebug() << "建表失败";
        return false;
    }
    query.exec("CREATE INDEX IF NOT EXISTS idx_id ON downloads (id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_savePath ON downloads (savePath)");
    return true;

}
bool MusicDownload::localExist(const QString &id) {
    QSqlQuery query(m_database);
    query.prepare("SELECT COUNT(*) FROM downloads WHERE id = :id");
    query.bindValue(":id", id);
    if (!query.exec() || !query.next()) {
        return false;
    }
    return query.value(0).toInt() > 0;
}
bool MusicDownload::addDownload(const QVariantMap &obj, const QString &savePath) {//写入数据库
    QSqlQuery query(m_database);
    query.prepare(R"(
        INSERT INTO downloads (id,savePath, name, artists, album, coverImg, url, allTime)
        VALUES (:id,:savePath, :name, :artists, :album, :coverImg, :url, :allTime)
    )");
    query.bindValue(":id", obj["id"].toString());
    query.bindValue(":savePath", savePath); //下载好的音乐文件存储路径
    query.bindValue(":name", obj["name"].toString());
    query.bindValue(":artists", obj["artists"].toString());
    query.bindValue(":album", obj["album"].toString());
    query.bindValue(":coverImg", obj["coverImg"].toString());
    query.bindValue(":url", obj["url"].toString());
    query.bindValue(":allTime", obj["allTime"].toString());
    if (!query.exec()) {
        qDebug() << "添加下载失败";
        return false;
    }
    qDebug() << "添加下载成功";
    return true;
}

QVariantList MusicDownload::loadAllDownloads() {
    QVariantList downloadsList;
    QSqlQuery query(m_database);
    QString selectSQL = "SELECT id, savePath,name, artists, album, coverImg, url, allTime FROM downloads ORDER BY create_time DESC";
    if (!query.exec(selectSQL)) {
        qDebug() << "获取下载数据失败";
        return downloadsList;
    }
    while (query.next()) {
        QVariantMap download;
        download["id"] = query.value("id").toString().toInt();
        download["savePath"] = query.value("savePath").toString();
        download["name"] = query.value("name").toString();
        download["artists"] = query.value("artists").toString();
        download["album"] = query.value("album").toString();
        download["coverImg"] = query.value("coverImg").toString();
        download["url"] = query.value("url").toString();
        download["allTime"] = query.value("allTime").toString();
        downloadsList.append(download);
    }
    return downloadsList;
}
QVariantList MusicDownload::data()const {
    return m_data;
}
void MusicDownload::setData(const QVariantList &newData) {
    if (m_data != newData) {
        m_data = newData;
    } else {
        return;
    }
}
void MusicDownload::onDataChanged() {
    setData(loadAllDownloads());
}
bool MusicDownload::isDownloading(const QString &taskId) {
    return m_downloadInfos.contains(taskId);
}
