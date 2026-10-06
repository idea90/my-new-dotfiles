import QtQuick
import Quickshell
import qs
import qs.services

// CPU, volume, brightness and battery as rings (hover for the number), then Wi-Fi
Row {
    spacing: 0

    Ring {
        value: Sys.cpu / 100
        icon: Theme.icon(0xf0ee0)
        hoverDetails: false
        color: Sys.cpu >= 90 ? Theme.error : Sys.cpu >= 70 ? Theme.tertiary : Theme.primary
        onLeftClicked: Quickshell.execDetached(["alacritty", "-e", "btop"])
    }

    Ring {
        visible: Audio.ready
        value: Audio.muted ? 0 : Audio.volume
        icon: Audio.muted ? Theme.icon(0xf075f) : Theme.icon(0xf057e)
        iconColor: Audio.muted ? Theme.alpha(Theme.text, 0.45) : Theme.text
        label: Audio.muted ? "muted" : Math.round(Audio.volume * 100) + "%"
        color: Audio.volume > 1 ? Theme.error : Theme.primary
        onLeftClicked: Quickshell.execDetached(["pavucontrol"])
        onRightClicked: Audio.toggleMute()
        onScrolled: step => Audio.change(step * 0.02)
    }

    Ring {
        visible: Brightness.available
        value: Brightness.percent / 100
        icon: Theme.icon(0xf00df)
        onScrolled: step => Brightness.change(step)
    }

    Ring {
        id: battery
        visible: Battery.available
        readonly property bool low: !Battery.charging && Battery.percent <= 30
        readonly property bool critical: !Battery.charging && Battery.percent <= 15

        value: Battery.percent / 100
        icon: Battery.charging ? Theme.icon(0xf0084) : Theme.icon(0xf0079)
        label: Battery.percent + "%" + (Battery.charging ? " charging" : "")
        color: low ? Theme.error : Battery.charging ? Theme.tertiary : Theme.primary
        iconColor: low ? Theme.error : Theme.text

        SequentialAnimation on opacity {
            running: battery.critical
            loops: Animation.Infinite
            onRunningChanged: if (!running) battery.opacity = 1
            NumberAnimation { to: 0.5; duration: Theme.dur(750) }
            NumberAnimation { to: 1; duration: Theme.dur(750) }
        }
    }

    Chip {
        readonly property var wifiIcons: [0xf091f, 0xf0922, 0xf0925, 0xf0928]

        implicitHeight: 30
        radius: 15
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
}
