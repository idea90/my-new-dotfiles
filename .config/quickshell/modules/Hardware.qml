import QtQuick
import Quickshell
import qs
import qs.services

// CPU always; memory and temperature slide out on hover. Click: btop.
Pill {
    id: pill

    property bool expanded: hover.hovered

    HoverHandler {
        id: hover
    }

    Chip {
        icon: Theme.icon(0xf0ee0)
        label: Sys.cpu + "%"
        fg: Sys.cpu >= 90 ? Theme.error : Sys.cpu >= 70 ? Theme.tertiary : Theme.text
        onLeftClicked: Quickshell.execDetached(["alacritty", "-e", "btop"])
    }
    Chip {
        visible: pill.expanded
        icon: Theme.icon(0xf035b)
        label: Sys.memory + "%"
        fg: Sys.memory >= 90 ? Theme.error : Sys.memory >= 75 ? Theme.tertiary : Theme.text
    }
    Chip {
        visible: pill.expanded && Sys.temperature >= 0
        icon: Theme.icon(0xf050f)
        label: Sys.temperature + "°C"
        fg: Sys.temperature >= 85 ? Theme.error : Theme.text
    }
}
