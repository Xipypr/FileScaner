#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>

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

//Signals to worker
signals:
    void openFileSignal(const QString &fileName);
    void startScanSignal();
    void pauseScanSignal();
    void stopScanSignal();


//Signals to qml
//Replace with State changed
signals:
    void fileOpened(qint64 fileSize);
    void scanStarted();
    void scanPaused();
    void scanStopped();
};

#endif // CONTROLLER_H
