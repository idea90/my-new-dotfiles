import QtQuick
import qs
import qs.modules
import qs.services

// Opened by the bar's bell or `qs ipc call controlcenter toggle`
OverlayWindow {
    open: Panels.open === "controlcenter"
    dim: false
    grabKeyboard: true
    onDismissed: Panels.close()

    ControlCenterContent {
        // Full height, or just as tall as the content with ccFit
        height: Config.ccFit ? implicitHeight : parent.height - Config.ccTopMargin - Config.ccBottomMargin
        anchors {
            top: parent.top
            right: Config.ccSide === "left" ? undefined : parent.right
            left: Config.ccSide === "left" ? parent.left : undefined
            topMargin: Config.ccTopMargin
            rightMargin: Config.ccSideMargin
            leftMargin: Config.ccSideMargin
            bottomMargin: Config.ccBottomMargin
        }
    }
}
