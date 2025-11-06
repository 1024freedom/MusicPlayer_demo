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


