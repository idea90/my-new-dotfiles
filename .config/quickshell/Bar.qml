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

    readonly property string edge: Config.barPosition   // top | bottom | left | right
    readonly property bool vertical: edge === "left" || edge === "right"
    readonly property int endGapMax: Math.max(8, (modelData.height - 420) / 2)

    anchors {
        top: edge !== "bottom"
        bottom: edge !== "top"
        left: edge !== "right"
        right: edge !== "left"
    }
    // barMarginTop is the gap to the screen edge the bar sits on, barMarginSide the gap at its ends
    margins {
        // On a side bar the end gaps are capped so short "capsule" styles still fit their contents
        top: edge === "top" ? Config.barMarginTop : vertical ? Math.min(Config.barMarginSide, endGapMax) : 0
        bottom: edge === "bottom" ? Config.barMarginTop : vertical ? Math.min(Config.barMarginSide, endGapMax) : 0
        left: edge === "left" ? Config.barMarginTop : vertical ? 0 : Config.barMarginSide
        right: edge === "right" ? Config.barMarginTop : vertical ? 0 : Config.barMarginSide
    }

    implicitHeight: vertical ? 0 : Config.barHeight
    implicitWidth: vertical ? Config.barHeight : 0
    visible: Config.barMode === "bar"
    color: "transparent"
    WlrLayershell.namespace: "qs-bar"

    // Idle lock off while the eye toggle is on
    IdleInhibitor {
        window: bar
        enabled: Idle.inhibited
    }

    BarContent {
        anchors.fill: parent
    }
}
