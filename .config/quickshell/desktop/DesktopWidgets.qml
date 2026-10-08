import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules
import qs.services

// A clock drawn on the wallpaper, under every window.
// Config.widgetClockStyle: aurora | stacked | analog | glass | line
// Config.widgetsPosition: top-left | top-right | bottom-left | bottom-right | center
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    // Background services that only run timers are created on first use; this
    // window always exists, so it keeps them alive
    readonly property var _slideshow: Slideshow
    readonly property var _nightLight: NightLight
    readonly property var _hyprTweaks: HyprTweaks
    readonly property var _depth: Depth

    readonly property string pos: Config.widgetsPosition

    visible: Config.widgetsEnabled
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "qs-desktop"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Only the clock takes clicks; the rest is click-through
    mask: Region { item: stack }

    readonly property string fam: Config.lockClockFont !== "" ? Config.lockClockFont : "Outfit"
    readonly property color c1: Qt.lighter(Theme.primary, 1.3)
    readonly property color c2: Qt.lighter(Theme.tertiary, 1.25)
    readonly property int size: Config.widgetClockSize
    readonly property bool onLeft: win.pos.endsWith("left")
    readonly property bool centered: win.pos === "center" || (!win.pos.endsWith("left") && !win.pos.endsWith("right"))

    SystemClock {
        id: clk
        precision: Config.widgetClockStyle === "analog" && !Config.lowEnd ? SystemClock.Seconds : SystemClock.Minutes
    }
    readonly property date now: clk.date
    readonly property string hh: Config.clock24h ? Qt.formatDateTime(now, "HH") : String(now.getHours() % 12 === 0 ? 12 : now.getHours() % 12)
    readonly property string mm: Qt.formatDateTime(now, "mm")
    readonly property string ap: Config.clock24h ? "" : Qt.formatDateTime(now, "AP")
    readonly property string dateLong: Qt.formatDateTime(now, "dddd, d MMMM")

    component T: BarText {
        font.family: win.fam
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.18)
    }
    // A line cropped to the height of its digits, so stacked lines sit close together
    component Digits: Item {
        property alias text: tx.text
        property alias color: tx.color
        property real px: win.size
        width: tx.implicitWidth
        height: Math.round(px * 0.8)
        T {
            id: tx
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: parent.px
            font.weight: Config.widgetClockWeight
            font.letterSpacing: -Math.round(parent.px * 0.015)
        }
    }

    Item {
        id: stack
        implicitWidth: loader.item ? loader.item.implicitWidth : 0
        implicitHeight: loader.item ? loader.item.implicitHeight : 0
        width: implicitWidth
        height: implicitHeight
        x: win.pos.endsWith("left") ? Theme.barSpaceLeft + 56
         : win.pos.endsWith("right") ? parent.width - width - Theme.barSpaceRight - 56
         : (parent.width - width) / 2
        y: win.pos.startsWith("top") ? Theme.barSpaceTop + 56
         : win.pos.startsWith("bottom") ? parent.height - height - Theme.barSpaceBottom - 90
         : (parent.height - height) / 2

        opacity: 0
        Component.onCompleted: fade.start()
        NumberAnimation on opacity { id: fade; running: false; to: 1; duration: Theme.dur(700); easing.type: Easing.OutCubic }

        Loader {
            id: loader
            visible: Config.widgetClock
            sourceComponent: ({ aurora: aurora, stacked: stacked, analog: analog, glass: glass, line: line })[Config.widgetClockStyle] ?? aurora
        }
    }

    // The wallpaper's subject drawn over the clock, so the clock appears to sit behind it.
    // Same crop as the wallpaper, so it lines up.
    Image {
        anchors.fill: parent
        z: 5
        visible: Config.clockDepth && Config.widgetClock && status === Image.Ready
        source: Config.clockDepth ? "file://" + Depth.file + "?" + Depth.rev : ""
        cache: false
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // ---- aurora: thin two-color time with a soft glow, date underneath ----------
    Component {
        id: aurora
        Column {
            spacing: 8
            Row {
                spacing: 0
                anchors.horizontalCenter: win.centered ? parent.horizontalCenter : undefined
                layer.enabled: !Config.lightMode
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Theme.alpha(Theme.primary, 0.7)
                    shadowBlur: 1.0
                    shadowVerticalOffset: 5
                }
                Digits { text: win.hh; color: win.c1 }
                Digits { text: ":"; color: Qt.rgba(1, 1, 1, 0.5); anchors.verticalCenter: undefined }
                Digits { text: win.mm; color: win.c2 }
                T {
                    visible: win.ap !== ""
                    anchors.baseline: undefined
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Math.round(win.size * 0.1)
                    leftPadding: 10
                    text: win.ap
                    font.pixelSize: Math.round(win.size * 0.2)
                    color: Qt.rgba(1, 1, 1, 0.6)
                }
            }
            T {
                anchors.horizontalCenter: win.centered ? parent.horizontalCenter : undefined
                topPadding: 10
                text: win.dateLong.toUpperCase()
                font.pixelSize: Math.max(13, Math.round(win.size * 0.13))
                font.weight: Font.DemiBold
                font.letterSpacing: 4
                color: Qt.rgba(1, 1, 1, 0.88)
            }
        }
    }

    // ---- stacked: hours over minutes, big and tight --------------------------------
    Component {
        id: stacked
        Column {
            spacing: 0
            Digits { text: win.hh; color: "#ffffff"; px: win.size * 1.15 }
            Row {
                spacing: 10
                Digits { text: win.mm; color: win.c1; px: win.size * 1.15 }
                T {
                    visible: win.ap !== ""
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Math.round(win.size * 0.08)
                    text: win.ap
                    font.pixelSize: Math.round(win.size * 0.22)
                    color: Qt.rgba(1, 1, 1, 0.55)
                }
            }
            T {
                topPadding: 14
                text: win.dateLong
                font.pixelSize: Math.max(14, Math.round(win.size * 0.16))
                font.weight: Font.Medium
                color: Qt.rgba(1, 1, 1, 0.85)
            }
        }
    }

    // ---- analog: round face with ticks, hands and a sweeping second hand --------------
    Component {
        id: analog
        Item {
            implicitWidth: win.size * 2
            implicitHeight: win.size * 2 + 40
            Rectangle {
                id: face
                width: win.size * 2
                height: width
                radius: width / 2
                color: Theme.alpha(Theme.surfaceLow, 0.5)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.2)
                layer.enabled: !Config.lightMode
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.5)
                    shadowBlur: 1.0
                    shadowVerticalOffset: 10
                }
                Repeater {
                    model: 60
                    delegate: Rectangle {
                        required property int index
                        readonly property bool big: index % 5 === 0
                        width: big ? 3 : 1.5
                        height: big ? 12 : 6
                        radius: 1
                        color: big ? "#ffffff" : Qt.rgba(1, 1, 1, 0.4)
                        x: face.width / 2 - width / 2
                        y: 8
                        transform: Rotation { origin.x: width / 2; origin.y: face.height / 2 - 8; angle: index * 6 }
                    }
                }
                Repeater {
                    model: [
                        { len: 0.5, w: 7, col: "#ffffff", ang: (win.now.getHours() % 12 + win.now.getMinutes() / 60) * 30 },
                        { len: 0.72, w: 5, col: win.c1, ang: (win.now.getMinutes() + win.now.getSeconds() / 60) * 6 },
                        { len: 0.8, w: 2, col: win.c2, ang: win.now.getSeconds() * 6, thin: true }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        visible: !modelData.thin || !Config.lowEnd
                        width: modelData.w
                        height: face.height / 2 * modelData.len
                        radius: width / 2
                        color: modelData.col
                        x: face.width / 2 - width / 2
                        y: face.height / 2 - height
                        transform: Rotation { origin.x: width / 2; origin.y: height; angle: modelData.ang
                            Behavior on angle { enabled: !Config.lowEnd && modelData.thin; NumberAnimation { duration: 250 } } }
                    }
                }
                Rectangle { anchors.centerIn: parent; width: 14; height: 14; radius: 7; color: win.c1 }
                Rectangle { anchors.centerIn: parent; width: 5; height: 5; radius: 3; color: Theme.surfaceLow }
            }
            T {
                anchors { horizontalCenter: face.horizontalCenter; top: face.bottom; topMargin: 16 }
                text: win.dateLong
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Qt.rgba(1, 1, 1, 0.85)
            }
        }
    }

    // ---- glass: time and date in one frosted card ------------------------------------
    Component {
        id: glass
        Rectangle {
            implicitWidth: gcol.implicitWidth + 64
            implicitHeight: gcol.implicitHeight + 48
            radius: 34
            color: Theme.alpha(Theme.surfaceLow, 0.5)
            border.width: 1.5
            border.color: Qt.rgba(1, 1, 1, 0.22)
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.16) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.04) }
            }
            layer.enabled: !Config.lightMode
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.5)
                shadowBlur: 1.0
                shadowVerticalOffset: 12
            }
            Column {
                id: gcol
                anchors.centerIn: parent
                spacing: 4
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 0
                    Digits { text: win.hh + ":" + win.mm; color: "#ffffff"; px: win.size * 0.85 }
                    T {
                        visible: win.ap !== ""
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Math.round(win.size * 0.06)
                        leftPadding: 8
                        text: win.ap
                        font.pixelSize: Math.round(win.size * 0.2)
                        color: win.c1
                    }
                }
                T {
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: 8
                    text: win.dateLong
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: win.c1
                }
            }
        }
    }

    // ---- line: one row, time then date -----------------------------------------------
    Component {
        id: line
        Row {
            spacing: 18
            Digits { text: win.hh + ":" + win.mm; color: "#ffffff"; px: win.size * 0.7; anchors.verticalCenter: parent.verticalCenter }
            Rectangle { width: 2; height: win.size * 0.5; radius: 1; color: win.c1; anchors.verticalCenter: parent.verticalCenter }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                T { text: Qt.formatDateTime(win.now, "dddd"); font.pixelSize: Math.round(win.size * 0.2); font.weight: Font.DemiBold; color: "#ffffff" }
                T { text: Qt.formatDateTime(win.now, "d MMMM") + (win.ap !== "" ? "  ·  " + win.ap : ""); font.pixelSize: Math.round(win.size * 0.14); color: win.c1 }
            }
        }
    }
}
