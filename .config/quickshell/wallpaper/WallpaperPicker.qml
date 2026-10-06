import QtQuick
import qs.modules
import qs.services

// Super+W (`qs ipc call wallpaper toggle`)
OverlayWindow {
    open: Panels.open === "wallpaper"
    onDismissed: Panels.close()

    WallpaperContent {
        anchors.centerIn: parent
        width: Math.min(1120, parent.width - 48)
        height: Math.min(600, parent.height - 120)
    }
}
