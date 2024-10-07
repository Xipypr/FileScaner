#include "fileexplorer.h"

#include <QDebug>
#include <QRegularExpression>
#include <QtConcurrent/QtConcurrent>

static QRegularExpression regExp("\\s+");

FileExplorer::FileExplorer(QObject *parent)
    : QObject{parent}
{}

qint64 FileExplorer::openFile(const QString &fileName)
{
    m_file.setFileName(fileName);
    if (!m_file.open(QIODevice::ReadOnly | QIODevice::Text | QIODevice::ExistingOnly))
    {
        return -1;
    }

    setNewState(States::READY_TO_START);
    return m_file.size();
}

void FileExplorer::startScan()
{
    auto feature = QtConcurrent::run(&FileExplorer::startScanFile, this);
}

void FileExplorer::pauseScan()
{
    if (m_state == States::RUNNIG)
    {
        setNewState(States::PAUSED);
        qDebug() << "paused";
    }
    else if (m_state == States::PAUSED)
    {
        startScan();
        qDebug() << "running";
    }
}

void FileExplorer::stopScan()
{
    setNewState(States::STOPED);
    emit scanStopped();
    reset();
}


void FileExplorer::startScanFile()
{
    if (!m_file.isOpen())
    {
        emit scanStopped();
        return;
    }

    setNewState(States::RUNNIG);
    emit scanStarted();

    m_file.seek(m_currentOffset);

    QStringList words;

    while (m_state == States::RUNNIG  &&
           !m_file.atEnd())
    {
        QByteArray block = m_file.read(m_buffSize); // Читаем блок данных
        block.prepend(m_leftover); // Добавляем незавершённое слово из предыдущего блока

        int lastSpaceIndex = block.lastIndexOf(' ');
        if (lastSpaceIndex != -1)
        {
            m_leftover = block.mid(lastSpaceIndex + 1); // Сохраняем остаток для следующего блока
            block = block.left(lastSpaceIndex); // Текущий блок до последнего пробела
        }
        else
        {
            m_leftover = block;
            continue;
        }

        words.append(QString::fromUtf8(block).split(regExp, Qt::SkipEmptyParts));

        m_currentOffset+=m_buffSize;
    }

    if (m_file.atEnd())
    {
        setNewState(States::READING_ENDED);
    }

    QHash<QString, quint32> resultHash;
    for (auto & word: words)
    {
        ++resultHash[word];
    }

    qDebug() << "Current procent " << double(m_currentOffset)/m_file.size() * 100;
    qDebug() << "Bytes processed " << m_currentOffset << " of " <<  m_file.size();

    if (m_state == States::PAUSED)
    {
        emit scanPaused();
    }
    else
    {
        emit stopScan();
    }
}

void FileExplorer::setNewState(States newState)
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
    // m_file.reset();
    m_currentOffset = 0;
    m_leftover = {};
}
