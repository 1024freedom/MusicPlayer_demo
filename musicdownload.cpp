#include "musicdownload.h"

//数据库存储歌曲元数据和其音频文件对应的存储路径，底层downloadtask下载的是歌曲音频数据，存储在本地文件夹中

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

void MusicDownload::startDownload(const QString &taskId, const QVariantMap obj) { //传入任务id和歌曲元数据
    if (m_downloadInfos.find(taskId) == m_downloadInfos.end()) {
        qDebug() << "无此任务";
        return;
    }
    m_downloadInfos[taskId]->start();

    connect(m_downloadInfos[taskId], &DownloadTaskThread::downloadRelay, this, [this, taskId, obj](const QString & fileName, const QString & savePath) {
        if (this->localIndexOf() >= 0) {//该歌曲是否已经下载过
            return;
        }
        //将元数据和下载好的音频文件路径写入数据库

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

void MusicDownload::initDatabase() {

}
void MusicDownload::
