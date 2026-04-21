#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFileInfo>
#include "TuringMachine.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    TuringMachine turingMachine;
    engine.rootContext()->setContextProperty("turingMachine", &turingMachine);

    // Загружаем Main.qml из папки с исполняемым файлом
    QString qmlPath = QCoreApplication::applicationDirPath() + "/Main.qml";

    if (!QFileInfo::exists(qmlPath)) {
        // Если не нашли, пробуем из папки проекта
        qmlPath = "C:/QtProjects/Turing/Main.qml";
    }

    const QUrl url = QUrl::fromLocalFile(qmlPath);
    engine.load(url);

    return app.exec();
}
