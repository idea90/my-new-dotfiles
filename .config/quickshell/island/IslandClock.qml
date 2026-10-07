import QtQuick
import Quickshell
import qs
import qs.services

// The clock inside the dynamic island. Config.islandClockStyle picks the design:
//   text     plain bold time
//   accent   hour in the accent color, minutes in the secondary
//   words    "quarter past two"
//   analog   tiny round face with live hands
//   ring     time inside a ring that fills with the minute
//   flip     four small flip cards
//   capsule  time in a filled pill
//   stack    hours over minutes
//   bar      time with a thin bar for how much of the hour has passed
// `u` scales everything (1 in the resting island, larger in the hover panel).
Item {
    id: clk

    property real u: 1
    readonly property string look: Config.islandClockStyle
    readonly property int fs: Math.round(15 * u)
    readonly property color c1: Qt.lighter(Theme.primary, 1.25)
    readonly property color c2: Qt.lighter(Theme.tertiary, 1.2)

    SystemClock {
        id: sec
        precision: clk.look === "analog" || clk.look === "ring" ? SystemClock.Seconds : SystemClock.Minutes
    }
    readonly property date now: sec.date
    readonly property int h24: now.getHours()
    readonly property int mins: now.getMinutes()
    readonly property string hh: Config.clock24h ? Qt.formatDateTime(now, "HH") : String(h24 % 12 === 0 ? 12 : h24 % 12)
    readonly property string mm: Qt.formatDateTime(now, "mm")

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight: loader.item ? loader.item.implicitHeight : 0

    Loader {
        id: loader
        anchors.centerIn: parent
        sourceComponent: ({
            text: plain, accent: accent, words: words, analog: analog, ring: ring,
            flip: flip, capsule: capsule, stack: stack, bar: bar
        })[clk.look] ?? plain
    }

    component Tx: Text {
        font.family: Theme.font
        font.bold: true
        font.pixelSize: clk.fs
        color: "#ffffff"
    }

    Component { id: plain; Tx { text: clk.hh + ":" + clk.mm } }

    Component {
        id: accent
        Row {
            Tx { text: clk.hh; color: clk.c1 }
            Tx { text: ":"; color: Qt.rgba(1, 1, 1, 0.6); font.bold: false }
            Tx { text: clk.mm; color: clk.c2 }
        }
    }

    Component {
        id: words
        Tx {
            readonly property var nums: ["twelve", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven"]
            readonly property int m: clk.mins
            readonly property int hh: (clk.h24 + (m > 32 ? 1 : 0)) % 12
            readonly property string part: m < 3 || m > 57 ? "" : m < 8 ? "five past " : m < 13 ? "ten past " : m < 18 ? "quarter past "
                : m < 23 ? "twenty past " : m < 28 ? "twenty-five past " : m < 33 ? "half past " : m < 38 ? "twenty-five to "
                : m < 43 ? "twenty to " : m < 48 ? "quarter to " : m < 53 ? "ten to " : "five to "
            text: part + nums[hh] + (part === "" ? " o'clock" : "")
            color: clk.c1
            font.pixelSize: Math.round(14 * clk.u)
        }
    }

    Component {
        id: analog
        Item {
            readonly property real d: Math.round((Config.islandCompactHeight - 10) * clk.u)
            implicitWidth: d
            implicitHeight: d
            Rectangle { anchors.fill: parent; radius: width / 2; color: "transparent"; border.width: 1.5; border.color: Qt.rgba(1, 1, 1, 0.55) }
            Repeater {
                model: 12
                delegate: Item {
                    required property int index
                    anchors.fill: parent
                    rotation: index * 30
                    Rectangle { x: parent.width / 2 - 0.5; y: 2; width: 1; height: index % 3 === 0 ? 4 : 2; color: Qt.rgba(1, 1, 1, 0.6) }
                }
            }
            Rectangle {
                x: parent.width / 2 - 1.5; y: parent.height / 2 - height; width: 3; height: parent.height * 0.26; radius: 1.5; color: "#ffffff"
                transformOrigin: Item.Bottom; rotation: (clk.h24 % 12 + clk.mins / 60) * 30
            }
            Rectangle {
                x: parent.width / 2 - 1; y: parent.height / 2 - height; width: 2; height: parent.height * 0.38; radius: 1; color: clk.c1
                transformOrigin: Item.Bottom; rotation: (clk.mins + clk.now.getSeconds() / 60) * 6
            }
            Rectangle {
                x: parent.width / 2 - 0.5; y: parent.height / 2 - height; width: 1; height: parent.height * 0.42; color: clk.c2
                transformOrigin: Item.Bottom; rotation: clk.now.getSeconds() * 6
            }
            Rectangle { anchors.centerIn: parent; width: 4; height: 4; radius: 2; color: clk.c2 }
        }
    }

    Component {
        id: ring
        Item {
            readonly property real d: Math.round((Config.islandCompactHeight - 4) * clk.u)
            implicitWidth: d + Math.round(clk.fs * 2.2)
            implicitHeight: d
            Canvas {
                id: arc
                width: parent.d
                height: parent.d
                property real minute: clk.mins + clk.now.getSeconds() / 60
                onMinuteChanged: requestPaint()
                onWidthChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const r = width / 2 - 3, c = width / 2;
                    ctx.lineWidth = 3;
                    ctx.lineCap = "round";
                    ctx.strokeStyle = "rgba(255,255,255,0.2)";
                    ctx.beginPath(); ctx.arc(c, c, r, 0, Math.PI * 2); ctx.stroke();
                    ctx.strokeStyle = clk.c1;
                    ctx.beginPath(); ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.max(0.01, minute / 60)); ctx.stroke();
                }
            }
            Tx {
                anchors.left: arc.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: clk.hh + ":" + clk.mm
            }
        }
    }

    Component {
        id: flip
        Row {
            spacing: 2
            readonly property string h2: clk.hh.length < 2 ? "0" + clk.hh : clk.hh
            component Card: Rectangle {
                property string value: ""
                implicitWidth: Math.round(clk.fs * 1.05)
                implicitHeight: Math.round(clk.fs * 1.55)
                radius: 3
                color: Qt.rgba(1, 1, 1, 0.14)
                Text { anchors.centerIn: parent; text: parent.value; color: "#ffffff"; font.family: Theme.font; font.bold: true; font.pixelSize: clk.fs }
                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 1; color: Qt.rgba(0, 0, 0, 0.6) }
            }
            Card { value: parent.h2[0] }
            Card { value: parent.h2[1] }
            Item { width: 4; height: 1 }
            Card { value: clk.mm[0] }
            Card { value: clk.mm[1] }
        }
    }

    Component {
        id: capsule
        Rectangle {
            implicitWidth: capText.implicitWidth + Math.round(18 * clk.u)
            implicitHeight: Math.round((Config.islandCompactHeight - 10) * clk.u)
            radius: height / 2
            color: Theme.primary
            Text {
                id: capText
                anchors.centerIn: parent
                text: clk.hh + ":" + clk.mm
                color: Theme.primaryFg
                font.family: Theme.font
                font.bold: true
                font.pixelSize: clk.fs
            }
        }
    }

    Component {
        id: stack
        Column {
            spacing: -Math.round(3 * clk.u)
            Tx { anchors.horizontalCenter: parent.horizontalCenter; text: clk.hh; font.pixelSize: Math.round(clk.fs * 0.82); color: clk.c1 }
            Tx { anchors.horizontalCenter: parent.horizontalCenter; text: clk.mm; font.pixelSize: Math.round(clk.fs * 0.82); color: clk.c2 }
        }
    }

    Component {
        id: bar
        Column {
            spacing: 3
            Tx { anchors.horizontalCenter: parent.horizontalCenter; text: clk.hh + ":" + clk.mm }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.round(40 * clk.u)
                height: 3
                radius: 1.5
                color: Qt.rgba(1, 1, 1, 0.22)
                Rectangle { width: Math.max(3, parent.width * clk.mins / 60); height: parent.height; radius: 1.5; color: clk.c1 }
            }
        }
    }
}
