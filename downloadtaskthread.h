#ifndef DOWNLOADTASKTHREAD_H
#define DOWNLOADTASKTHREAD_H

#include <QObject>
#include <QPointer>
#include "downloadtask.h"

class DownloadTaskThread : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString m_fileName READ getFileName WRITE setFileName NOTIFY fileNameChanged FINAL)
    Q_PROPERTY(double m_progressValue READ getProgressValue WRITE setProgressValue NOTIFY progressValueChanged FINAL)
    Q_PROPERTY(DownloadTask::TaskStatus status READ getStatus WRITE setStatus NOTIFY statusChanged FINAL)
    Q_PROPERTY(QString savePath READ getSavePath WRITE setSavePath NOTIFY savePathChanged FINAL)

public:
    explicit DownloadTaskThread();
    explicit DownloadTaskThread(const QString& url, const QString& savePath, const QString& fileName);
    ~DownloadTaskThread();
    void start();
    void pause();
    void cancel();
    void setMusicInfo(const QString& source, const QString& name, const QString& artist, const QString& album);

    QString getFileName()const;
    void setFileName(const QString& newFileName);

    Q_INVOKABLE double getProgressValue()const;
    void setProgressValue(const double newProgressValue);

    DownloadTask::TaskStatus getStatus()const;
    void setStatus(const DownloadTask::TaskStatus newStatus);

    QString getSavePath()const;
    void setSavePath(const QString& newSavePath);
signals:
    void downloadRelay(const QString &filename, const QString& savePath);

    void downloadError(const QString &error, const QString &filename);

    void nameChanged();
    void progressValueChanged(double progress);

    void fileNameChanged(const QString& fileName);

    void statusChanged(const DownloadTask::TaskStatus status);

    void savePathChanged();

    void artistsChanged();

    void albumChanged();
private:
    QPointer<DownloadTask> m_downloadTask;
    std::mutex m_mutex;
    QThread* m_thread = nullptr;
    QString m_url = "";
    QString m_savePath = "";
    QString m_fileName = "";
    DownloadTask::TaskStatus m_status = DownloadTask::TaskStatus::Normal;
    double m_progressValue = 0;
};

#endif // DOWNLOADTASKTHREAD_H
