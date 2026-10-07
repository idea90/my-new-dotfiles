import QtQuick
import qs
import qs.modules
import qs.services

// Opened from the Sound tile (right-click), the bar's volume ring, or `qs ipc call mixer toggle`
OverlayWindow {
    open: Panels.open === "mixer"
    dim: false
    onDismissed: Panels.close()

    MixerContent {
        x: parent.width - width - 12 - Theme.barSpaceRight
        y: Theme.barSpaceTop + 8
    }
}
