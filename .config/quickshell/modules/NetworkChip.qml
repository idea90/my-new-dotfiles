import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.services

// Wi-Fi (name) and a Bluetooth toggle side by side
Row {
    spacing: 2

    WifiChip {}

    Chip {
        readonly property var adapter: Bluetooth.defaultAdapter
        visible: !!adapter
        implicitHeight: 30
        radius: Theme.chipRadius
        padding: 8
        icon: Theme.icon(adapter && adapter.enabled ? 0xf00af : 0xf00b2)
        fg: adapter && adapter.enabled ? Theme.text : Theme.alpha(Theme.text, 0.45)
        hoverBg: Theme.surfaceHigh
        onLeftClicked: if (adapter) adapter.enabled = !adapter.enabled
        onRightClicked: Quickshell.execDetached(["blueman-manager"])
    }
}
