#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QThread>

#include "worker.h"
#include "controller.h"
#include "enums.h"
#include "structs.h"

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

    //Pause scan
    QObject::connect(&controller, &Controller::pauseScanSignal, worker, &Worker::pauseScan);

    //Stop scan
    QObject::connect(&controller, &Controller::stopScanSignal, worker, &Worker::stopScan);

    //State changed
    QObject::connect(worker, &Worker::fileExplorerStateChanged, &controller, &Controller::fileExplorerStateChanged);
    QObject::connect(worker, &Worker::updateProgressStatusSignal, &controller, &Controller::updateProgressStatusSignal);

    //Ratings update
    QObject::connect(&controller, &Controller::updateWordRatingsSignal, worker, &Worker::updateWordRatings);
    QObject::connect(worker, &Worker::updateWordsRating, &controller, &Controller::updateWordsRating);

    // Подключаем завершение потока к завершению работы
    QObject::connect(worker, &Worker::workFinished, thread, &QThread::quit);
    QObject::connect(worker, &Worker::workFinished, worker, &Worker::deleteLater);
    QObject::connect(thread, &QThread::finished, thread, &QThread::deleteLater);

    QQmlApplicationEngine engine;
    // Регистрируем контроллер в QML
    engine.rootContext()->setContextProperty("controller", &controller);
    qmlRegisterUncreatableMetaObject(FileExplorerEnums::staticMetaObject,
                                     "equipment.enums", 1, 0,
                                     "FileExplorerEnums",
                                     "States for file explorer");
    qmlRegisterType<WordFrequency>("equipment.structs", 1, 0, "wordFrequency");

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
