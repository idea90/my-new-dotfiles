import QtQuick
import Quickshell
import qs

// Icon buttons that launch things; edit Config.barShortcuts to change them
Grid {
    // a row on a top/bottom bar, a column on a side bar
    columns: Theme.vertical ? 1 : 100
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter
    spacing: 0

    Repeater {
        model: Config.barShortcuts

        Chip {
            required property var modelData
            implicitHeight: 30
            radius: Theme.chipRadius
            padding: 9
            icon: Theme.icon(modelData.icon)
            fg: Theme.textDim
            hoverFg: Theme.text
            hoverBg: Theme.surfaceHigh
            onLeftClicked: Quickshell.execDetached(["sh", "-c", modelData.cmd])
        }
    }
}
