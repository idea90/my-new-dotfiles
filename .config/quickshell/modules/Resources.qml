import QtQuick
import qs
import qs.services

// CPU and memory as labelled slim bars
Row {
    spacing: 14

    Row {
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter
        BarText {
            text: "CPU"
            font.pixelSize: 12
            color: Theme.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
        MiniBar {
            anchors.verticalCenter: parent.verticalCenter
            value: Sys.cpu / 100
            fill: Sys.cpu >= 90 ? Theme.error : Sys.cpu >= 70 ? Theme.tertiary : Theme.primary
        }
    }
    Row {
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter
        BarText {
            text: "MEM"
            font.pixelSize: 12
            color: Theme.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
        MiniBar {
            anchors.verticalCenter: parent.verticalCenter
            value: Sys.memory / 100
            fill: Sys.memory >= 90 ? Theme.error : Sys.memory >= 75 ? Theme.tertiary : Theme.primary
        }
    }
}
