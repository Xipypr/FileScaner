import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Worker Thread Example"

    Row {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0

        Column {
            id: controlPanel
            width: row.width * 0.2
            height: row.height
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
                height: row.height / 8 - row.height * 0.01 * 3
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
            width: row.width - controlPanel.width - stats.width
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

        Column {
            id: stats
            width: row.width * 0.2
            height: row.height
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

        function onFileOpened(value) {
            console.log("File opened with size " + value)
            row.state = "ReadyToStart";
        }

        function onScanStarted() {
            console.log("Starting scan")
            row.state = "ScanInProgress";
        }

        function onScanPaused() {
            console.log("Paused scan")
            row.state = "ScanPaused";
        }


        //TODO error handling
        function onScanStopped() {
            console.log("Scan stopped")
            row.state = "ScanStopped";
        }

        function onUpdateProgressStatusSignal(value) {
            progressBar.value = value
        }

        function onFileExplorerStateChanged(value) {
            console.log("State changed " + value)
            // console.log("State check" + FileExplorerEnums.IDLE)
        }
    }
}
