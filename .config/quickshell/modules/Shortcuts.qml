import QtQuick
import Quickshell
import qs

// Icon buttons that launch things; edit Config.barShortcuts to change them
Row {
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
