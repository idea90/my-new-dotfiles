import QtQuick
import QtQuick.Effects
import qs

// Panel background that swallows clicks so they don't close the overlay
Rectangle {
    radius: Theme.radius
    color: Theme.panelFill
    border.width: Config.panelBorder
    border.color: Theme.panelBorderFill

    layer.enabled: Config.shadows
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.55)
        shadowBlur: 0.9
        shadowVerticalOffset: 6
    }

    MouseArea {
        anchors.fill: parent
    }
}
