import QtQuick
import qs
import qs.services

// Time and date; click for the calendar
Rectangle {
    implicitWidth: row.implicitWidth + 28
    implicitHeight: 30
    radius: 15
    color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainer : "transparent"

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            // Qt only uses 12-hour time when AP is in the same format string
            text: Qt.formatDateTime(Time.now, "h:mm AP").replace(/\s*[AP]M$/i, "")
            font.pixelSize: 16
            font.bold: true
            color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainerFg : Theme.text
        }
        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(Time.now, "AP · ddd d MMM")
            font.pixelSize: 12
            color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainerFg : Theme.textDim
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Panels.toggle("calendar")
    }
}
