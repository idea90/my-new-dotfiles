import QtQuick
import qs
import qs.modules
import qs.services

// Icon, level bar and percentage for volume / mic / brightness
Rectangle {
    id: osd

    readonly property real level: Osd.kind === "brightness" ? Brightness.percent / 100
        : Osd.kind === "mic" ? (Audio.micMuted ? 0 : 1)
        : (Audio.muted ? 0 : Audio.volume)
    readonly property string icon: Osd.kind === "brightness" ? Theme.icon(0xf00df)
        : Osd.kind === "mic" ? (Audio.micMuted ? Theme.icon(0xf036d) : Theme.icon(0xf036c))
        : Audio.muted ? Theme.icon(0xf075f)
        : Audio.volume < 0.34 ? Theme.icon(0xf057f)
        : Audio.volume < 0.67 ? Theme.icon(0xf0580)
        : Theme.icon(0xf057e)
    readonly property string text: Osd.kind === "mic" ? (Audio.micMuted ? "Mic off" : "Mic on")
        : Osd.kind === "volume" && Audio.muted ? "Muted"
        : Math.round(level * 100) + "%"

    implicitWidth: Config.osdWidth
    implicitHeight: 56
    radius: Theme.radius
    color: Theme.panelFill
    border.width: Config.panelBorder
    border.color: Theme.panelBorderFill

    BarText {
        id: iconText
        anchors {
            left: parent.left
            leftMargin: 18
            verticalCenter: parent.verticalCenter
        }
        text: osd.icon
        font.pixelSize: 22
        color: Theme.primary
    }

    Rectangle {
        anchors {
            left: iconText.right
            right: value.left
            leftMargin: 14
            rightMargin: 14
            verticalCenter: parent.verticalCenter
        }
        height: 8
        radius: 4
        color: Theme.surfaceHighest

        Rectangle {
            width: parent.width * Math.min(1, osd.level)
            height: parent.height
            radius: 4
            color: osd.level > 1 ? Theme.error : Theme.primary

            Behavior on width {
                NumberAnimation { duration: Theme.dur(120); easing.type: Easing.OutCubic }
            }
        }
    }

    BarText {
        id: value
        width: 56
        anchors {
            right: parent.right
            rightMargin: 18
            verticalCenter: parent.verticalCenter
        }
        horizontalAlignment: Text.AlignRight
        text: osd.text
        color: Theme.textDim
        font.pixelSize: 13
    }
}
