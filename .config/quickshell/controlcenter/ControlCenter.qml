import QtQuick
import qs.modules
import qs.services

// Opened by the bar's bell or `qs ipc call controlcenter toggle`
OverlayWindow {
    open: Panels.open === "controlcenter"
    dim: false
    grabKeyboard: true
    onDismissed: Panels.close()

    ControlCenterContent {
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            topMargin: 54      // below the bar
            rightMargin: 12
            bottomMargin: 12
        }
    }
}
