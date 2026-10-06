import QtQuick
import Quickshell
import qs
import qs.services

// Left click: apps. Right click: wallpaper picker.
Chip {
    icon: Theme.icon(0xf303)   // Arch logo
    padding: 11
    radius: Theme.pillRadius
    fg: Theme.primaryFg
    bg: Theme.primary
    hoverBg: Theme.alpha(Theme.primary, 0.85)
    onLeftClicked: AppMenu.toggle()
    onRightClicked: Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/apply-wal"])
}
