#ifndef CONTROLLER_H
#define CONTROLLER_H

#include "enums.h"
#include "structs.h"

#include <QObject>
#include <QTimer>

class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QObject *parent = nullptr);

public slots:
    void openFile(const QString &fileName){
        emit openFileSignal(fileName);
    }

    void startScan(){
        emit startScanSignal();
    }

    void pauseScan(){
        emit pauseScanSignal();
    }

    void stopScan(){
        emit stopScanSignal();
    }

    void updateWordRatings(){
        emit updateWordRatingsSignal();
    }

//Signals to worker
signals:
    void openFileSignal(const QString &fileName);
    void startScanSignal();
    void pauseScanSignal();
    void stopScanSignal();
    void updateWordRatingsSignal();


//Signals to qml
//Replace with State changed
signals:
    void fileExplorerStateChanged(FileExplorerEnums::States);

    void updateProgressStatusSignal(double progress);

    void fileOpened(qint64 fileSize);

    void updateWordsRating(QList<WordFrequency>);
};

#endif // CONTROLLER_H
