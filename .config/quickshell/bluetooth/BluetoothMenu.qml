import QtQuick
import qs
import qs.modules
import qs.services

// From the control center's Bluetooth tile (right-click) or `qs ipc call bluetooth toggle`
OverlayWindow {
    open: Panels.open === "bluetooth"
    dim: false
    onDismissed: {
        Panels.close();
    }

    BluetoothContent {
        x: parent.width - width - 12 - Theme.barSpaceRight
        y: Theme.panelY(height, parent.height)
    }
}
