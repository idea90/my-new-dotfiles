import QtQuick
import qs

// Horizontal slider with an icon. value is 0..1; moved(value) fires while dragging.
Item {
    id: slider

    property real value: 0
    property string icon: ""
    signal moved(real value)
    signal iconClicked

    implicitHeight: 40

    BarText {
        id: iconText
        width: 28
        anchors.verticalCenter: parent.verticalCenter
        text: slider.icon
        font.pixelSize: 18
        horizontalAlignment: Text.AlignHCenter

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: slider.iconClicked()
        }
    }

    Rectangle {
        id: track
        anchors {
            left: iconText.right
            right: label.left
            leftMargin: 10
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: 10
        radius: 5
        color: Theme.surfaceHighest

        Rectangle {
            width: Math.max(height, track.width * Math.min(1, slider.value))
            height: parent.height
            radius: 5
            color: Theme.primary
        }

        Rectangle {
            x: Math.max(0, Math.min(track.width, track.width * Math.min(1, slider.value))) - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            radius: 9
            color: Theme.primaryContainerFg
            border.width: 2
            border.color: Theme.primary
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            cursorShape: Qt.PointingHandCursor
            function update(x) {
                slider.moved(Math.max(0, Math.min(1, (x - 10) / track.width)));
            }
            onPressed: event => update(event.x)
            onPositionChanged: event => update(event.x)
        }
    }

    BarText {
        id: label
        width: 42
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        horizontalAlignment: Text.AlignRight
        text: Math.round(slider.value * 100) + "%"
        color: Theme.textDim
        font.pixelSize: 12
    }
}
