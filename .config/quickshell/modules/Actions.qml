import QtQuick
import qs
import qs.services

// Settings gear, notification bell with unread badge, power button
Grid {
    // a row on a top/bottom bar, a column on a side bar
    columns: Theme.vertical ? 1 : 100
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter
    spacing: 0

    Chip {
        visible: Config.showSettingsButton
        implicitHeight: Theme.barItem
        radius: Theme.chipRadius
        padding: 9
        icon: Theme.icon(0xf0493)
        fg: Theme.textDim
        hoverFg: Theme.text
        hoverBg: Theme.surfaceHigh
        onLeftClicked: Panels.toggle("settings")
    }

    Item {
        width: bell.implicitWidth
        height: Theme.barItem

        Chip {
            id: bell
            implicitHeight: Theme.barItem
            radius: Theme.chipRadius
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
        visible: Config.barPowerButton
        implicitHeight: Theme.barItem
        radius: Theme.chipRadius
        padding: 9
        icon: Theme.icon(0xf0425)
        fg: Theme.error
        hoverBg: Theme.error
        hoverFg: Theme.errorFg
        onLeftClicked: Panels.toggle("power")
    }
}
