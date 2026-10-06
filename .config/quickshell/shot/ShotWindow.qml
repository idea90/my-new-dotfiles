import QtQuick
import qs
import qs.modules
import qs.services

// Toolbar: `qs ipc call screenshot toggle` or the control center's Capture tile
OverlayWindow {
    open: Panels.open === "screenshot"
    dim: false
    onDismissed: Panels.close()

    ShotToolbar {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 60
        }
    }
}
