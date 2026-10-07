import QtQuick
import QtQuick.Effects
import Quickshell
import qs
import qs.modules
import qs.services

// The lock screen clock. Config.lockClockStyle picks the design:
//   big stacked small      plain text (see LockContent)
//   pixel                  date + weather over stacked hours / minutes, wallpaper-tinted
//   analog                 round face with hands and ticks
//   words                  "quarter past two" in big type
//   ring                   time inside a ring that fills with the minute
//   flip                   two flip-clock cards
//   neon                   glowing tube-style digits
//   outline                hollow, outlined digits
//   editorial              serif time with a rule and small-caps date
//   progress               time with a bar for how much of today has passed
Item {
    id: clk

    property bool onLeft: false
    readonly property string look: Config.lockClockStyle
    readonly property string fam: Config.lockClockFont !== "" ? Config.lockClockFont : "Outfit"
    readonly property int size: Config.lockClockSize
    readonly property color c1: Qt.lighter(Theme.primary, 1.25)
    readonly property color c2: Qt.lighter(Theme.tertiary, 1.2)

    // Seconds precision only while an analog / ring face needs it
    SystemClock {
        id: sec
        precision: clk.look === "analog" || clk.look === "ring" ? SystemClock.Seconds : SystemClock.Minutes
    }
    readonly property date now: sec.date
    readonly property int h24: now.getHours()
    readonly property int h12: h24 % 12 === 0 ? 12 : h24 % 12
    readonly property string hh: Config.clock24h ? Qt.formatDateTime(now, "HH") : String(h12)
    readonly property string mm: Qt.formatDateTime(now, "mm")
    readonly property string dateLong: Qt.formatDateTime(now, "dddd, d MMMM")
    readonly property string dateShort: Qt.formatDateTime(now, "ddd, MMM d")
    readonly property string wx: Config.weatherEnabled && Weather.ready ? Weather.glyph + " " + Weather.temp + "°" : ""

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight: loader.item ? loader.item.implicitHeight : 0

    Loader {
        id: loader
        anchors.horizontalCenter: clk.onLeft ? undefined : parent.horizontalCenter
        sourceComponent: ({
            pixel: pixel, analog: analog, words: words, ring: ring, flip: flip,
            neon: neon, outline: outline, editorial: editorial, progress: progress
        })[clk.look] ?? null
    }

    component T: BarText {
        font.family: clk.fam
        style: Text.Outline
        styleColor: Theme.alpha("#000000", 0.2)
    }

    // ---- pixel ----------------------------------------------------------
    Component {
        id: pixel
        Column {
            spacing: -Math.round(clk.size * 0.36)
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                bottomPadding: Math.round(clk.size * 0.22)
                T { text: clk.dateShort; font.pixelSize: 20; font.weight: Font.Medium; color: Qt.rgba(1, 1, 1, 0.95) }
                T { visible: clk.wx !== ""; text: "·   " + clk.wx; font.pixelSize: 20; font.weight: Font.Medium; color: Qt.rgba(1, 1, 1, 0.95) }
            }
            T { anchors.horizontalCenter: parent.horizontalCenter; text: clk.hh; font.pixelSize: Math.round(clk.size * 1.5); font.weight: Config.lockClockWeight; font.letterSpacing: -2; color: clk.c1 }
            T { anchors.horizontalCenter: parent.horizontalCenter; text: clk.mm; font.pixelSize: Math.round(clk.size * 1.5); font.weight: Config.lockClockWeight; font.letterSpacing: -2; color: clk.c2 }
        }
    }

    // ---- analog ---------------------------------------------------------
    Component {
        id: analog
        Item {
            readonly property real d: Math.round(clk.size * 2.3)
            implicitWidth: d
            implicitHeight: d + 54

            Item {
                id: face
                width: parent.d
                height: parent.d

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Theme.alpha("#000000", 0.28)
                    border.width: 2
                    border.color: Qt.rgba(1, 1, 1, 0.35)
                }
                // 60 ticks, longer on the hours
                Repeater {
                    model: 60
                    delegate: Item {
                        required property int index
                        anchors.fill: parent
                        rotation: index * 6
                        Rectangle {
                            x: parent.width / 2 - width / 2
                            y: 8
                            width: index % 5 === 0 ? 3 : 1.5
                            height: index % 5 === 0 ? 14 : 6
                            radius: 1
                            color: index % 5 === 0 ? clk.c1 : Qt.rgba(1, 1, 1, 0.5)
                        }
                    }
                }
                // hands
                Rectangle {   // hour
                    x: face.width / 2 - width / 2
                    y: face.height / 2 - height + 8
                    width: 7
                    height: face.height * 0.24
                    radius: 3.5
                    color: "#ffffff"
                    transformOrigin: Item.Bottom
                    rotation: (clk.h24 % 12 + clk.now.getMinutes() / 60) * 30
                    transform: Translate { y: 0 }
                }
                Rectangle {   // minute
                    x: face.width / 2 - width / 2
                    y: face.height / 2 - height + 8
                    width: 5
                    height: face.height * 0.36
                    radius: 2.5
                    color: clk.c1
                    transformOrigin: Item.Bottom
                    rotation: (clk.now.getMinutes() + clk.now.getSeconds() / 60) * 6
                }
                Rectangle {   // second
                    x: face.width / 2 - width / 2
                    y: face.height / 2 - height + 14
                    width: 2
                    height: face.height * 0.42
                    radius: 1
                    color: clk.c2
                    transformOrigin: Item.Bottom
                    rotation: clk.now.getSeconds() * 6
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    radius: 7
                    color: clk.c2
                }
            }
            T {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: face.bottom
                anchors.topMargin: 16
                text: clk.dateLong
                font.pixelSize: 18
                color: Qt.rgba(1, 1, 1, 0.95)
            }
        }
    }

    // ---- words ----------------------------------------------------------
    Component {
        id: words
        Column {
            spacing: 2
            readonly property var nums: ["twelve", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven"]
            readonly property int m: clk.now.getMinutes()
            readonly property int hh: (clk.h24 + (m > 32 ? 1 : 0)) % 12
            readonly property string minutes: m < 3 || m > 57 ? "" : m < 8 ? "five past" : m < 13 ? "ten past" : m < 18 ? "quarter past"
                : m < 23 ? "twenty past" : m < 28 ? "twenty-five past" : m < 33 ? "half past" : m < 38 ? "twenty-five to"
                : m < 43 ? "twenty to" : m < 48 ? "quarter to" : m < 53 ? "ten to" : "five to"
            T { text: "it's"; font.pixelSize: Math.round(clk.size * 0.38); font.weight: Font.Light; color: Qt.rgba(1, 1, 1, 0.8) }
            T { visible: parent.minutes !== ""; text: parent.minutes; font.pixelSize: Math.round(clk.size * 0.62); font.weight: Font.DemiBold; color: clk.c2 }
            T {
                text: parent.nums[parent.hh] + (parent.minutes === "" ? " o'clock" : "")
                font.pixelSize: Math.round(clk.size * 0.86)
                font.weight: Font.Bold
                color: clk.c1
            }
            T { topPadding: 10; text: clk.dateLong; font.pixelSize: 16; color: Qt.rgba(1, 1, 1, 0.85) }
        }
    }

    // ---- ring -----------------------------------------------------------
    Component {
        id: ring
        Item {
            readonly property real d: Math.round(clk.size * 2.5)
            implicitWidth: d
            implicitHeight: d

            Canvas {
                id: arc
                anchors.fill: parent
                property real minute: clk.now.getMinutes() + clk.now.getSeconds() / 60
                property color a: clk.c1
                property color b: clk.c2
                onMinuteChanged: requestPaint()
                onAChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const r = width / 2 - 14, cx = width / 2, cy = height / 2;
                    ctx.lineWidth = 12;
                    ctx.lineCap = "round";
                    ctx.strokeStyle = "rgba(255,255,255,0.16)";
                    ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.stroke();
                    ctx.strokeStyle = a;
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.max(0.004, minute / 60));
                    ctx.stroke();
                    // inner ring: hour of the day
                    ctx.lineWidth = 6;
                    ctx.strokeStyle = b;
                    ctx.beginPath();
                    ctx.arc(cx, cy, r - 24, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * ((clk.h24 % 12 + minute / 60) / 12));
                    ctx.stroke();
                }
            }
            Column {
                anchors.centerIn: parent
                T { anchors.horizontalCenter: parent.horizontalCenter; text: clk.hh + ":" + clk.mm; font.pixelSize: Math.round(clk.size * 0.72); font.weight: Font.Bold; color: "#ffffff" }
                T { anchors.horizontalCenter: parent.horizontalCenter; text: clk.dateShort; font.pixelSize: 15; color: Qt.rgba(1, 1, 1, 0.85) }
            }
        }
    }

    // ---- flip -----------------------------------------------------------
    Component {
        id: flip
        Row {
            spacing: Math.round(clk.size * 0.09)
            component Card: Rectangle {
                property string value: ""
                implicitWidth: Math.round(clk.size * 0.82)
                implicitHeight: Math.round(clk.size * 1.2)
                radius: Math.round(clk.size * 0.14)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.alpha("#2a2a2a", 0.92) }
                    GradientStop { position: 0.5; color: Theme.alpha("#1d1d1d", 0.92) }
                    GradientStop { position: 0.5001; color: Theme.alpha("#141414", 0.92) }
                    GradientStop { position: 1.0; color: Theme.alpha("#1a1a1a", 0.92) }
                }
                T {
                    anchors.centerIn: parent
                    text: parent.value
                    font.pixelSize: Math.round(clk.size * 0.98)
                    font.weight: Font.Bold
                    color: "#f2f2f2"
                    style: Text.Normal
                }
                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 3; color: Theme.alpha("#000000", 0.7) }
            }
            readonly property string hour2: clk.hh.length < 2 ? "0" + clk.hh : clk.hh
            Card { value: parent.hour2[0] }
            Card { value: parent.hour2[1] }
            Item { width: Math.round(clk.size * 0.12); height: 1 }
            Card { value: clk.mm[0] }
            Card { value: clk.mm[1] }
        }
    }

    // ---- neon -----------------------------------------------------------
    Component {
        id: neon
        Column {
            spacing: 6
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: glow.implicitWidth
                implicitHeight: glow.implicitHeight
                T {
                    id: glow
                    text: clk.hh + ":" + clk.mm
                    font.pixelSize: Math.round(clk.size * 1.25)
                    font.weight: Font.Medium
                    font.letterSpacing: 4
                    color: Qt.lighter(Theme.primary, 1.6)
                    style: Text.Normal
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Theme.primary
                        shadowBlur: 1.0
                        shadowOpacity: 1.0
                        shadowScale: 1.04
                    }
                }
            }
            T { anchors.horizontalCenter: parent.horizontalCenter; text: clk.dateLong.toUpperCase(); font.pixelSize: 15; font.letterSpacing: 6; color: clk.c2 }
        }
    }

    // ---- outline --------------------------------------------------------
    Component {
        id: outline
        Column {
            spacing: -Math.round(clk.size * 0.1)
            T {
                anchors.horizontalCenter: parent.horizontalCenter
                text: clk.hh + ":" + clk.mm
                font.pixelSize: Math.round(clk.size * 1.7)
                font.weight: Font.Black
                color: "transparent"
                style: Text.Outline
                styleColor: Qt.rgba(1, 1, 1, 0.95)
                font.letterSpacing: 2
            }
            T { anchors.horizontalCenter: parent.horizontalCenter; text: clk.dateLong; font.pixelSize: 18; color: clk.c1; style: Text.Normal }
        }
    }

    // ---- editorial ------------------------------------------------------
    Component {
        id: editorial
        Column {
            spacing: 10
            T {
                anchors.horizontalCenter: parent.horizontalCenter
                text: clk.hh + ":" + clk.mm
                font.family: "Playfair Display"
                font.pixelSize: Math.round(clk.size * 1.45)
                font.weight: Font.Normal
                color: "#ffffff"
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14
                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: Math.round(clk.size * 0.7); height: 1; color: clk.c1 }
                T { text: Qt.formatDateTime(clk.now, "dddd").toUpperCase(); font.pixelSize: 14; font.letterSpacing: 7; color: clk.c1; style: Text.Normal }
                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: Math.round(clk.size * 0.7); height: 1; color: clk.c1 }
            }
            T { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(clk.now, "d MMMM yyyy"); font.family: "Playfair Display"; font.pixelSize: 17; font.italic: true; color: Qt.rgba(1, 1, 1, 0.85) }
        }
    }

    // ---- progress (how much of today is gone) ----------------------------
    Component {
        id: progress
        Column {
            spacing: 12
            readonly property real day: (clk.h24 * 60 + clk.now.getMinutes()) / 1440
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                T { text: clk.hh; font.pixelSize: Math.round(clk.size * 1.3); font.weight: Font.Bold; color: clk.c1 }
                T { text: ":"; font.pixelSize: Math.round(clk.size * 1.3); font.weight: Font.Light; color: Qt.rgba(1, 1, 1, 0.7) }
                T { text: clk.mm; font.pixelSize: Math.round(clk.size * 1.3); font.weight: Font.Bold; color: clk.c2 }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.round(clk.size * 2.8)
                height: 8
                radius: 4
                color: Qt.rgba(1, 1, 1, 0.2)
                Rectangle { width: Math.max(8, parent.width * parent.parent.day); height: parent.height; radius: 4; color: clk.c1 }
            }
            T { anchors.horizontalCenter: parent.horizontalCenter; text: clk.dateLong + "  ·  " + Math.round(parent.day * 100) + "% of today"; font.pixelSize: 15; color: Qt.rgba(1, 1, 1, 0.85); style: Text.Normal }
        }
    }
}
