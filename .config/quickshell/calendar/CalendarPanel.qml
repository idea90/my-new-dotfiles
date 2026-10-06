import QtQuick
import qs.modules
import qs.services

// Click the clock (`qs ipc call calendar toggle`)
OverlayWindow {
    open: Panels.open === "calendar"
    dim: false
    onDismissed: Panels.close()

    CalendarContent {
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 54
        }
    }
}
