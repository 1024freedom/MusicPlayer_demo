#ifndef LOCALMUSICMANAGER_H
#define LOCALMUSICMANAGER_H
#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QFutureWatcher>
#include <QDebug>

class LocalMusicManager: public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList data READ getData NOTIFY dataChanged FINAL)
    Q_PROPERTY(bool isLoading READ getIsLoading  NOTIFY isLoadingChanged FINAL)//加载状态
public:
    explicit LocalMusicManager(QObject* parent = nullptr);
    ~LocalMusicManager();
    Q_INVOKABLE void scanDirectory(const QString& path);
    Q_INVOKABLE void refreshData();
    Q_INVOKABLE int getMusicCount()const;
    QVariantList getData()const;
    bool getIsLoading()const;
private:
    bool initializeDatabase();
    bool createTable();

    // QSqlDatabase m_database;QSqlDatabase 连接不能跨线程使用，故不使用类成员
    QVariantList m_data;
    bool isLoading = false;
    QString m_databasePath = "userInfo/localMusic.db";

    //异步任务监控
    QFutureWatcher<void> m_watcher;
    //静态辅助函数，用于在子线程中运行
    static void scanTask(const QString& folderPath, const QString& dbPath);
    static QVariantMap extractMetaData(const QFileInfo& fileInfo);

signals:
    void dataChanged();
    void isLoadingChanged();
    void scanFinished(int count);//扫描结束信号，传递新增的数量

};

#endif // LOCALMUSICMANAGER_H
