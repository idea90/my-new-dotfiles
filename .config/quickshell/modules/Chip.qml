import QtQuick
import qs

// Icon + optional label inside a pill, with hover highlight, clicks and scroll
Rectangle {
    id: chip

    property string icon: ""
    property string label: ""
    property color fg: Theme.text
    property color bg: "transparent"
    property color hoverBg: Theme.surfaceHighest
    property color hoverFg: fg
    property int padding: 10
    readonly property bool hovered: mouse.containsMouse

    signal leftClicked
    signal rightClicked
    signal middleClicked
    signal scrolled(int step)   // +1 up, -1 down

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Theme.pillHeight
    radius: Theme.innerRadius
    color: hovered ? hoverBg : bg

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 7

        BarText {
            visible: chip.icon !== ""
            text: chip.icon
            color: chip.hovered ? chip.hoverFg : chip.fg
            font.pixelSize: Theme.iconSize
        }
        BarText {
            visible: chip.label !== ""
            text: chip.label
            color: chip.hovered ? chip.hoverFg : chip.fg
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => {
            if (event.button === Qt.RightButton)
                chip.rightClicked();
            else if (event.button === Qt.MiddleButton)
                chip.middleClicked();
            else
                chip.leftClicked();
        }
        onWheel: event => chip.scrolled(event.angleDelta.y > 0 ? 1 : -1)
    }
}
