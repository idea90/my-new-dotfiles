import QtQuick
import qs

// Level indicator for the bar's status group. Config.statusStyle picks the look:
//   rings  icon inside a circular gauge, percentage slides out on hover
//   bars   icon next to a slim progress bar
//   text   icon and the percentage, always shown
//   icons  just the icon, tinted by the level color
// Scroll / click signals like Chip.
Item {
    id: ring

    property real value: 0           // 0..1 (values above 1 draw a full ring)
    property string icon: ""
    property string label: Math.round(value * 100) + "%"
    property color color: Theme.primary
    property color iconColor: Theme.text
    property bool hoverDetails: true    // false: no highlight or label on hover
    readonly property bool hovered: hoverDetails && mouse.containsMouse
    readonly property string look: Config.statusStyle

    signal leftClicked
    signal rightClicked
    signal scrolled(int step)

    implicitWidth: row.implicitWidth + 12
    implicitHeight: Theme.barItem

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.dur(180); easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: ring.hovered ? Theme.surfaceHigh : "transparent"
        Behavior on color {
            ColorAnimation { duration: Theme.dur(150) }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Item {
            visible: ring.look === "rings"
            width: Theme.barItem - 4
            height: Theme.barItem - 4

            Canvas {
                id: canvas
                anchors.fill: parent
                property real value: Math.max(0, Math.min(1, ring.value))
                property color track: Theme.surfaceHighest
                property color fill: ring.color
                onValueChanged: requestPaint()
                onFillChanged: requestPaint()
                onTrackChanged: requestPaint()
                onWidthChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d");
                    const r = width / 2 - 2;
                    ctx.reset();
                    ctx.lineWidth = 3;
                    ctx.lineCap = "round";
                    ctx.strokeStyle = track;
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2, r, 0, 2 * Math.PI);
                    ctx.stroke();
                    if (value > 0) {
                        ctx.strokeStyle = fill;
                        ctx.beginPath();
                        ctx.arc(width / 2, height / 2, r, -Math.PI / 2, -Math.PI / 2 + value * 2 * Math.PI);
                        ctx.stroke();
                    }
                }
            }

            BarText {
                anchors.centerIn: parent
                text: ring.icon
                color: ring.iconColor
                font.pixelSize: 12
            }
        }

        BarText {
            visible: ring.look === "rings" && ring.hovered
            anchors.verticalCenter: parent.verticalCenter
            text: ring.label
            font.pixelSize: 12
        }

        // bars / text / icons
        BarText {
            visible: ring.look !== "rings"
            anchors.verticalCenter: parent.verticalCenter
            text: ring.icon
            font.pixelSize: Math.round(14 * Theme.barScale)
            color: ring.look === "icons" ? ring.color : ring.iconColor
        }
        MiniBar {
            visible: ring.look === "bars"
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: Math.round(34 * Theme.barScale)
            value: ring.value
            fill: ring.color
        }
        BarText {
            visible: ring.look === "text"
            anchors.verticalCenter: parent.verticalCenter
            text: ring.label
            font.pixelSize: 12
            font.family: Theme.barFont
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => event.button === Qt.RightButton ? ring.rightClicked() : ring.leftClicked()
        onWheel: event => ring.scrolled(event.angleDelta.y > 0 ? 1 : -1)
    }
}
