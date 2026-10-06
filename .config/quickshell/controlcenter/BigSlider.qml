import QtQuick
import qs
import qs.modules

// Thick slider: the whole bar fills, with the icon and percentage inside.
// Drag or scroll; moved(value 0..1).
Rectangle {
    id: slider

    property real value: 0
    property string icon: ""
    signal moved(real value)
    signal iconClicked

    implicitHeight: 46
    radius: Config.itemRadius + 4
    color: Theme.surfaceHigh
    clip: true

    Rectangle {
        width: Math.max(slider.radius * 2, slider.width * Math.min(1, slider.value))
        height: parent.height
        radius: slider.radius
        color: Theme.primaryContainer
        Behavior on width {
            NumberAnimation { duration: Theme.dur(120) }
        }
    }

    BarText {
        anchors {
            left: parent.left
            leftMargin: 16
            verticalCenter: parent.verticalCenter
        }
        text: slider.icon
        font.pixelSize: 18
        color: Theme.primaryContainerFg
        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: slider.iconClicked()
        }
    }
    BarText {
        anchors {
            right: parent.right
            rightMargin: 16
            verticalCenter: parent.verticalCenter
        }
        text: Math.round(slider.value * 100) + "%"
        font.pixelSize: 12
        font.bold: true
        color: Theme.text
    }

    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: 44
        cursorShape: Qt.PointingHandCursor
        onPressed: event => slider.moved(Math.max(0, Math.min(1, (event.x + 44) / slider.width)))
        onPositionChanged: event => {
            if (pressed)
                slider.moved(Math.max(0, Math.min(1, (event.x + 44) / slider.width)));
        }
        onWheel: event => slider.moved(Math.max(0, Math.min(1, slider.value + (event.angleDelta.y > 0 ? 0.04 : -0.04))))
    }
}
