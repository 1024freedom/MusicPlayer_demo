#include "downloadtask.h"

DownloadTask::DownloadTask(QObject* parent): QObject(parent) {}

DownloadTask::DownloadTask(const QString &url, const QString &savePath, const QString &fileName): m_url(url), m_savePath(savePath), m_fileName(fileName) {

}

DownloadTask::~DownloadTask() {
    if (m_reply) {
        m_reply->deleteLater();
    }
    if (m_manager) {
        m_manager->deleteLater();
    }
}

// void DownloadTask::startDownload() {
//     qDebug() << "运行线程:" << QThread::currentThreadId();
//     //确保manager是全新的，防止僵尸对象问题
//     if (m_manager) {
//         m_manager->deleteLater();
//         m_manager = nullptr;
//     }
//     m_manager = new QNetworkAccessManager(this);
//     //设置状态
//     setStatus(TaskStatus::Loading);
//     m_paused = false;
//     //请求网络
//     QNetworkRequest request;
//     request.setUrl(QUrl(m_url));
//     //111
//     request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);

//     //设置http请求头
//     request.setRawHeader(QByteArray("Range"), QString("bytes=" + QString::number(m_bufferByte) + "-").toLocal8Bit());
//     m_reply = m_manager->get(request);
//     qDebug() << "音乐" + m_fileName + "开始下载";
//     //准备写入文件
//     QString fullPath = m_savePath + "/" + m_fileName;
//     QFileInfo fileInfo(fullPath);
//     QDir dir = fileInfo.absoluteDir();
//     if (!dir.exists()) {
//         dir.mkpath(".");
//     }
//     m_file.setFileName(fullPath);
//     if (!m_file.open(QIODevice::WriteOnly) | QIODevice::Append) {
//         m_reply->abort();
//         return;
//     }

//     //有数据可读信号
//     connect(m_reply, &QNetworkReply::readyRead, this, &DownloadTask::onDownloadReadyRead, Qt::UniqueConnection);
//     //下载完成信号
//     connect(m_reply, &QNetworkReply::finished, this, &DownloadTask::onFinished, Qt::UniqueConnection);
//     //下载进度更新信号
//     connect(m_reply, &QNetworkReply::downloadProgress, this, &DownloadTask::onDownloadProgress, Qt::UniqueConnection);
// }


// 出现Internal problem原因：Qt 6 网络模块对线程亲和性要求极高。当 DownloadTask 通过 moveToThread 移动后，如果 QNetworkAccessManager 将其设为父对象（this），会导致底层初始化时读取到错误的线程上下文状态，从而引发内部错误。

//解决：断绝父子关系。在 startDownload 中创建 QNetworkAccessManager 时传入 nullptr，强制其绑定到当前子线程的纯净环境，并在析构时手动 deleteLater 释放。
void DownloadTask::startDownload() {
    qDebug() << "运行线程:" << QThread::currentThreadId();

    // 1. 清理旧对象
    if (m_manager) {
        // 如果有正在进行的回复，先中止，防止野指针
        if (m_reply && m_reply->isRunning()) m_reply->abort();
        m_manager->deleteLater();
        m_manager = nullptr;
    }

    // ---------------------------------------------------------
    // 传入 nullptr，不要传 this！
    // 即使 m_manager 变成了孤儿对象（没有父），我们在析构函数里手动 delete 即可。
    // 这避免了 QNAM 在初始化时被 DownloadTask 的线程状态干扰。
    // ---------------------------------------------------------
    m_manager = new QNetworkAccessManager(nullptr);

    // 状态设置
    setStatus(TaskStatus::Loading);
    m_paused = false;

    // 构建请求
    QNetworkRequest request;
    request.setUrl(QUrl(m_url));
    qDebug() << "下载URL:" << m_url;
    // 彻底禁用 Qt 6 的 HTTP2 和 缓存
    // "Internal problem" 常由缓存层试图复用错误的连接导致
    request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);

    request.setRawHeader(QByteArray("Range"), QString("bytes=" + QString::number(m_bufferByte) + "-").toLocal8Bit());

    // 文件准备
    QString fullPath = m_savePath + "/" + m_fileName;
    QFileInfo fileInfo(fullPath);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) dir.mkpath(".");

    m_file.setFileName(fullPath);

    // 打开文件
    if (!m_file.open(QIODevice::WriteOnly | QIODevice::Append)) {
        qDebug() << "文件打开失败";
        setStatus(TaskStatus::Error);
        emit downloadError("文件打开失败", m_fileName);
        // 记得清理 manager，因为它是无父对象的
        m_manager->deleteLater();
        m_manager = nullptr;
        return;
    }

    // 发起请求
    try {
        m_reply = m_manager->get(request);
        qDebug() << "音乐" + m_fileName + "开始下载";

        // 信号连接
        connect(m_reply, &QNetworkReply::readyRead, this, &DownloadTask::onDownloadReadyRead, Qt::UniqueConnection);
        connect(m_reply, &QNetworkReply::finished, this, &DownloadTask::onFinished, Qt::UniqueConnection);
        connect(m_reply, &QNetworkReply::downloadProgress, this, &DownloadTask::onDownloadProgress, Qt::UniqueConnection);
    } catch (...) {
        qDebug() << "QNAM Get 发生异常";
        setStatus(TaskStatus::Error);
    }
}


