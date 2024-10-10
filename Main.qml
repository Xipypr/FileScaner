import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs

import equipment.structs
import equipment.enums

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "2GisTest"

    property string statusText: "Waiting for file"
    property string filePath: "E://Words.txt"

    Rectangle {
        id: mainParent
        anchors.fill: parent

        Column {
            id: controlPanel
            width: parent.width * 0.2
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: statusBar.top
            topPadding: controlPanel.height / 4 - controlPanel.height * 0.01 * 3
            spacing: controlPanel.height * 0.01

            FileDialog {
                id: fileDialog
                title: "Выберите файл"
                nameFilters: ["All files (*)"]

                onAccepted: {
                    statusText = "Current file is: " + filePath
                    filePath = fileDialog.currentFile
                    controller.openFile(filePath)
                }
                onRejected: {
                    console.log("Файл не был выбран")
                }
            }

            Button {
                id: openFileBtn
                width: controlPanel.width
                height: controlPanel.height / 8 - controlPanel.height * 0.01 * 3
                text: qsTr("Open File")
                font.pixelSize: openFileBtn.icon.width
                onClicked: fileDialog.open()
            }

            Button {
                id: startScanFileBtn
                width: controlPanel.width
                height: mainParent.height / 8 - mainParent.height * 0.01 * 3
                text: qsTr("Start Scan")
                font.pixelSize: startScanFileBtn.icon.width
                onClicked: controller.startScan()
            }

            Button {
                id: pauseScanBtn
                width: controlPanel.width
                height: controlPanel.height / 8 - controlPanel.height * 0.01 * 3
                text: qsTr("Pause scan")
                font.pixelSize: pauseScanBtn.icon.width
                onClicked: controller.pauseScan()
            }

            Button {
                id: stopScanBtn
                width: controlPanel.width
                height: controlPanel.height / 8 - controlPanel.height * 0.01 * 3
                text: qsTr("Stop")
                font.pixelSize: stopScanBtn.icon.width
                onClicked: controller.stopScan()
            }
        }

        Rectangle {
            id: gisto
            y: 0
            anchors.left: controlPanel.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: statusBar.top

            ListView {
                id: listView
                width: gisto.width
                anchors.fill: parent
                anchors.leftMargin: 5

                model: ListModel {
                    id: wordFrequencyModel
                }
                delegate: Row {
                    spacing: 20

                    Text {
                        id: delegateText
                        width: gisto.width*0.15
                        text: name
                    }

                    Rectangle {
                        width: (gisto.width - delegateText.width - gisto.width*0.1) * w
                        height: gisto.height / 15
                        color: colorPattern
                        Text {
                            width: 100
                            text: value
                            color: textColorPattern
                        }
                    }
                }
            }
        }

        Rectangle {
            id: statusBar
            y: 927
            height: parent.height / 10
            color: "#d3d3d3"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            ProgressBar {
                id: progressBar
                value: 0
                anchors.fill: parent
                to: 100

                Text {
                    anchors.centerIn: parent
                    text: statusText
                    color: "black"
                    font.bold: true
                }
            }
        }

        states: [
            State {
                name: "WaitingForFile"
                PropertyChanges {
                    target: openFileBtn
                    enabled: true
                }
                PropertyChanges {
                    target: startScanFileBtn
                    enabled: false
                }
                PropertyChanges {
                    target: pauseScanBtn
                    enabled: false
                }
                PropertyChanges {
                    target: stopScanBtn
                    enabled: false
                }
            },
            State {
                name: "ReadyToStart"
                PropertyChanges {
                    target: openFileBtn
                    enabled: true
                }
                PropertyChanges {
                    target: startScanFileBtn
                    enabled: true
                }
                PropertyChanges {
                    target: pauseScanBtn
                    enabled: false
                }
                PropertyChanges {
                    target: stopScanBtn
                    enabled: false
                }
            },
            State {
                name: "ScanInProgress"
                PropertyChanges {
                    target: openFileBtn
                    enabled: false
                }
                PropertyChanges {
                    target: startScanFileBtn
                    enabled: false
                }
                PropertyChanges {
                    target: pauseScanBtn
                    enabled: true
                    text: qsTr("Pause scan")
                }
                PropertyChanges {
                    target: stopScanBtn
                    enabled: true
                }
            },
            State {
                name: "ScanPaused"
                PropertyChanges {
                    target: openFileBtn
                    enabled: false
                }
                PropertyChanges {
                    target: startScanFileBtn
                    enabled: false
                }
                PropertyChanges {
                    target: pauseScanBtn
                    enabled: true
                    text: qsTr("Continue scan")
                }
                PropertyChanges {
                    target: stopScanBtn
                    enabled: true
                }
            },
            State {
                name: "ScanStopped"
                PropertyChanges {
                    target: openFileBtn
                    enabled: true
                }
                PropertyChanges {
                    target: startScanFileBtn
                    enabled: false
                }
                PropertyChanges {
                    target: pauseScanBtn
                    enabled: false
                }
                PropertyChanges {
                    target: stopScanBtn
                    enabled: false
                }
            }
        ]
        state: "WaitingForFile"
    }

    Connections {
        target: controller

        function onUpdateProgressStatusSignal(value) {
            progressBar.value = value

            //To process correctly start new file
            if (mainParent.state === "ReadyToStart")
            {
                return;
            }

            //Sometimes it overrides status bar
            if (mainParent.state !== "ScanPaused")
            {
                statusText = "Scan in progress " + Math.round(value) + " %"
            }
        }

        function onFileExplorerStateChanged(value) {
            switch (value)
            {
            case FileExplorerEnums.IDLE:
                mainParent.state = "ReadyToStart";
                updateTimer.running = false
                break
            case FileExplorerEnums.READY_TO_START:
                mainParent.state = "ReadyToStart";
                statusText = "File " + filePath + " loaded";
                updateTimer.running = false
                break
            case FileExplorerEnums.RUNNIG:
                mainParent.state = "ScanInProgress";
                statusText = "Scan in progress";
                updateTimer.running = true
                break
            case FileExplorerEnums.PAUSED:
                updateTimer.running = false
                mainParent.state = "ScanPaused";
                statusText = "Scan is paused";
                break
            case FileExplorerEnums.STOPPED:
                mainParent.state = "ScanStopped";
                statusText = "Scan is stopped";
                updateTimer.running = false
                break
            case FileExplorerEnums.READING_ENDED:
                mainParent.state = "ScanStopped";
                statusText = "Reached the end of file";
                updateTimer.running = false
                break
            default:
                break
            }
        }

        function onUpdateWordsRating (list) {
            wordFrequencyModel.clear()
            for (var i = 0; i < list.length; i++) {
                var w = Math.pow(list[i].frequency, 3)/Math.pow(list[0].frequency, 3)
                wordFrequencyModel.append({
                                              "name": list[i].word,
                                              "w": w,
                                              "colorPattern" : i % 2 === 0 ? "#5b3b8c" : "#b3d68d",
                                              "textColorPattern" : i % 2 === 0 ? "white" : "black",
                                              "value": list[i].frequency});
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 500
        running: false
        repeat: true
        onTriggered: {
            controller.updateWordRatings()
        }
    }
}
