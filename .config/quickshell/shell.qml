// Quickshell entry point: the whole desktop shell.
// Edits hot-reload; restart with `qs` if something gets stuck.
import QtQuick
import Quickshell
import qs.controlcenter
import qs.launcher
import qs.notifications
import qs.osd
import qs.powermenu
import qs.wallpaper
import qs.wifi

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    LauncherWindow {}
    NotificationPopups {}
    ControlCenter {}
    Osd {}
    PowerMenu {}
    WallpaperPicker {}
    WifiMenu {}
}
