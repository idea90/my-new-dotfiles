import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Full-screen overlay holding the launcher card; click outside to close
PanelWindow {
    visible: AppMenu.open
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    // qs-powermenu: Hyprland blurs the whole screen behind it (see hyprland.lua)
    WlrLayershell.namespace: Config.launcherBlurBackdrop || Config.launcherFullscreen ? "qs-powermenu" : "qs-launcher"

    LauncherContent {
        anchors.fill: parent
        entries: DesktopEntries.applications.values
    }
}
