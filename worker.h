#ifndef WORKER_H
#define WORKER_H

#include <QObject>

#include "enums.h"
#include "fileexplorer.h"
#include "datamodel.h"

class Worker : public QObject
{
    Q_OBJECT
public:
    explicit Worker(QObject *parent = nullptr);

public slots:
    void openFile(const QString &fileName);

    void startScan();

    void pauseScan();

    void stopScan();

    void updateWordRatings();

signals:
    void dataChanged(int);

    void fileOpened(qint64);

    void fileExplorerStateChanged(FileExplorerEnums::States);

    void updateProgressStatusSignal(double);

    void updateWordsRating(QList<WordFrequency>);

private:
    DataModel m_data;
    FileExplorer m_fileExplorer;
};

#endif // WORKER_H
