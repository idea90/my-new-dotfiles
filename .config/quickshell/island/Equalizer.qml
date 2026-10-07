import QtQuick
import qs

// Three bouncing bars, shown next to the song while music plays
Row {
    property bool running: true
    spacing: 3
    height: 16

    Repeater {
        model: [0.9, 0.5, 0.75]
        delegate: Rectangle {
            required property real modelData
            required property int index
            anchors.bottom: parent.bottom
            width: 3
            radius: 1.5
            color: Theme.primary
            height: 5
            SequentialAnimation on height {
                running: parent.running
                loops: Animation.Infinite
                NumberAnimation { to: 16 * modelData; duration: 260 + index * 70; easing.type: Easing.InOutSine }
                NumberAnimation { to: 4; duration: 300 + index * 50; easing.type: Easing.InOutSine }
            }
        }
    }
}
