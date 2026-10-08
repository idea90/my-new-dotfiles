import QtQuick
import qs
import qs.modules
import qs.services

// Click the clock (`qs ipc call calendar toggle`)
OverlayWindow {
    open: Panels.open === "calendar"
    dim: false
    onDismissed: Panels.close()

    CalendarContent {
        // Under the clock normally; above the taskbar, at the right, like Windows
        x: Theme.panelsBottom ? parent.width - width - 10 - Theme.barSpaceRight : (parent.width - width) / 2
        y: Theme.panelY(height, parent.height)
    }
}
