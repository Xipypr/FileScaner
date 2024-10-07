#ifndef WORKER_H
#define WORKER_H

#include <QObject>

#include "fileexplorer.h"

class Worker : public QObject
{
    Q_OBJECT
public:
    explicit Worker(QObject *parent = nullptr);

public slots:
    void process();

    void openFile(const QString &fileName);

    void startScan();

    void pauseScan();

    void stopScan();

signals:
    void dataChanged(int value);
    void workFinished();

    void fileOpened(qint64 fileSize);
    void scanStarted();
    void scanPaused();
    void scanStopped();
private:
    FileExplorer m_fileExplorer;
};

#endif // WORKER_H
