import QtQuick
import qs

// Slim progress bar (value 0..1)
Rectangle {
    property real value: 0
    property color fill: Theme.primary

    implicitWidth: 44
    implicitHeight: 4
    radius: 2
    color: Theme.alpha(Theme.text, 0.18)

    Rectangle {
        width: Math.max(parent.height, parent.width * Math.min(1, parent.value))
        height: parent.height
        radius: 2
        color: parent.fill
        Behavior on width {
            NumberAnimation { duration: Theme.dur(300); easing.type: Easing.OutCubic }
        }
    }
}
