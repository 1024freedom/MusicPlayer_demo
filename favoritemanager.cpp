// #include "favoritemanager.h"

// FavoriteManager::FavoriteManager(QObject* parent): QObject(parent) {
//     m_data = readFile(m_savePath);
//     connect(this, &FavoriteManager::dataValueChanged, this, &FavoriteManager::onDataValueChanged);
// }

// QJsonArray FavoriteManager::data() const {
//     return m_data;
// }

// void FavoriteManager::setData(const QJsonArray &newData) {
//     if (m_data == newData) {
//         return;
//     }
//     m_data = newData;
//     emit dataChanged();
// }

// QString FavoriteManager::savePath() const {
//     return m_savePath;
// }

// void FavoriteManager::setSavePath(const QString &newSavePath) {
//     if (m_savePath == newSavePath) {
//         return;
//     }
//     m_savePath = newSavePath;
//     emit savePathChanged();
// }

// void FavoriteManager::append(const QJsonObject &obj) {

//     QString id = QString::number(obj["id"].toInt());
//     if (indexOf(id) <= -1) {
//         m_data.insert(0,obj);
//     }

//     emit dataValueChanged();
// }

// void FavoriteManager::remove(const QString &id) {
//     int index = indexOf(id);
//     if (index <= -1) {
//         return;
//     }
//     m_data.removeAt(index);
//     emit dataValueChanged();
// }

// QJsonArray FavoriteManager::readFile(const QString &filePath) {
//     QJsonArray jsonArr;
//     QFile file(filePath);
//     if (!file.open(QIODevice::ReadOnly)) {
//         return jsonArr;
//     }
//     QByteArray data(file.readAll());
//     file.close();
//     QJsonParseError error;
//     QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
//     if (error.error == QJsonParseError::NoError) {
//         qDebug() << "json转换成功";
//         return jsonDoc.array();
//     }
//     qDebug() << "json转换失败";
//     return jsonArr;
// }

// void FavoriteManager::writeFile(const QString &filePath, const QJsonArray &obj) {
//     QJsonDocument jsonDoc(obj);
//     QFileInfo fileInfo(filePath);
//     QDir dir = fileInfo.absoluteDir();
//     if (!dir.exists()) { //检查当前路径是否存在，不存在则创建
//         dir.mkpath(".");
//     }
//     QFile file(filePath);
//     if (!file.open(QIODevice::WriteOnly)) {
//         return;
//     }
//     file.write(jsonDoc.toJson());
//     file.close();
//     qDebug() << "文件保存路径" << fileInfo.absoluteFilePath();
// }

// int FavoriteManager::indexOf(const QString &findId) {
//     for (int i = 0; i < m_data.count(); i++) {
//         QString id = QString::number(m_data.at(i).toObject()["id"].toInt());
//         if (id == findId) {
//             return i;
//         }
//     }
//     return -1;
// }

// void FavoriteManager::onDataValueChanged() {
//     //数据变化时写入文件
//     writeFile(m_savePath, m_data);
// }

#include "favoritemanager.h"

FavoriteManager::FavoriteManager(QObject* parent): QObject(parent) {
    if (!initializeDatabase()) {
        qDebug() << "数据库未成功加载";
    } else {
        refreshData(loadAllFavorites());
    }
}

FavoriteManager::~FavoriteManager() {
    if (m_database.isOpen()) {
        m_database.close();
    }
}

bool FavoriteManager::initializeDatabase() {
    //确保目标目录存在，不存在则创建
    QFileInfo fileInfo(m_databasePath);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    //打开数据库(sqlite)
    m_database = QSqlDatabase::addDatabase("QSQLITE", "favorites_connection"); //连接名为favorites_connection的sqlite数据库
    m_database.setDatabaseName(m_databasePath);//绑定指定目录，若目标目录有数据库文件，则直接打开，否则创建一个新的

    if (!m_database.open()) {
        qDebug() << "数据库打开失败";
        return false;
    } else {
        qDebug() << "数据库打开成功";
    }

    //建表
    return createTable();
}

bool FavoriteManager::createTable() {

    QSqlQuery query(m_database);
    QString createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS favorites (
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
        qDebug() << "建表失败";
        return false;
    }

    //创建索引提高查询性能
    query.exec("CREATE INDEX IF NOT EXISTS idx_id ON favorites (id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_create_time ON favorites (url)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_create_time ON favorites (coverImg)");

    return true;
}

QVariantList FavoriteManager::data() const {
    return m_data;
}

