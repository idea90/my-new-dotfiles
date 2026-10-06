import QtQuick
import qs.modules
import qs.services

// Click the bar's Wi-Fi item, right-click the control center's Wi-Fi tile,
// or `qs ipc call wifi toggle`
OverlayWindow {
    open: Panels.open === "wifi"
    dim: false
    onDismissed: Panels.close()

    WifiContent {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 54
            rightMargin: 12
        }
    }
}
