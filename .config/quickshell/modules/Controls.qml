import QtQuick
import Quickshell
import qs
import qs.services

// Volume and brightness sliders in the bar, then battery
Row {
    spacing: 14

    Row {
        visible: Audio.ready
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Audio.muted ? Theme.icon(0xf075f) : Theme.icon(0xf057e)
            color: Audio.muted ? Theme.alpha(Theme.text, 0.45) : Theme.text
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.toggleMute()
                onWheel: event => Audio.change(event.angleDelta.y > 0 ? 0.02 : -0.02)
            }
        }
        MiniSlider {
            anchors.verticalCenter: parent.verticalCenter
            value: Audio.muted ? 0 : Audio.volume
            color: Audio.volume > 1 ? Theme.error : Theme.primary
            onMoved: v => Audio.setVolume(v)
        }
    }

    Row {
        visible: Brightness.available
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Theme.icon(0xf00df)
        }
        MiniSlider {
            anchors.verticalCenter: parent.verticalCenter
            value: Brightness.percent / 100
            onMoved: v => Brightness.set(v)
        }
    }

    Row {
        visible: Battery.available
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        readonly property bool low: !Battery.charging && Battery.percent <= 30

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Battery.charging ? Theme.icon(0xf0084) : Theme.icon(0xf0079)
            color: parent.low ? Theme.error : Battery.charging ? Theme.tertiary : "#8fd68a"
        }
        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Battery.percent + "%"
            font.pixelSize: 13
            color: parent.low ? Theme.error : Theme.text
        }
    }
}
