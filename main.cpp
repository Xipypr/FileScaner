#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QThread>

#include "worker.h"
#include "controller.h"
#include "enums.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);


    // Создаём поток и рабочий объект
    QThread *thread = new QThread;
    Worker *worker = new Worker;
    worker->moveToThread(thread);

    Controller controller;

    // Openning file
    QObject::connect(&controller, &Controller::openFileSignal, worker, &Worker::openFile);
    QObject::connect(worker, &Worker::fileOpened, &controller, &Controller::fileOpened);

    //Scan file
    QObject::connect(&controller, &Controller::startScanSignal, worker, &Worker::startScan);
    QObject::connect(worker, &Worker::scanStarted, &controller, &Controller::scanStarted);

    //Pause scan
    QObject::connect(&controller, &Controller::pauseScanSignal, worker, &Worker::pauseScan);
    QObject::connect(worker, &Worker::scanPaused, &controller, &Controller::scanPaused);

    //Stop scan
    QObject::connect(&controller, &Controller::stopScanSignal, worker, &Worker::stopScan);
    QObject::connect(worker, &Worker::scanStopped, &controller, &Controller::scanStopped);

    //State changed
    QObject::connect(worker, &Worker::fileExplorerStateChanged, &controller, &Controller::fileExplorerStateChanged);
    QObject::connect(worker, &Worker::updateProgressStatusSignal, &controller, &Controller::updateProgressStatusSignal);

    // Подключаем завершение потока к завершению работы
    QObject::connect(worker, &Worker::workFinished, thread, &QThread::quit);
    QObject::connect(worker, &Worker::workFinished, worker, &Worker::deleteLater);
    QObject::connect(thread, &QThread::finished, thread, &QThread::deleteLater);

    QQmlApplicationEngine engine;
    // Регистрируем контроллер в QML
    engine.rootContext()->setContextProperty("controller", &controller);
    qmlRegisterUncreatableMetaObject(FileExplorerEnums::staticMetaObject,
                                     "com.enums", 1, 0,
                                     "FileExplorerEnums",
                                     "States for file explorer");

    // Запуск потока
    thread->start();

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("FileScaner", "Main");

    return app.exec();
}
