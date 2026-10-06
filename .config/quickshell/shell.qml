//@ pragma UseQApplication
// Quickshell entry point: the whole desktop shell.
// UseQApplication (above) is needed for tray icons' right-click menus.
// Edits hot-reload; restart with `qs` if something gets stuck.
import QtQuick
import Quickshell
import qs.calendar
import qs.controlcenter
import qs.launcher
import qs.lock
import qs.notifications
import qs.osd
import qs.powermenu
import qs.settings
import qs.shot
import qs.theme
import qs.wifi

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    LauncherWindow {}
    CalendarPanel {}
    NotificationPopups {}
    ControlCenter {}
    Osd {}
    PowerMenu {}
    ThemeMenu {}
    WifiMenu {}
    SettingsWindow {}
    LockScreen {}
    ShotWindow {}
    ShotPreview {}
}
