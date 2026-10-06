import QtQuick
import qs
import qs.modules

// Round icon-only toggle
Rectangle {
    id: tile

    property string icon
    property bool on: false
    signal clicked
    signal rightClicked

    implicitWidth: 48
    implicitHeight: 48
    radius: width / 2
    color: on ? Theme.primary : mouse.containsMouse ? Theme.surfaceHighest : Theme.surfaceHigh

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    BarText {
        anchors.centerIn: parent
        text: tile.icon
        font.pixelSize: 19
        color: tile.on ? Theme.primaryFg : Theme.text
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
