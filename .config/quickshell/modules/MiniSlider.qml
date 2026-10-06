import QtQuick
import qs

// Slim draggable bar for the top bar. Drag or scroll to change; moved(value 0..1).
Item {
    id: slider

    property real value: 0
    property color color: Theme.primary
    signal moved(real value)

    implicitWidth: 56
    implicitHeight: 20

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Theme.alpha(Theme.text, 0.18)

        Rectangle {
            width: Math.max(track.height, track.width * Math.min(1, slider.value))
            height: track.height
            radius: 2
            color: slider.color
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: event => slider.moved(Math.max(0, Math.min(1, event.x / width)))
        onPositionChanged: event => {
            if (pressed)
                slider.moved(Math.max(0, Math.min(1, event.x / width)));
        }
        onWheel: event => slider.moved(Math.max(0, Math.min(1, slider.value + (event.angleDelta.y > 0 ? 0.04 : -0.04))))
    }
}
