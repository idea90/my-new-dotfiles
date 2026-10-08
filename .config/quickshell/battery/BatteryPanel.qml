import QtQuick
import qs
import qs.modules
import qs.services

OverlayWindow {
    open: Panels.open === "battery"
    dim: false
    onDismissed: Panels.close()

    BatteryContent {
        x: parent.width - width - 12 - Theme.barSpaceRight
        y: Theme.panelY(height, parent.height)
    }
}
