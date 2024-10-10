import QtQuick 2.15
import QtQuick.Controls 2.15

import equipment.structs
import equipment.enums

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "2GisTest"

    Rectangle {
        id: mainParent
        color: "#00ffffff"
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0

        Column {
            id: controlPanel
            width: mainParent.width * 0.2
            height: mainParent.height
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.topMargin: 0
            topPadding: controlPanel.height / 4 - controlPanel.height * 0.01 * 3
            spacing: controlPanel.height * 0.01


            Button {
                id: openFileBtn
                width: controlPanel.width
                height: controlPanel.height / 8 - controlPanel.height * 0.01 * 3
                text: qsTr("Open File")
                font.pixelSize: openFileBtn.icon.width
                onClicked: controller.openFile("E://Words.txt")
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

        Row {
            id: gisto
            x: controlPanel.width
            width: mainParent.width - controlPanel.width - stats.width
            height: 400
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 100
            anchors.bottomMargin: 100

            Repeater {
                id: gistoRepeater
                model: ListModel {
                    ListElement {
                        name: "Red"
                        value: 200
                        colorCode: "#b3d68d"
                    }

                    ListElement {
                        name: "Red"
                        value: 200
                        colorCode: "#b3d68d"
                    }

                    ListElement {
                        name: "Red"
                        value: 200
                        colorCode: "#b3d68d"
                    }
                }

                delegate: Column {
                    spacing: 5
                    Rectangle {
                        width: gisto.width/15
                        height: value
                        color: colorCode
                    }
                }
            }
        }

        Rectangle {
            id: stats
            width: mainParent.width * 0.2
            height: mainParent.height
            color: "#00ffffff"
            anchors.right: parent.right
            anchors.top: parent.top

            ProgressBar {
                id: progressBar
                width: stats.width
                height: stats.height * 0.10
                value: 65
                anchors.bottom: parent.bottom
                indeterminate: false
                rightInset: 0
                leftInset: 0
                bottomInset: 0
                topInset: 0
                transformOrigin: Item.Bottom
                to: 100
            }

            ListView {
                id: listView
                width: stats.width
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: progressBar.top
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                model: ListModel {
                    ListElement {
                        name: "Red"
                        colorCode: "red"
                    }

                    ListElement {
                        name: "Green"
                        colorCode: "green"
                    }
                }
                delegate: Row {
                    spacing: 5
                    Rectangle {
                        width: 100
                        height: 20
                        color: colorCode
                    }

                    Text {
                        width: 100
                        text: name
                    }
                }
            }
        }

        // Определение состояний
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
        }

        function onFileExplorerStateChanged(value) {
            switch (value)
            {
            case FileExplorerEnums.IDLE:
                mainParent.state = "ReadyToStart";
                break
            case FileExplorerEnums.READY_TO_START:
                mainParent.state = "ReadyToStart";
                break
            case FileExplorerEnums.RUNNIG:
                mainParent.state = "ScanInProgress";
                break
            case FileExplorerEnums.PAUSED:
                mainParent.state = "ScanPaused";
                break
            case FileExplorerEnums.STOPPED:
                mainParent.state = "ScanStopped";
                break
            case FileExplorerEnums.READING_ENDED:
                mainParent.state = "ScanStopped";
                break
            default:
                break
            }
        }

        function onUpdateWordsRating (list) {
            console.log("list legth " + list.length);
            for (var i = 0; i < list.length; i++) {
                console.log(list[i].word + ": " + list[i].frequency);
            }
        }
    }
}
