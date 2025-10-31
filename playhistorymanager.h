#ifndef PLAYHISTORYMANAGER_H
#define PLAYHISTORYMANAGER_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <Qtsql/QSqlDatabase>
#include <Qtsql/QSqlQuery>
#include <Qtsql/QSqlError>
#include <QVariant>
#include <QDateTime>
#include <QVariantList>
#include <QVariantMap>

class PlayHistoryManager: public QObject {
    Q_OBJECT

public:
    explicit PlayHistoryManager(QObject* parent = nullptr);
    // ~PlayHistoryManager();
    // Q_INVOKABLE void addRecentPlay(const QVariantMap& obj);

};

#endif // PLAYHISTORYMANAGER_H
