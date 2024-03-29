#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "FileContent.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/Calibration3D/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    qmlRegisterType<FileContent>("test.filecontent", 1, 0, "FileContentItem");
    engine.load(url);

    return app.exec();
}
