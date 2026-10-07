//@ pragma UseQApplication
// Quickshell entry point: the whole desktop shell.
// UseQApplication (above) is needed for tray icons' right-click menus.
// Edits hot-reload; restart with `qs` if something gets stuck.
import QtQuick
import Quickshell
import qs.battery
import qs.bluetooth
import qs.calendar
import qs.clipboard
import qs.controlcenter
import qs.desktop
import qs.dock
import qs.emoji
import qs.goodbye
import qs.island
import qs.launcher
import qs.lock
import qs.mixer
import qs.notifications
import qs.osd
import qs.overview
import qs.powermenu
import qs.settings
import qs.shot
import qs.switcher
import qs.theme
import qs.welcome
import qs.wifi

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    // Desktop widgets (Config.widgetsEnabled)
    Variants {
        model: Quickshell.screens

        DesktopWidgets {}
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
    BatteryPanel {}
    ClipboardMenu {}
    EmojiPicker {}
    Overview {}
    Welcome {}
    BluetoothMenu {}
    GoodbyeScreen {}
    ShotWindow {}
    SwitcherWindow {}
    ShotPreview {}
}
