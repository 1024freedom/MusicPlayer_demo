#include "playhistorymanager.h"

PlayHistoryManager::PlayHistoryManager(QObject* parent): QObject(parent) {
    if (!initializeDatabase()) {
        qDebug() << "数据库未成功加载";
    } else {
        refreshData(loadAllHistorys());
    }

    if (shouldCleanup()) {
        autoCleanup();
    }

    m_cleanupTimer = new QTimer(this);
    connect(m_cleanupTimer, &QTimer::timeout, this, &PlayHistoryManager::onAutoCleanupTimeout);
    m_cleanupTimer->start(24 * 60 * 60 * 7);

    //连接其他信号
    connect(this, &PlayHistoryManager::m_databaseChanged, this, &PlayHistoryManager::onM_databaseChanged);

}

PlayHistoryManager::~PlayHistoryManager() {
    if (m_database.isOpen()) {
        m_database.close();
    }
}

bool PlayHistoryManager::initializeDatabase() {
    //确保目标目录存在，不存在则创建
    QFileInfo fileInfo(m_databasePath);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    //打开数据库(sqlite)
    m_database = QSqlDatabase::addDatabase("QSQLITE", "historys_connection"); //连接名为historys_connection的sqlite数据库
    m_database.setDatabaseName(m_databasePath);

    if (!m_database.open()) {
        qDebug() << "数据库打开失败";
        return false;
    } else {
        qDebug() << "数据库打开成功";
    }

    //建表
    return createTable();
}

bool PlayHistoryManager::createTable() {

    QSqlQuery query(m_database);
    //基本数据表
    QString createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS historys (
            id TEXT PRIMARY KEY,
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
        qDebug() << "基本数据表建表失败";
        return false;
    }

    //创建索引提高查询性能
    query.exec("CREATE INDEX IF NOT EXISTS idx_id ON historys (id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_create_time ON historys (url)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_create_time ON historys (coverImg)");

    //应用元数据表，存储清理时间等信息
    QString createMetaTableSQL = R"(
        CREATE TABLE IF NOT EXISTS app_metadata (
            key TEXT PRIMARY KEY,
            value TEXT
        )
    )";
    if (!query.exec(createMetaTableSQL)) {
        qDebug() << "元数据表建表失败";
        return false;
    }

    return true;
}

QDateTime PlayHistoryManager::getLastCleanupTime() {
    QSqlQuery query(m_database);
    query.prepare("SELECT value FROM app_metadata WHERE key = 'last_cleanup_time'");
    if (query.exec() && query.next()) {
        return QDateTime::fromString(query.value(0).toString(), Qt::ISODate);
    }
    //如果不存在记录则返回远古日期，实现强制清理
    return QDateTime::fromString("2005-01-01T00:00:00", Qt::ISODate);
}

void PlayHistoryManager::setLastCleanupTime(const QDateTime &time) {
    QSqlQuery query(m_database);
    query.prepare(R"(
        INSERT OR REPLACE INTO app_metadata (key, value)
        VALUES ('last_cleanup_time', ?)
    )");
    query.addBindValue(time.toString(Qt::ISODate));
    if (!query.exec()) {
        qWarning() << "Set last cleanup time failed:" << query.lastError();
    }
}

bool PlayHistoryManager::shouldCleanup() {
    QDateTime lastCleanup = getLastCleanupTime();
    QDateTime now = QDateTime::currentDateTime();
    return lastCleanup.daysTo(now) >= 7;
}

void PlayHistoryManager::autoCleanup() {
    setLastCleanupTime(QDateTime::currentDateTime());
    QSqlQuery query(m_database);
    query.prepare("DELETE FROM historys WHERE date(update_time) < date('now', '-? days')");//删除七天前的记录
    query.addBindValue(m_cleanupDays);
    emit m_databaseChanged();
}

QVariantList PlayHistoryManager::loadAllHistorys() {
    QVariantList historysList;
    QSqlQuery query(m_database);
    QString selectSQL = "SELECT id, name, artists, album, coverImg, url, allTime FROM historys ORDER BY update_time DESC";

    if (!query.exec(selectSQL)) {
        qDebug() << "获取收藏数据失败";
        return historysList;
    }

    while (query.next()) {
        QVariantMap history;
        history["id"] = query.value("id").toString().toInt();
        history["name"] = query.value("name").toString();
        history["artists"] = query.value("artists").toString();
        history["album"] = query.value("album").toString();
        history["coverImg"] = query.value("coverImg").toString();
        history["url"] = query.value("url").toString();
        history["allTime"] = query.value("allTime").toString();
        historysList.append(history);
    }

    qDebug() << "从数据库加载了" << historysList.count() << "条数据";
    return historysList;
}

void PlayHistoryManager::refreshData(const QVariantList &newData) {
    if (m_data != newData) {
        m_data = newData;
    } else {
        return;
    }
}

void PlayHistoryManager::onM_databaseChanged() {
    refreshData(loadAllHistorys());
    emit m_dataChanged();
}

void PlayHistoryManager::onAutoCleanupTimeout() {
    autoCleanup();
}

QVariantList PlayHistoryManager::getRecentPlays(const int limit) {
    QVariantList limitHistorys;
    for (int i = 0; i < limit; i++) {
        limitHistorys.append(m_data[i].toMap());
    }
    return limitHistorys;
}

bool PlayHistoryManager::indexAppear(const int findId) {
    for (int i = 0; i < m_data.count(); i++) {
        QVariantMap item = m_data[i].toMap();
        QString id = item["id"].toInt();
        if (id == findId) {
            return true;
        }
    }
    return false;
}

void PlayHistoryManager::addRecentPlay(const QVariantMap &obj) {
    int id = obj["id"].toInt();
    if (indexAppear(id)) {
        QSqlQuery query(m_database);
        query.prepare("DELETE FROM historys WHERE id=?");
        query.addBindValue(id);
    }
    addHistory(obj);
}

bool PlayHistoryManager::addHistory(const QVariantMap& obj) {
    QSqlQuery query(m_database);
    query.prepare(R"(
        INSERT INTO historys (id, name, artists, album, coverImg, url, allTime)
        VALUES (:id, :name, :artists, :album, :coverImg, :url, :allTime)
    )");//命名参数占位符实现参数绑定

    QString id = obj["id"].toString();
    query.bindValue(":id", id);
    query.bindValue(":name", obj["name"].toString());
    query.bindValue(":artists", obj["artists"].toString());
    query.bindValue(":album", obj["album"].toString());
    query.bindValue(":coverImg", obj["coverImg"].toString());
    query.bindValue(":url", obj["url"].toString());
    query.bindValue(":allTime", obj["allTime"].toString());

    if (!query.exec()) {
        qDebug() << "添加历史失败";
        return false;
    }
    qDebug() << "添加历史成功";
    emit m_databaseChanged();
    return true;
}
