import QtQuick
import qs
import qs.services

// Notification bell with unread badge, power button
Row {
    spacing: 0

    Item {
        width: bell.implicitWidth
        height: 30

        Chip {
            id: bell
            implicitHeight: 30
            radius: 15
            padding: 9
            icon: Notifs.dnd ? Theme.icon(0xf009b) : Theme.icon(0xf009a)
            fg: Notifs.dnd ? Theme.alpha(Theme.text, 0.45) : Theme.text
            hoverBg: Theme.surfaceHigh
            onLeftClicked: Notifs.togglePanel()
            onRightClicked: Notifs.toggleDnd()
        }

        // Unread count
        Rectangle {
            visible: Notifs.count > 0 && !Notifs.dnd
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 1
                rightMargin: 2
            }
            width: Math.max(15, badge.implicitWidth + 7)
            height: 15
            radius: 8
            color: Theme.primary

            BarText {
                id: badge
                anchors.centerIn: parent
                text: Notifs.count > 9 ? "9+" : Notifs.count
                color: Theme.primaryFg
                font.pixelSize: 9
                font.bold: true
            }
        }
    }

    Chip {
        implicitHeight: 30
        radius: 15
        padding: 9
        icon: Theme.icon(0xf0425)
        fg: Theme.error
        hoverBg: Theme.error
        hoverFg: Theme.errorFg
        onLeftClicked: Panels.toggle("power")
    }
}
