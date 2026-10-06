import QtQuick
import Quickshell
import qs
import qs.services

// Network, volume, brightness and battery share one pill
Pill {
    Chip {
        readonly property var wifiIcons: [0xf091f, 0xf0922, 0xf0925, 0xf0928]

        icon: Network.kind === "wifi" ? Theme.icon(wifiIcons[Math.min(3, Math.floor(Network.signal / 25))])
            : Network.kind === "ethernet" ? Theme.icon(0xf0200)
            : Theme.icon(0xf092e)
        label: Network.kind === "wifi" ? (Network.name.length > 16 ? Network.name.slice(0, 15) + "…" : Network.name)
             : Network.kind === "ethernet" ? "wired"
             : "offline"
        fg: Network.kind === "none" ? Theme.alpha(Theme.text, 0.45) : Theme.text
        onLeftClicked: Panels.toggle("wifi")
        onRightClicked: Quickshell.execDetached(["nm-connection-editor"])
    }

    Chip {
        visible: Audio.ready
        icon: Audio.muted ? Theme.icon(0xf075f)
            : Audio.volume < 0.34 ? Theme.icon(0xf057f)
            : Audio.volume < 0.67 ? Theme.icon(0xf0580)
            : Theme.icon(0xf057e)
        label: Audio.muted ? "muted" : Math.round(Audio.volume * 100) + "%"
        fg: Audio.muted ? Theme.alpha(Theme.text, 0.45) : Theme.text
        onLeftClicked: Quickshell.execDetached(["pavucontrol"])
        onRightClicked: Audio.toggleMute()
        onScrolled: step => Audio.change(step * 0.02)
    }

    Chip {
        visible: Brightness.available
        icon: Brightness.percent < 34 ? Theme.icon(0xf00de)
            : Brightness.percent < 67 ? Theme.icon(0xf00df)
            : Theme.icon(0xf00e0)
        label: Brightness.percent + "%"
        onScrolled: step => Brightness.change(step)
    }

    Chip {
        id: battery
        visible: Battery.available
        readonly property bool low: !Battery.charging && Battery.percent <= 30
        readonly property bool critical: !Battery.charging && Battery.percent <= 15

        icon: Battery.charging ? Theme.icon(0xf0084)
            : Theme.icon(0xf007a + Math.min(8, Math.floor(Battery.percent / 11)))
        label: Battery.percent + "%"
        fg: critical ? Theme.errorFg : low ? Theme.errorContainerFg : Battery.charging ? Theme.tertiary : Theme.text
        bg: critical ? Theme.error : low ? Theme.errorContainer : "transparent"

        SequentialAnimation on opacity {
            running: battery.critical
            loops: Animation.Infinite
            onRunningChanged: if (!running) battery.opacity = 1
            NumberAnimation { to: 0.55; duration: 750 }
            NumberAnimation { to: 1; duration: 750 }
        }
    }
}
