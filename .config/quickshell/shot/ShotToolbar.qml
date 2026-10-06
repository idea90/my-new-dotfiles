import QtQuick
import QtQuick.Layouts
import qs
import qs.modules
import qs.services

Card {
    id: bar

    implicitWidth: row.implicitWidth + 28
    implicitHeight: 64

    component Group: Row {
        spacing: 4
    }
    component Pick: Chip {
        id: pick
        property string key
        property var current
        property var value
        property string name: ""
        label: name
        bg: current === value ? Theme.primary : Theme.surfaceHigh
        fg: current === value ? Theme.primaryFg : Theme.text
        hoverBg: current === value ? Theme.primary : Theme.surfaceHighest
        onLeftClicked: Config.set(key, value)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 14

        Group {
            Pick { key: "shotMode"; current: Config.shotMode; value: "area"; icon: Theme.icon(0xf0f28); name: "Area" }
            Pick { key: "shotMode"; current: Config.shotMode; value: "window"; icon: Theme.icon(0xf0376); name: "Window" }
            Pick { key: "shotMode"; current: Config.shotMode; value: "screen"; icon: Theme.icon(0xf0379); name: "Screen" }
        }
        Group {
            BarText {
                height: Theme.pillHeight
                text: Theme.icon(0xf051b)
                color: Theme.textDim
            }
            Pick { key: "shotDelay"; current: Config.shotDelay; value: 0; name: "0" }
            Pick { key: "shotDelay"; current: Config.shotDelay; value: 3; name: "3s" }
            Pick { key: "shotDelay"; current: Config.shotDelay; value: 5; name: "5s" }
            Pick { key: "shotDelay"; current: Config.shotDelay; value: 10; name: "10s" }
        }
        Group {
            Pick { key: "shotAction"; current: Config.shotAction; value: "copy"; name: "Copy" }
            Pick { key: "shotAction"; current: Config.shotAction; value: "save"; name: "Save" }
            Pick { key: "shotAction"; current: Config.shotAction; value: "both"; name: "Both" }
        }
        Chip {
            icon: Theme.icon(0xf0100)
            label: "Capture"
            bg: Theme.primary
            fg: Theme.primaryFg
            hoverBg: Theme.alpha(Theme.primary, 0.85)
            onLeftClicked: Shot.capture()
        }
    }
}
