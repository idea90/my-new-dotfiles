import QtQuick
import qs

// Panel background that swallows clicks so they don't close the overlay
Rectangle {
    radius: Theme.radius
    color: Theme.panelFill
    border.width: Config.panelBorder
    border.color: Theme.panelBorderFill

    MouseArea {
        anchors.fill: parent
    }
}
