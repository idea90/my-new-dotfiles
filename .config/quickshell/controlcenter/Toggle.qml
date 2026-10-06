import QtQuick
import qs
import qs.modules

// Quick-settings tile: icon + label, filled when on
Rectangle {
    id: tile

    property string icon
    property string label
    property bool on: false
    signal clicked
    signal rightClicked

    implicitHeight: 64
    radius: Config.itemRadius
    color: on ? Theme.primary : mouse.containsMouse ? Theme.surfaceHighest : Theme.surfaceHigh

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    Column {
        anchors.centerIn: parent
        spacing: 4

        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.icon
            font.pixelSize: 20
            color: tile.on ? Theme.primaryFg : Theme.text
        }
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.label
            font.pixelSize: 11
            color: tile.on ? Theme.primaryFg : Theme.textDim
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => event.button === Qt.RightButton ? tile.rightClicked() : tile.clicked()
    }
}
