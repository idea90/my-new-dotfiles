import QtQuick
import qs
import qs.modules

// Compact quick-settings toggle: icon and label in a row
Rectangle {
    id: tile

    property string icon
    property string label
    property bool on: false
    signal clicked
    signal rightClicked

    implicitHeight: 46
    radius: Config.itemRadius + 2
    color: on ? Theme.primaryContainer : mouse.containsMouse ? Theme.surfaceHighest : Theme.surfaceHigh

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    Row {
        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }
        spacing: 10
        BarText {
            width: 20
            text: tile.icon
            font.pixelSize: 17
            color: tile.on ? Theme.primary : Theme.textDim
        }
        BarText {
            text: tile.label
            font.pixelSize: 13
            font.bold: tile.on
            color: tile.on ? Theme.primaryContainerFg : Theme.text
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
