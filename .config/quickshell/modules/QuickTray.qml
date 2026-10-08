import QtQuick
import qs
import qs.services

// Windows-style group of system icons (network, sound, battery) in one button;
// click opens the quick settings (control center), scroll changes the volume,
// right-click opens the volume mixer.
Rectangle {
    id: qt

    readonly property bool vertical: Theme.vertical
    implicitWidth: vertical ? Theme.barItem : row.implicitWidth + 20
    implicitHeight: vertical ? row.implicitHeight + 16 : Theme.barItem
    radius: Theme.chipRadius
    color: mouse.pressed ? Theme.alpha(Theme.text, 0.12) : mouse.containsMouse || Panels.open === "controlcenter" ? Theme.alpha(Theme.text, 0.08) : "transparent"
    Behavior on color {
        ColorAnimation { duration: Theme.dur(120) }
    }

    readonly property var wifiIcons: [0xf091f, 0xf0922, 0xf0925, 0xf0928]

    Grid {
        id: row
        anchors.centerIn: parent
        columns: qt.vertical ? 1 : 100
        spacing: 12
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter

        BarText {
            text: Network.kind === "wifi" ? Theme.icon(qt.wifiIcons[Math.min(3, Math.floor(Network.signal / 25))])
                : Network.kind === "ethernet" ? Theme.icon(0xf0200) : Theme.icon(0xf092e)
            font.pixelSize: Math.round(15 * Theme.barScale)
            color: Network.kind === "none" ? Theme.alpha(Theme.text, 0.5) : Theme.text
        }
        BarText {
            visible: Audio.ready
            text: Audio.muted ? Theme.icon(0xf075f) : Audio.volume < 0.34 ? Theme.icon(0xf057f) : Audio.volume < 0.67 ? Theme.icon(0xf0580) : Theme.icon(0xf057e)
            font.pixelSize: Math.round(15 * Theme.barScale)
        }
        BarText {
            visible: Battery.available
            text: Theme.icon(Battery.charging ? 0xf0084 : 0xf0079)
            font.pixelSize: Math.round(15 * Theme.barScale)
            color: !Battery.charging && Battery.percent <= 20 ? Theme.error : Theme.text
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.ArrowCursor
        onClicked: event => event.button === Qt.RightButton ? Panels.toggle("mixer") : Panels.toggle("controlcenter")
        onWheel: event => Audio.change(event.angleDelta.y > 0 ? 0.02 : -0.02)
    }
}
