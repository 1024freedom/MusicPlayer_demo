#include "favoritemanager.h"

FavoriteManager::FavoriteManager(QObject* parent): QObject(parent) {
    m_data = readFile(m_savePath);
}

QJsonArray FavoriteManager::data() const {
    return m_data;
}

void FavoriteManager::setData(const QJsonArray &newData) {
    if (m_data == newData) {
        return;
    }
    m_data = newData;
    emit dataChanged();
}

QString FavoriteManager::savePath() const {
    return m_savePath;
}

void FavoriteManager::setSavePath(const QString &newSavePath) {
    if (m_savePath == newSavePath) {
        return;
    }
    m_savePath = newSavePath;
    emit savePathChanged();
}

void FavoriteManager::append(const QJsonValue &obj) {
    QJsonArray jsonArr = obj.toArray();
    if (jsonArr.isEmpty()) {
        if (indexOf(QString::number(obj["id"].toInteger())) <= -1) {
            return;
        }
        m_data.insert(0, obj);
    } else {
        for (int i = 0; i < jsonArr.count(); i++) {
            QString id = QString::number(jsonArr.at(i).toObject()["id"].toInteger());
            if (indexOf(id) <= -1) {
                continue;
            }
            m_data.insert(0, jsonArr.at(i));
        }
    }
    emit dataValueChanged();
}

void FavoriteManager::remove(const QString &id) {
    int index = indexOf(id);
    if (index <= -1) {
        return;
    }
    m_data.removeAt(index);
    emit dataValueChanged();
}

QJsonArray FavoriteManager::readFile(const QString &filePath) {
    QJsonArray jsonArr;
    QFileInfo fileInfo(filePath);
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        return jsonArr;
    }
    QByteArray data(file.readAll());
    file.close();
    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &error);
    if (error.error == QJsonParseError::NoError) {
        qDebug() << "json转换成功";
        return jsonDoc.array();
    }
    qDebug() << "json转换失败";
    return jsonArr;
}

void FavoriteManager::writeFile(const QString &filePath, const QJsonArray &obj) {
    QJsonDocument jsonDoc;
    QFileInfo fileInfo(filePath);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) { //检查当前路径是否存在，不存在则创建
        dir.mkpath(".");
    }
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        return;
    }
    file.write(jsonDoc.toJson());
    file.close();
    qDebug() << "文件保存路径" << fileInfo.absoluteFilePath();
}

int FavoriteManager::indexOf(const QString &findId) {
    for (int i = 0; i < m_data.count(); i++) {
        QString id = QString::number(m_data.at(i).toObject()["id"].toInteger());
        if (id == findId) {
            return i;
        }
        return -1;
    }
}

void FavoriteManager::onDataValueChanged() {
    //数据变化时写入文件
    writeFile(m_savePath, m_data);
}





