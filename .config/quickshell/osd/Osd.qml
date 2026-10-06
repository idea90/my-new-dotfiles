import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Bottom-center pop-up on volume / brightness keys
PanelWindow {
    visible: Osd.shown
    color: "transparent"
    anchors.bottom: Config.osdPosition !== "top"
    anchors.top: Config.osdPosition === "top"
    margins.bottom: Config.osdMargin
    margins.top: Config.osdMargin
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"

    OsdContent {
        id: content
        anchors.fill: parent
    }
}
