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

    // Space the bar takes at the top or bottom, so the panel never covers it
    readonly property int barTop: Theme.barSpaceTop
    readonly property int barBottom: Theme.barSpaceBottom

    ControlCenterContent {
        readonly property int topMargin: barTop + Config.ccTopMargin
        readonly property int bottomGap: barBottom + Config.ccBottomMargin
        // Full height, or just as tall as the content with ccFit
        height: Config.ccFit ? implicitHeight : parent.height - topMargin - bottomGap
        // Plain x/y (no left/right anchors): switching sides can't leave both set
        // and stretch the panel across the screen
        width: implicitWidth
        x: Config.ccSide === "left" ? Theme.barSpaceLeft + Config.ccSideMargin
         : Config.ccSide === "center" ? (parent.width - width) / 2
         : parent.width - width - Theme.barSpaceRight - Config.ccSideMargin
        y: Theme.panelsBottom && Config.ccFit ? parent.height - height - bottomGap
         : Config.ccSide === "center" && Config.ccFit ? Math.max(topMargin, (parent.height - height) / 3) : topMargin
    }
}