void DownloadTask::pauseDownload() {
    if (m_status != TaskStatus::Loading) {
        return;
    }
    m_paused = true;
    setStatus(TaskStatus::Paused);
    if (m_reply) {
        m_reply->abort();
    }
    qDebug() << "暂停下载" << m_fileName << "已下载" << m_progressByte + m_bufferByte;
}

void DownloadTask::cancelDownload() {
    setStatus(TaskStatus::Cancel);
    if (m_reply) {
        m_reply->abort();
    }
    qDebug() << "取消下载音乐" << m_fileName;
}

void DownloadTask::onDownloadReadyRead() {
    QByteArray data = m_reply->readAll();
    m_progressByte += data.length();
    m_file.write(data);//写入文件
}

void DownloadTask::onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal) {
    if (bytesTotal > 0) {
        double progress = (double)(bytesReceived + m_bufferByte) / (bytesTotal + m_bufferByte);
        setProgressValue(progress);
    }
}

double DownloadTask::progressValue()const {
    return m_progressValue;
}

void DownloadTask::setProgressValue(double newProgressValue) {
    if (qFuzzyCompare(m_progressByte, newProgressValue)) { //浮点数模糊比较
        return;
    }

    m_progressValue = newProgressValue;
    emit progressValueChanged(m_progressValue);
}

DownloadTask::TaskStatus DownloadTask::status()const {
    return m_status;
}

void DownloadTask::setStatus(TaskStatus newStatus) {
    if (m_status == newStatus) {
        return;
    }
    m_status = newStatus;
    emit statusChanged(m_status);
}

QString DownloadTask::url()const {
    return m_url;
}

void DownloadTask::setUrl(const QString &newUrl) {
    if (m_url == newUrl) {
        return;
    }
    m_url = newUrl;
    emit urlChanged(m_url);
}

QString DownloadTask::fileName()const {
    return m_fileName;
}

void DownloadTask::setFileName(const QString &newfileName) {
    if (m_fileName == newfileName) {
        return;
    }
    m_fileName = newfileName;
    emit fileNameChanged(m_fileName);
}

QString DownloadTask::savePath()const {
    return m_savePath;
}

void DownloadTask::setSavePath(const QString &newSavePath) {
    if (m_savePath == newSavePath) {
        return;
    }
    m_savePath = newSavePath;
    emit savePathChanged(m_savePath);
}

void DownloadTask::onFinished() {
    //空指针保护防止多次调用导致崩溃
    if (!m_reply)return;
    m_file.close();

    auto noError_func = [&]() {
        setStatus(TaskStatus::Ready);
        // 检查文件是否真的存在且有大小
        if (QFile::exists(m_file.fileName()) && m_file.size() > 0) {
            qDebug() << "音乐：" + m_fileName + "下载完成" + m_file.fileName();
            emit downloadRelay(m_fileName, m_file.fileName());
        } else {
            setStatus(TaskStatus::Error);
            m_file.remove(); // 它是空文件或有问题的，删掉
            qDebug() << "音乐：" + m_fileName + "文件异常";
            emit downloadError("文件写入异常", m_fileName);
        }
    };
    auto defaultError_func = [&]() {
        m_bufferByte += m_progressByte;
        setStatus(TaskStatus::Error);
        qDebug() << "音乐：" + m_fileName + "下载失败" + m_reply->errorString();
        emit downloadError(m_reply->errorString(), m_fileName);
    };
    auto canceledError_func = [&]() {
        if (m_status == TaskStatus::Paused) {
            m_bufferByte += m_progressByte;
        }
        if (m_status == TaskStatus::Cancel) {
            m_progressByte = 0;
            m_bufferByte = 0;
            m_file.remove();
        }
    };
    switch (m_reply->error()) {
    case QNetworkReply::NoError:
        noError_func();
        break;
    case QNetworkReply::OperationCanceledError:
        canceledError_func();
        break;
    default:
        defaultError_func();
        break;
    }
    m_progressByte = 0;
    m_reply->deleteLater();
    m_reply = nullptr;
    emit downloadFinished();
}




