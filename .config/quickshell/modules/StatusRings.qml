import QtQuick
import Quickshell
import qs
import qs.services

// CPU, volume, brightness and battery as rings (hover for the number)
Grid {
    // a row on a top/bottom bar, a column on a side bar
    columns: Theme.vertical ? 1 : 100
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter
    spacing: 0

    Ring {
        value: Sys.cpu / 100
        icon: Theme.icon(0xf0ee0)
        shortName: "CPU"
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
        onLeftClicked: Panels.toggle("mixer")
        onRightClicked: Audio.toggleMute()
        onScrolled: step => Audio.change(step * 0.02)
        shortName: "VOL"
        settable: true
        onMoved: v => Audio.setVolume(v)
    }

    Ring {
        visible: Brightness.available
        value: Brightness.percent / 100
        icon: Theme.icon(0xf00df)
        shortName: "BRI"
        settable: true
        onMoved: v => Brightness.set(v)
        onScrolled: step => Brightness.change(step)
    }

    Ring {
        id: battery
        visible: Battery.available
        readonly property bool low: !Battery.charging && Battery.percent <= 30
        readonly property bool critical: !Battery.charging && Battery.percent <= 15

        value: Battery.percent / 100
        shortName: "BAT"
        onLeftClicked: Panels.toggle("battery")
        icon: Battery.charging ? Theme.icon(0xf0084) : Theme.icon(0xf0079)
        label: Battery.percent + "%"
        color: low ? Theme.error : Battery.charging ? Theme.tertiary : Theme.primary
        iconColor: low ? Theme.error : Theme.text

        SequentialAnimation on opacity {
            running: battery.critical && !Config.lowEnd
            loops: Animation.Infinite
            onRunningChanged: if (!running) battery.opacity = 1
            NumberAnimation { to: 0.5; duration: Theme.dur(750) }
            NumberAnimation { to: 1; duration: Theme.dur(750) }
        }
    }
}