QString FavoriteManager::databasePath()const {
    return m_databasePath;
}

void FavoriteManager::setDatabasePath(const QString &newDatabasePath) {
    if (m_databasePath == newDatabasePath) {
        return;
    }
    //关闭现有数据库连接
    if (m_database.isOpen()) {
        m_database.close();
    }
    m_databasePath = newDatabasePath;
    if (initializeDatabase()) {
        refreshData(loadAllFavorites());
    } else {
        qDebug() << "新数据库初始化失败";
    }
    emit databasePathChanged();
}

// void FavoriteManager::append(const QJsonObject &obj) {
//     QString id = QString::number(obj["id"].toInt());
//     if (!favoriteExists(id)) {
//         if (addFavorite(obj)) {
//             refreshData(loadAllFavorites());
//         } else {
//             qDebug() << "添加收藏失败";
//         }
//     }
// }
void FavoriteManager::append(const QVariantMap& obj) {
    QString id = obj["id"].toString();
    if (!favoriteExists(id)) {
        if (addFavorite(obj)) {
            refreshData(loadAllFavorites());
        } else {
            qDebug() << "添加收藏失败";
        }
    }
}

void FavoriteManager::remove(const QString &id) {
    if (deleteFavorite(id)) {
        refreshData(loadAllFavorites());
    } else {
        qDebug() << "移除收藏失败";
    }
}

// int FavoriteManager::indexOf(const QString &findId) {
//     for (int i = 0; i < m_data.count(); i++) {
//         QString id = QString::number(m_data.at(i).toObject()["id"].toInt());
//         if (id == findId) {
//             return i;
//         }
//     }
//     return -1;
// }
int FavoriteManager::indexOf(const QString &findId) {
    for (int i = 0; i < m_data.count(); i++) {
        QVariantMap item = m_data[i].toMap();
        QString id = item["id"].toString();
        if (id == findId) {
            return i;
        }
    }
    return -1;
}

QVariantMap FavoriteManager::get(int index) const {
    if (index >= 0 && index <= m_data.count()) {
        return m_data[index].toMap();
    }
    return QVariantMap();
}

QVariantList FavoriteManager::loadAllFavorites() {
    // QJsonArray favoritesArray;
    QVariantList favoritesList;
    QSqlQuery query(m_database);
    QString selectSQL = "SELECT id, name, artists, album, coverImg, url, allTime FROM favorites ORDER BY create_time DESC"; //获取数据库中的数据
    if (!query.exec(selectSQL)) {
        qDebug() << "获取收藏数据失败";
        return favoritesList;
    }

    while (query.next()) {
        // QJsonObject favorite;
        QVariantMap favorite;
        favorite["id"] = query.value("id").toString().toInt();
        favorite["name"] = query.value("name").toString();
        favorite["artists"] = query.value("artists").toString();
        favorite["album"] = query.value("album").toString();
        favorite["coverImg"] = query.value("coverImg").toString();
        favorite["url"] = query.value("url").toString();
        favorite["allTime"] = query.value("allTime").toString();
        // favoritesArray.append(favorite);
        favoritesList.append(favorite);
    }

    qDebug() << "从数据库加载了" << favoritesList.count() << "条数据";
    return favoritesList;
}

bool FavoriteManager::addFavorite(const /*QJsonObject*/QVariantMap &obj) {
    QSqlQuery query(m_database);
    query.prepare(R"(
        INSERT INTO favorites (id, name, artists, album, coverImg, url, allTime)
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
        qDebug() << "添加收藏失败";
        return false;
    }
    qDebug() << "添加收藏成功";
    return true;
}

bool FavoriteManager::deleteFavorite(const QString &id) {
    QSqlQuery query(m_database);
    query.prepare("DELETE FROM favorites WHERE id = :id");
    query.bindValue(":id", id);
    if (!query.exec()) {
        qDebug() << "移除收藏失败";
        return false;
    }
    qDebug() << "移除收藏成功";
    return true;
}

bool FavoriteManager::favoriteExists(const QString &id) {
    QSqlQuery query(m_database);
    query.prepare("SELECT COUNT(*) FROM favorites WHERE id = :id");
    query.bindValue(":id", id);
    if (!query.exec() || !query.next()) {
        return false;
    }
    return query.value(0).toInt() > 0;
}

void FavoriteManager::refreshData(const QVariantList& newData) {
    if (m_data != newData) {
        m_data = newData;
        emit dataChanged();
    }
}

