import QtQuick
import qs.modules
import qs.services

// Opened from the control center's Settings tile or `qs ipc call settings toggle`
OverlayWindow {
    open: Panels.open === "settings"
    onDismissed: Panels.close()

    SettingsContent {
        anchors.centerIn: parent
    }
}
