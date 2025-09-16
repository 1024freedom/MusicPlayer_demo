#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "framelesswindow.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/MusicPlayer_demo/main.qml"));

    qmlRegisterType<FramelessWindow>("sz.window", 1, 0, "FramelessWindow");

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
