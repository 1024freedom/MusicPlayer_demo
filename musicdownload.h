#ifndef MUSICDOWNLOAD_H
#define MUSICDOWNLOAD_H

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include <QCoreApplication>
#include <QMap>
#include <QThread>
#include <QDebug>
#include <mutex>
#include "downloadtaskthread.h"

class MusicDownload: public QObject {
    Q_OBJECT
    Q_PROPERTY(int count READ getCount NOTIFY countChanged FINAL)
    Q_PROPERTY(QMap<QString, down> READ  WRITE set NOTIFY Changed FINAL)
public:
    MusicDownload();
};

#endif // MUSICDOWNLOAD_H
