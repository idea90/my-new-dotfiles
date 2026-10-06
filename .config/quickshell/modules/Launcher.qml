import QtQuick
import Quickshell
import qs
import qs.services

// Left click: apps. Right click: wallpapers.
Chip {
    icon: Theme.icon(0xf303)   // Arch logo
    implicitHeight: Theme.barItem
    padding: 10
    radius: Theme.chipRadius
    fg: Config.launcherPlain ? Theme.primary : Theme.primaryFg
    bg: Config.launcherPlain ? "transparent" : Theme.primary
    hoverBg: Config.launcherPlain ? Theme.surfaceHigh : Theme.alpha(Theme.primary, 0.85)
    onLeftClicked: AppMenu.toggle()
    onRightClicked: Panels.toggle("theme")
}
