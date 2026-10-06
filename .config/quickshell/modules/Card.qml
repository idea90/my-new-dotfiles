import QtQuick
import qs

// Panel background that swallows clicks so they don't close the overlay
Rectangle {
    radius: Theme.radius
    color: Theme.surfaceLow
    border.width: 1
    border.color: Theme.outlineVariant

    MouseArea {
        anchors.fill: parent
    }
}
