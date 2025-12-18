#ifndef MUSICDOWNLOAD_H
#define MUSICDOWNLOAD_H

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QCoreApplication>
#include <QMap>
#include <QThread>
#include <QDebug>
#include <mutex>
#include "downloadtaskthread.h"

class MusicDownload: public QObject {
    Q_OBJECT
    Q_PROPERTY(int count READ getCount WRITE setCount NOTIFY countChanged FINAL)
    Q_PROPERTY(QMap<QString, DownloadTaskThread*> downloadInfos READ getDownloadInfos WRITE setDownloadInfos NOTIFY downloadInfosChanged FINAL)
    Q_PROPERTY(QString downloadSavePath READ getDownloadSavePath WRITE setDownloadSavePath NOTIFY downloadSavePathChanged FINAL)
    Q_PROPERTY(QVariantList data READ data WRITE setData NOTIFY dataChanged FINAL)

public:
    explicit MusicDownload(QObject* parent = nullptr);
    ~MusicDownload();

    Q_INVOKABLE void startDownload(const QString& taskId, const QVariantMap& obj);
    Q_INVOKABLE void pauseDownload(const QString& taskId);
    Q_INVOKABLE void cancelDownload(const QString& taskId);
    Q_INVOKABLE void addTask(const QString& url, const QString& fileName, const QString& taskId);
    Q_INVOKABLE void moveTask(const QString& taskId);
    Q_INVOKABLE bool localExist(const QString& id);
    Q_INVOKABLE bool isDownloading(const QString& taskId);//taskid和id其实是一个

    int getCount()const;
    void setCount(int newCount);

    QMap<QString, DownloadTaskThread*> getDownloadInfos()const;
    void setDownloadInfos(const QMap<QString, DownloadTaskThread*>& newDownloadInfos);

    QString getDownloadSavePath()const;
    void setDownloadSavePath(const QString& newDownloadSavePath);

    QVariantList data()const;
    void setData(const QVariantList& newData);

signals:
    void countChanged();
    void downloadInfosChanged();
    void downloadSavePathChanged();
    void dataChanged();
private slots:
    void onDataChanged();
private:
    bool initDatabase();
    bool createTable();
    QVariantList loadAllDownloads();
    bool addDownload(const QVariantMap& obj, const QString& savePath);

    QSqlDatabase m_database;
    QMap<QString, DownloadTaskThread*> m_downloadInfos;
    QVariantList m_data;//元数据和下载好的音频文件路径
    std::mutex m_mutex;
    QString m_downloadSavePath = "userInfo/downloadInfo";
    QString m_savePath = "userInfo/downloadInfo.db";
    int m_count = 0;
    int m_taskCount = 0;
};


#endif // MUSICDOWNLOAD_H
