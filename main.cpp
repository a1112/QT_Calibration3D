#include "ProjectResourceMonitor.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "filecontent.h"
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
#ifndef Q_OS_WIN
    // The Windows style is native-only. Keep the existing Windows appearance.
    QQuickStyle::setStyle(QStringLiteral("Fusion"));
#endif

    QQmlApplicationEngine engine;
    ProjectResources::install(engine);
    const QUrl url(u"qrc:/Calibration3D/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    qmlRegisterType<FileContent>("test.filecontent", 1, 0, "FileContentItem");
    engine.load(url);

    return app.exec();
}
