import QtQuick
import qs
import qs.services

// Time and date; click for the calendar
Rectangle {
    implicitWidth: row.implicitWidth + 28
    implicitHeight: 30
    radius: Theme.chipRadius
    color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainer : "transparent"

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            // Qt only uses 12-hour time when AP is in the same format string
            text: Config.clock24h
                ? Qt.formatDateTime(Time.now, Config.clockSeconds ? "HH:mm:ss" : "HH:mm")
                : Qt.formatDateTime(Time.now, Config.clockSeconds ? "h:mm:ss AP" : "h:mm AP").replace(/\s*[AP]M$/i, "")
            font.pixelSize: 16
            font.bold: true
            color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainerFg : Theme.text
        }
        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Config.clockCompact ? "•  " + Qt.formatDateTime(Time.now, "ddd d MMM")
                : Qt.formatDateTime(Time.now, Config.clock24h ? "ddd d MMM" : "AP · ddd d MMM")
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
