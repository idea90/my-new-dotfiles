//@ pragma UseQApplication
// Quickshell entry point: the whole desktop shell.
// UseQApplication (above) is needed for tray icons' right-click menus.
// Edits hot-reload; restart with `qs` if something gets stuck.
import QtQuick
import Quickshell
import qs.bluetooth
import qs.calendar
import qs.clipboard
import qs.controlcenter
import qs.dock
import qs.emoji
import qs.goodbye
import qs.island
import qs.launcher
import qs.lock
import qs.mixer
import qs.notifications
import qs.osd
import qs.powermenu
import qs.settings
import qs.shot
import qs.switcher
import qs.theme
import qs.wifi

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    // Dynamic island bar mode (Config.barMode)
    Variants {
        model: Quickshell.screens

        DynamicIsland {}
    }

    LauncherWindow {}
    Dock {}
    CalendarPanel {}
    NotificationPopups {}
    ControlCenter {}
    Osd {}
    PowerMenu {}
    ThemeMenu {}
    WifiMenu {}
    SettingsWindow {}
    LockScreen {}
    Mixer {}
    ClipboardMenu {}
    EmojiPicker {}
    BluetoothMenu {}
    GoodbyeScreen {}
    ShotWindow {}
    SwitcherWindow {}
    ShotPreview {}
}
