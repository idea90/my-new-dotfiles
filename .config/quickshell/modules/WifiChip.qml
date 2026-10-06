import QtQuick
import Quickshell
import qs
import qs.services

// Current network: click for the Wi-Fi menu, right-click for the connection editor
Chip {
    readonly property var wifiIcons: [0xf091f, 0xf0922, 0xf0925, 0xf0928]

    implicitHeight: Theme.barItem
    fontFamily: Theme.barFont
    radius: Theme.chipRadius
    icon: Network.kind === "wifi" ? Theme.icon(wifiIcons[Math.min(3, Math.floor(Network.signal / 25))])
        : Network.kind === "ethernet" ? Theme.icon(0xf0200)
        : Theme.icon(0xf092e)
    label: Network.kind === "wifi" ? (Network.name.length > 14 ? Network.name.slice(0, 13) + "…" : Network.name)
         : Network.kind === "ethernet" ? "wired" : "offline"
    fg: Network.kind === "none" ? Theme.alpha(Theme.text, 0.45) : Theme.text
    hoverBg: Theme.surfaceHigh
    onLeftClicked: Panels.toggle("wifi")
    onRightClicked: Quickshell.execDetached(["nm-connection-editor"])
}
