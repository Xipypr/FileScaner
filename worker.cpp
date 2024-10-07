#include "worker.h"
#include <QtConcurrent/QtConcurrent>

Worker::Worker(QObject *parent)
    : QObject{parent}
{
    connect(&m_fileExplorer, &FileExplorer::scanStopped, this, &Worker::scanStopped);
    connect(&m_fileExplorer, &FileExplorer::scanStarted, this, &Worker::scanStarted);
}

void Worker::process() {
    for (int i = 0; i < 5; ++i) {
        emit dataChanged(i);  // Сигнал для передачи данных
        QThread::sleep(1);    // Имитация работы
    }
    emit workFinished();  // Сигнал завершения работы
}

void Worker::openFile(const QString &fileName)
{
    auto result = m_fileExplorer.openFile(fileName);
    emit fileOpened(result);
}

void Worker::startScan()
{
    m_fileExplorer.startScan();
}

void Worker::pauseScan()
{
    m_fileExplorer.pauseScan();
}

void Worker::stopScan()
{
    m_fileExplorer.stopScan();
    //should get signal from fileExplorer
}
