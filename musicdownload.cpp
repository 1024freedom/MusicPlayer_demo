#include "musicdownload.h"

MusicDownload::MusicDownload(QObject* parent): QObject(parent) {
    m_data = readFile(m_savePath);
    connect(this, &MusicDownload::dataChanged, this, &MusicDownload::onDataChanged);
}

MusicDownload::~MusicDownload() {
    for (const auto taskInfo : m_downloadInfos.values()) {
        if (taskInfo) {
            taskInfo->deleteLater();
        }
    }
}

void MusicDownload::startDownload(const QString &taskId, const QVariantMap &obj) {
    if (m_downloadInfos.find(taskId) == m_downloadInfos.end()) {
        qDebug() << "无此任务";
        return;
    }
    connect(m_downloadInfos[taskId], &DownloadTaskThread::downloadRelay, this, [this, obj, taskId](const QString & fileName, const QString & savePath) {
        if (this->localIndexOf(QString::number(obj["id"].toInt())) >= 0) {
            return;
        }
        QVariantMap o(obj);
        o["url"] = savePath;
        this->m_data.insert(0, o);
        this->m_taskCount++;
        this->moveTask(taskId);
        emit dataChanged();
    });//写入数据信号
    m_downloadInfos[taskId]->start();
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
