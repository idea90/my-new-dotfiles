import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Bottom-center pop-up on volume / brightness keys
PanelWindow {
    visible: Osd.shown
    color: "transparent"
    anchors.bottom: true
    margins.bottom: 80
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
