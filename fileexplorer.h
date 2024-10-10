#ifndef FILEEXPLORER_H
#define FILEEXPLORER_H

#include <QObject>
#include <QFile>
#include <QByteArray>

#include "enums.h"
#include "datamodel.h"

class FileExplorer : public QObject
{
    Q_OBJECT
public:
    explicit FileExplorer(DataModel &dataModel ,QObject *parent = nullptr);

    /*!
     * \brief File openning
     * \param path to file
     * \return return size of opened file or -1, if failed to open file
     */
    qint64 openFile(const QString &fileName);

    void startScan();

    void pauseScan();

    void stopScan();

signals:
    void stateChanged(FileExplorerEnums::States);

    void scanStarted();
    void scanPaused();
    void scanStopped();

    void updateProgressStatusSignal(double progress);

private:
    void startScanFile();

    void setNewState(FileExplorerEnums::States newState);

    void reset();

    void updateProgressStatus();

    FileExplorerEnums::States m_state = FileExplorerEnums::States::IDLE;
    QFile m_file;
    qint64 m_currentOffset = 0;
    QByteArray m_leftover = {};
    qint64 m_buffSize = 1024;

    DataModel &m_dataModel;
};

#endif // FILEEXPLORER_H
