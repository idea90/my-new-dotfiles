import QtQuick
import Quickshell
import qs
import qs.services

// Idle inhibitor, notification bell, power menu
Pill {
    Chip {
        padding: 9
        icon: Idle.inhibited ? Theme.icon(0xf0208) : Theme.icon(0xf0209)
        fg: Idle.inhibited ? Theme.tertiaryContainerFg : Theme.text
        bg: Idle.inhibited ? Theme.tertiaryContainer : "transparent"
        onLeftClicked: Idle.toggle()
    }

    Chip {
        padding: 9
        icon: Notifs.dnd ? Theme.icon(0xf009b) : Notifs.count > 0 ? Theme.icon(0xf116b) : Theme.icon(0xf009a)
        fg: Notifs.dnd ? Theme.alpha(Theme.text, 0.45) : Notifs.count > 0 ? Theme.primary : Theme.text
        onLeftClicked: Notifs.togglePanel()
        onRightClicked: Notifs.toggleDnd()
    }

    Chip {
        padding: 9
        icon: Theme.icon(0xf0425)
        fg: Theme.error
        hoverBg: Theme.error
        hoverFg: Theme.errorFg
        onLeftClicked: Quickshell.execDetached(["sh", "-c", "~/.config/wlogout/launch.sh"])
    }
}
