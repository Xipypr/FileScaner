#include "worker.h"
#include <QtConcurrent/QtConcurrent>

Worker::Worker(QObject *parent)
    : QObject{parent}
    , m_fileExplorer(m_data, this)
{
    connect(&m_fileExplorer, &FileExplorer::stateChanged, this, &Worker::fileExplorerStateChanged);
    connect(&m_fileExplorer, &FileExplorer::updateProgressStatusSignal, this, &Worker::updateProgressStatusSignal);
}

void Worker::openFile(const QString &fileName)
{
    auto result = m_fileExplorer.openFile(fileName);
    updateWordRatings();
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
}

void Worker::updateWordRatings()
{
    auto result = m_data.getTopWords();
    emit updateWordsRating(result);
}
