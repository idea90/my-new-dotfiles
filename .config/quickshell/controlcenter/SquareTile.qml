import QtQuick
import qs
import qs.modules

// Square quick-settings tile: big icon over a label
Rectangle {
    id: tile

    property string icon
    property string label
    property bool on: false
    signal clicked
    signal rightClicked

    implicitHeight: 76
    radius: Config.itemRadius + 4
    color: on ? Theme.primaryContainer : mouse.containsMouse ? Theme.surfaceHighest : Theme.surfaceHigh

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    Column {
        anchors.centerIn: parent
        spacing: 6
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.icon
            font.pixelSize: 22
            color: tile.on ? Theme.primary : Theme.text
        }
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.label
            font.pixelSize: 11
            font.bold: tile.on
            color: tile.on ? Theme.primaryContainerFg : Theme.textDim
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
