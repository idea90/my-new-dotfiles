import QtQuick
import qs

// Level indicator for the bar's status group. Config.statusStyle picks the look:
//   rings  icon inside a circular gauge, percentage slides out on hover
//   bars   icon next to a slim progress bar
//   text   icon and the percentage, always shown
//   icons  just the icon, tinted by the level color
//   sliders  icon and a draggable slider (volume, brightness); a bar for the rest
//   pills  a small pill that fills up, icon and number on top
//   meter  icon next to a little vertical gauge
//   labels  short name and number, like "VOL 25%"
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
    // On a side bar only narrow looks fit: rings, icons and meter stay, the wide
    // ones (bars, sliders, pills, labels, text) show the icon over the number
    readonly property string look: Theme.vertical && !["rings", "icons", "meter"].includes(Config.statusStyle)
        ? "text" : Config.statusStyle

    signal leftClicked
    signal rightClicked
    signal scrolled(int step)
    signal moved(real value)            // from the slider in "sliders" look
    property bool settable: false       // true when moved() actually changes something
    property string shortName: ""       // for the "labels" look, e.g. "CPU"

    implicitWidth: Theme.vertical ? Theme.barItem : row.implicitWidth + 12
    implicitHeight: Theme.vertical ? row.implicitHeight + 8 : Theme.barItem

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

    Grid {
        id: row
        columns: Theme.vertical ? 1 : 100
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        z: ring.look === "sliders" ? 1 : 0
        anchors.centerIn: parent
        spacing: Theme.vertical ? 0 : 6

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
            text: ring.label
            font.pixelSize: 12
        }

        // bars / text / icons / sliders / meter
        BarText {
            visible: ring.look !== "rings" && ring.look !== "pills" && ring.look !== "labels"
            text: ring.icon
            font.pixelSize: Math.round(14 * Theme.barScale)
            color: ring.look === "icons" ? ring.color : ring.iconColor
        }
        MiniBar {
            visible: ring.look === "bars" || (ring.look === "sliders" && !ring.settable)
            implicitWidth: Math.round(34 * Theme.barScale)
            value: ring.value
            fill: ring.color
        }
        BarText {
            visible: ring.look === "text"
            text: Theme.vertical ? ring.label.replace("%", "") : ring.label
            font.pixelSize: Theme.vertical ? 10 : 12
            font.family: Theme.barFont
        }
        MiniSlider {
            visible: ring.look === "sliders" && ring.settable
            implicitWidth: Math.round(52 * Theme.barScale)
            value: ring.value
            color: ring.color
            onMoved: v => ring.moved(v)
        }
        // meter: a small vertical gauge filling from the bottom
        Rectangle {
            visible: ring.look === "meter"
            width: 6
            height: Math.round(18 * Theme.barScale)
            radius: 3
            color: Theme.alpha(Theme.text, 0.18)
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Math.max(width, parent.height * Math.min(1, ring.value))
                radius: 3
                color: ring.color
            }
        }
        // pills: the whole pill fills up, icon and number on top
        Rectangle {
            visible: ring.look === "pills"
            width: pillText.implicitWidth + 20
            height: Theme.barItem - 6
            radius: height / 2
            color: Theme.alpha(Theme.text, 0.12)
            clip: true
            Rectangle {
                width: parent.width * Math.min(1, ring.value)
                height: parent.height
                radius: parent.radius
                color: Theme.alpha(ring.color, 0.55)
            }
            BarText {
                id: pillText
                anchors.centerIn: parent
                text: ring.icon + " " + ring.label
                font.pixelSize: 11
                font.bold: true
            }
        }
        // labels: short name and number
        Row {
            visible: ring.look === "labels"
            spacing: 4
            BarText {
                text: ring.shortName
                font.pixelSize: 10
                font.bold: true
                color: ring.color
                anchors.verticalCenter: parent.verticalCenter
            }
            BarText {
                text: ring.label
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => {
            if (event.button === Qt.MiddleButton) {
                // Middle-click cycles through the status looks
                const looks = ["rings", "bars", "sliders", "pills", "meter", "text", "labels", "icons"];
                Config.set("statusStyle", looks[(looks.indexOf(Config.statusStyle) + 1) % looks.length]);
            } else if (event.button === Qt.RightButton) {
                ring.rightClicked();
            } else {
                ring.leftClicked();
            }
        }
        onWheel: event => ring.scrolled(event.angleDelta.y > 0 ? 1 : -1)
    }
}
