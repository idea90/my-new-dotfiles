import QtQuick
import qs.modules
import qs.services

// Super+W (`qs ipc call theme toggle`)
OverlayWindow {
    open: Panels.open === "theme"
    onDismissed: Panels.close()

    ThemeContent {
        anchors.centerIn: parent
        width: Math.min(1120, parent.width - 48)
        height: Math.min(600, parent.height - 120)
    }
}
