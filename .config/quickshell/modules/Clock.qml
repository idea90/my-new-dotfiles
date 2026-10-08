import QtQuick
import qs
import qs.services

// Time and date; click for the calendar
Rectangle {
    readonly property bool win: Config.barClockFormat === "win"
    implicitWidth: Theme.vertical ? Theme.barItem : win ? winCol.implicitWidth + 20 : row.implicitWidth + 28
    implicitHeight: Theme.vertical ? stack.implicitHeight + 14 : Theme.barItem
    radius: Theme.chipRadius
    color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainer : "transparent"

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    // Side bar: hours over minutes, centered
    Column {
        id: stack
        visible: Theme.vertical
        anchors.centerIn: parent
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(Time.now, Config.clock24h ? "HH" : "h")
            font.pixelSize: 15
            font.bold: true
            color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainerFg : Theme.text
        }
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(Time.now, "mm")
            font.pixelSize: 15
            font.bold: true
            color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainerFg : Theme.primary
        }
    }

    // "win": time over date, right aligned, like the Windows taskbar
    Column {
        id: winCol
        visible: win && !Theme.vertical
        anchors.centerIn: parent
        spacing: 0
        BarText {
            anchors.right: parent.right
            text: Qt.formatDateTime(Time.now, Config.clock24h ? "HH:mm" : "h:mm AP")
            font.pixelSize: Math.round(12 * Theme.barScale)
            font.family: Theme.barFont
        }
        BarText {
            anchors.right: parent.right
            text: Qt.formatDateTime(Time.now, "M/d/yyyy")
            font.pixelSize: Math.round(12 * Theme.barScale)
            font.family: Theme.barFont
        }
    }

    Row {
        id: row
        visible: !Theme.vertical && !win
        anchors.centerIn: parent
        spacing: 10

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            // Qt only uses 12-hour time when AP is in the same format string
            visible: Config.barClockFormat !== "date"
            text: Config.clock24h
                ? Qt.formatDateTime(Time.now, Config.clockSeconds ? "HH:mm:ss" : "HH:mm")
                : Qt.formatDateTime(Time.now, Config.clockSeconds ? "h:mm:ss AP" : "h:mm AP").replace(/\s*[AP]M$/i, "")
            font.pixelSize: Math.round(16 * Math.min(1.25, Math.max(0.8, Theme.barScale)))
            font.bold: true
            font.family: Theme.barFont
            color: mouse.containsMouse || Panels.open === "calendar" ? Theme.primaryContainerFg : Theme.text
        }
        BarText {
            anchors.verticalCenter: parent.verticalCenter
            visible: Config.barClockFormat !== "time"
            font.family: Theme.barFont
            text: Config.barClockFormat === "date" ? Qt.formatDateTime(Time.now, "dddd d MMMM")
                : Config.clockCompact ? "•  " + Qt.formatDateTime(Time.now, "ddd d MMM")
                : Qt.formatDateTime(Time.now, Config.clock24h ? "ddd d MMM" : "AP · ddd d MMM")
            font.pixelSize: Math.round(12 * Math.min(1.2, Math.max(0.85, Theme.barScale)))
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
