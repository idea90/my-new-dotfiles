import QtQuick
import qs
import qs.modules
import qs.services

// Super+Escape or the bar's power button (`qs ipc call power toggle`)
OverlayWindow {
    open: Panels.open === "power"
    namespace: Config.powerBlur ? "qs-powermenu" : "qs-panel"
    onDismissed: Panels.close()

    PowerMenuContent {
        anchors.fill: parent
    }
}
