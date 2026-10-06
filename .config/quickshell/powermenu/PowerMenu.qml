import QtQuick
import qs.modules
import qs.services

// Super+Escape or the bar's power button (`qs ipc call power toggle`)
OverlayWindow {
    open: Panels.open === "power"
    onDismissed: Panels.close()

    PowerMenuContent {
        anchors.fill: parent
    }
}
