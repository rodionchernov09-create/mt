#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "TuringMachine.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    TuringMachine turingMachine;
    engine.rootContext()->setContextProperty("turingMachine", &turingMachine);

    engine.load(QUrl::fromLocalFile("C:/QtProjects/Turing/Main.qml"));

    return app.exec();
}
