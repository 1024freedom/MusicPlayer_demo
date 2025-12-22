#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "framelesswindow.h"
#include "favoritemanager.h"
#include "desktoplyric.h"
#include "imagecolor.h"
#include "thememanager.h"
#include "musicdownload.h"
#include "playhistorymanager.h"
#include "localmusicmanager.h"

int main(int argc, char* argv[]) {

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/MusicPlayer_demo/main.qml"));

    // 关键：设置组织名和应用名（自定义名称）
    QCoreApplication::setOrganizationName("sz");
    QCoreApplication::setApplicationName("MusicPlayerDemo");

    qmlRegisterType<FramelessWindow>("sz.window", 1, 0, "FramelessWindow");
    qmlRegisterType<FavoriteManager>("sz.window", 1, 0, "FavoriteManager");
    qmlRegisterType<DesktopLyric>("sz.window", 1, 0, "DesktopLyric");
    qmlRegisterType<ImageColor>("sz.window", 1, 0, "ImageColor");
    qmlRegisterType<ThemeManager>("sz.window", 1, 0, "ThemeManager");
    qmlRegisterType<PlayHistoryManager>("sz.window", 1, 0, "PlayHistoryManager");
    qmlRegisterType<MusicDownload>("sz.window", 1, 0, "MusicDownload");
    //注册为不可创建类型，但qml可访问其属性
    qmlRegisterUncreatableType<DownloadTaskThread>("sz.window", 1, 0, "DownloadTaskThread", "Cannot create in QML");
    qmlRegisterType<LocalMusicManager>("sz.window", 1, 0, "LocalMusicManager");

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
    [url](QObject * obj, const QUrl & objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
