import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Floating bar: 8px from the top, 12px from the sides (matches Hyprland gaps_out)
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 8
        left: 12
        right: 12
    }

    implicitHeight: 38
    color: "transparent"

    // Idle lock off while the eye toggle is on
    IdleInhibitor {
        window: bar
        enabled: Idle.inhibited
    }

    BarContent {
        anchors.fill: parent
    }
}
