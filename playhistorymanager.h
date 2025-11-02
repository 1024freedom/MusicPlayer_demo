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
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>

class PlayHistoryManager: public QObject {
    Q_OBJECT

public:
    explicit PlayHistoryManager(QObject* parent = nullptr);
    ~PlayHistoryManager();
    Q_INVOKABLE void addRecentPlay(const QVariantMap& obj);
    Q_INVOKABLE QVariantList getRecentPlays(const int limit);
private:
    QSqlDatabase m_database;
    QVariantList m_data;
    QString m_databasePath = "userInfo/historyMusic.db"; //数据库文件路径
    //运行时清理
    QTimer* m_cleanupTimer;//程序运行时定时清理定时器
    int m_cleanupDays = 7; //程序运行七天为一个清理周期
    //长期化清理
    QDateTime getLastCleanupTime();
    void setLastCleanupTime(const QDateTime& time);
    bool shouldCleanup();

    bool initializeDatabase();
    bool createTable();
    bool indexAppear(const int findId);//查找是否已经存在历史，若存在则删除之前的位置，重新录入数据
    bool addHistory(const QVariantMap& obj);
    QVariantList loadAllHistorys();
    void autoCleanup();//清除七天前的数据
    void refreshData(const QVariantList& newData);
signals:
    void m_dataChanged();
    void m_databaseChanged();
private slots:
    void onAutoCleanupTimeout();
    void onM_databaseChanged();
};

#endif // PLAYHISTORYMANAGER_H
