import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Floating bar: 8px from the top, 12px from the sides (matches Hyprland gaps_out)
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors {
        top: Config.barPosition !== "bottom"
        bottom: Config.barPosition === "bottom"
        left: true
        right: true
    }
    margins {
        top: Config.barPosition === "bottom" ? 0 : Config.barMarginTop
        bottom: Config.barPosition === "bottom" ? Config.barMarginTop : 0
        left: Config.barMarginSide
        right: Config.barMarginSide
    }

    implicitHeight: Config.barHeight
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
