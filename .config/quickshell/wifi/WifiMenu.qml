import QtQuick
import qs
import qs.modules
import qs.services

// Click the bar's Wi-Fi item, right-click the control center's Wi-Fi tile,
// or `qs ipc call wifi toggle`
OverlayWindow {
    open: Panels.open === "wifi"
    dim: false
    onDismissed: Panels.close()

    WifiContent {
        x: parent.width - width - 12 - Theme.barSpaceRight
        y: Theme.panelY(height, parent.height)
    }
}
