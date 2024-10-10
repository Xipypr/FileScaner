#include "fileexplorer.h"

#include <QDebug>
#include <QRegularExpression>
#include <QtConcurrent/QtConcurrent>

static QRegularExpression regExp("\\s+");

FileExplorer::FileExplorer(DataModel &dataModel, QObject *parent)
    : QObject{parent}
    , m_dataModel(dataModel)
{}

qint64 FileExplorer::openFile(const QString &fileName)
{
    m_file.setFileName(fileName);
    if (!m_file.open(QIODevice::ReadOnly | QIODevice::Text | QIODevice::ExistingOnly))
    {
        return -1;
    }

    setNewState(FileExplorerEnums::States::READY_TO_START);
    updateProgressStatus();
    return m_file.size();
}

void FileExplorer::startScan()
{
    //TODO научиться прибить это
    auto feature = QtConcurrent::run(&FileExplorer::startScanFile, this);
}

void FileExplorer::pauseScan()
{
    if (m_state == FileExplorerEnums::States::RUNNIG)
    {
        setNewState(FileExplorerEnums::States::PAUSED);
        qDebug() << "paused";
    }
    else if (m_state == FileExplorerEnums::States::PAUSED)
    {
        startScan();
        qDebug() << "running";
    }
}

void FileExplorer::stopScan()
{
    setNewState(FileExplorerEnums::States::STOPPED);
    reset();
}


void FileExplorer::startScanFile()
{
    if (!m_file.isOpen())
    {
        setNewState(FileExplorerEnums::States::STOPPED);
        return;
    }

    setNewState(FileExplorerEnums::States::RUNNIG);

    m_file.seek(m_currentOffset);

    QStringList words;
    quint8 iter = 0;

    while (m_state == FileExplorerEnums::States::RUNNIG  &&
           !m_file.atEnd())
    {
        QByteArray block = m_file.read(m_buffSize);
        block.prepend(m_leftover);

        int lastSpaceIndex = block.lastIndexOf(' ');
        if (lastSpaceIndex != -1)
        {
            m_leftover = block.mid(lastSpaceIndex + 1);
            block = block.left(lastSpaceIndex);
        }
        else
        {
            m_leftover = block;
            continue;
        }

        words.append(QString::fromUtf8(block).split(regExp, Qt::SkipEmptyParts));

        m_currentOffset+=m_buffSize;
        ++iter;

        //Just a simple stupid solution to update proress
        if (iter == 10)
        {
            m_dataModel.updateData(std::move(words));
            updateProgressStatus();
        }
    }


    if (m_file.atEnd())
    {
        emit updateProgressStatusSignal(100);
        setNewState(FileExplorerEnums::States::READING_ENDED);
        reset();
        return;
    }

    if (m_state != FileExplorerEnums::States::PAUSED)
    {
        stopScan();
    }
}

void FileExplorer::setNewState(FileExplorerEnums::States newState)
{
    if (m_state == newState)
    {
        return;
    }

    m_state = newState;
    emit stateChanged(m_state);
}

void FileExplorer::reset()
{
    m_file.close();
    m_currentOffset = 0;
    m_leftover = {};
    m_dataModel.reset();
}

void FileExplorer::updateProgressStatus()
{
    double progress = double(m_currentOffset)/m_file.size() * 100;

    emit updateProgressStatusSignal(progress);
}
