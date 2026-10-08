import QtQuick
import qs
import qs.modules

// Wide quick-settings tile with a state subtitle (Wi-Fi: network name, Sound: volume)
Rectangle {
    id: tile

    property string icon
    property string label
    property string sub
    property bool on: false
    signal clicked
    signal rightClicked

    implicitHeight: 66
    radius: Config.itemRadius + 4
    color: on ? (Config.tileAccent ? Theme.primary : Theme.primaryContainer) : mouse.containsMouse ? Theme.surfaceHighest : Theme.surfaceHigh

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    Rectangle {
        id: disc
        width: 40
        height: 40
        radius: 20
        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }
        color: tile.on ? (Config.tileAccent ? Theme.alpha(Theme.primaryFg, 0.18) : Theme.primary) : Theme.surfaceHighest
        Behavior on color {
            ColorAnimation { duration: Theme.dur(150) }
        }
        BarText {
            anchors.centerIn: parent
            text: tile.icon
            font.pixelSize: 19
            color: tile.on ? Theme.primaryFg : Theme.text
        }
    }

    Column {
        anchors {
            left: disc.right
            leftMargin: 12
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        BarText {
            width: parent.width
            text: tile.label
            font.bold: true
            font.pixelSize: 14
            color: tile.on ? (Config.tileAccent ? Theme.primaryFg : Theme.primaryContainerFg) : Theme.text
            elide: Text.ElideRight
        }
        BarText {
            width: parent.width
            text: tile.sub
            font.pixelSize: 11
            color: tile.on ? Theme.alpha(Theme.primaryContainerFg, 0.75) : Theme.textDim
            elide: Text.ElideRight
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
