import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.modules
import qs.services

// Lock screen: lightly blurred wallpaper, weather and a big stacked clock on the left,
// a column of cards on the right (sign-in, music, notifications), status pills at the
// top and a small power dock at the bottom.
Item {
    id: root

    property bool demo: false
    readonly property string home: Quickshell.env("HOME")
    readonly property string user: Quickshell.env("USER")
    readonly property bool hasWall: wall.status === Image.Ready
    readonly property color c1: Qt.lighter(Theme.primary, 1.3)
    // "Clock behind the subject": big centered clock, the wallpaper subject drawn over it
    // The layout is used for every wallpaper; the cut-out is only drawn when one could be made
    readonly property bool depth: Config.clockDepth
    readonly property bool cutReady: Config.clockDepth && !Depth.stale && cutout.status === Image.Ready
    readonly property color cardColor: Theme.alpha(Theme.surfaceLow, 0.9)
    readonly property int edge: 48
    readonly property real s: Math.max(0.7, Math.min(1.3, root.height / 900))

    function greeting() {
        const h = Time.now.getHours();
        return h >= 5 && h < 12 ? "Good morning" : h >= 12 && h < 18 ? "Good afternoon" : h >= 18 && h < 22 ? "Good evening" : "Good night";
    }
    function mmss(sec) {
        const t = Math.max(0, Math.floor(sec));
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0");
    }

    // ---- background -------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceLow
    }
    Rectangle {
        anchors.fill: parent
        visible: Config.lockBackground === "gradient"
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Theme.primaryContainer }
            GradientStop { position: 0.55; color: Theme.surfaceLow }
            GradientStop { position: 1.0; color: Theme.tertiaryContainer }
        }
    }
    Image {
        id: wall
        anchors.fill: parent
        visible: false
        source: Config.lockWallpaper && Config.lockBackground === "wallpaper" ? "file://" + root.home + "/.cache/lockscreen.png?" + Wallpapers.imageRev : ""
        cache: false
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    MultiEffect {
        anchors.fill: parent
        source: wall
        visible: root.hasWall
        blurEnabled: Config.lockBlur > 0 && !Config.lowEnd && !root.cutReady
        blurMax: 64
        blur: (Config.performance === "light" ? Math.min(Config.lockBlur, 12) : Config.lockBlur) / 64
        autoPaddingEnabled: false
    }
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", Config.lockDim)
    }
    // A little darker at the corners so text reads on any wallpaper
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha("#000000", 0.25) }
            GradientStop { position: 0.3; color: "transparent" }
            GradientStop { position: 0.75; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.alpha("#000000", 0.3) }
        }
    }

    // ---- top left: weather -------------------------------------------------
    Row {
        id: wx
        z: 2
        visible: Config.lockShowDate && Config.weatherEnabled && Weather.ready
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: root.edge
            topMargin: 36
        }
        spacing: 12
        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.glyph
            font.pixelSize: 38
            color: root.c1
        }
        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.temp + "°"
            font.pixelSize: 28
            font.weight: Font.Medium
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 34
            color: Qt.rgba(1, 1, 1, 0.3)
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            BarText { text: Weather.desc; font.pixelSize: 14; font.weight: Font.Medium }
            BarText {
                text: Weather.forecast.length > 0
                    ? "H " + Weather.forecast[0].max + "°  L " + Weather.forecast[0].min + "°  ·  feels " + Weather.feels + "°"
                    : "feels " + Weather.feels + "°"
                font.pixelSize: 12
                color: Qt.rgba(1, 1, 1, 0.7)
            }
        }
    }

    // ---- top right: status pills ----------------------------------------
    Row {
        z: 2
        visible: Config.lockShowStatus
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: root.edge
            topMargin: 34
        }
        spacing: 8

        Pill {
            visible: Battery.available
            glyph: Battery.charging ? 0xf0084 : 0xf0079
            label: Battery.percent + "%"
        }
        Pill {
            visible: Network.kind !== "none"
            glyph: Network.kind === "ethernet" ? 0xf0200 : 0xf05a9
            label: Network.kind === "wifi" ? Network.name : "wired"
        }
        Pill {
            readonly property bool on: !!Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
            glyph: on ? 0xf00af : 0xf00b2
            label: on ? "Bluetooth on" : "Bluetooth off"
        }
    }

    component Pill: Rectangle {
        property int glyph: 0
        property string label: ""
        height: 36
        width: pillRow.implicitWidth + 26
        radius: 12
        color: root.cardColor

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 8
            BarText {
                visible: glyph > 0
                text: Theme.icon(glyph)
                color: root.c1
                font.pixelSize: 15
            }
            BarText {
                text: label
                font.pixelSize: 13
            }
        }
    }

    // ---- left: the clock -----------------------------------------------------
    Column {
        id: clockCol
        visible: !root.depth
        anchors {
            left: parent.left
            leftMargin: root.edge
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -Math.round(root.height * 0.05)
        }
        spacing: 0
        opacity: 0
        property real rise: 24
        transform: Translate { y: clockCol.rise }

        readonly property string fam: Config.lockClockFont !== "" ? Config.lockClockFont : "Outfit"
        readonly property string hh: Config.clock24h ? Qt.formatDateTime(Time.now, "HH") : String(Time.now.getHours() % 12 === 0 ? 12 : Time.now.getHours() % 12)
        readonly property string mm: Qt.formatDateTime(Time.now, "mm")
        readonly property int sz: Math.round(Config.lockClockSize * root.s)

        // Each line is cropped to the height of its digits so the two sit close together
        Item {
            width: hoursText.implicitWidth
            height: Math.round(clockCol.sz * 0.78)
            BarText {
                id: hoursText
                anchors.verticalCenter: parent.verticalCenter
                text: clockCol.hh
                font.family: clockCol.fam
                font.pixelSize: clockCol.sz
                font.weight: Config.lockClockWeight
                font.letterSpacing: Config.lockClockSpacing
                color: "#ffffff"
            }
        }
        Row {
            spacing: 10
            Item {
                width: minText.implicitWidth
                height: Math.round(clockCol.sz * 0.78)
                BarText {
                    id: minText
                    anchors.verticalCenter: parent.verticalCenter
                    text: clockCol.mm
                    font.family: clockCol.fam
                    font.pixelSize: clockCol.sz
                    font.weight: Config.lockClockWeight
                    font.letterSpacing: Config.lockClockSpacing
                    color: root.c1
                }
            }
            BarText {
                visible: !Config.clock24h
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Math.round(clockCol.sz * 0.06)
                text: Qt.formatDateTime(Time.now, "AP")
                font.pixelSize: Math.round(clockCol.sz * 0.2)
                color: Qt.rgba(1, 1, 1, 0.55)
            }
        }
        BarText {
            visible: Config.lockShowDate
            topPadding: 14
            text: Qt.formatDateTime(Time.now, "dddd, d MMMM")
            font.pixelSize: 17
            font.weight: Font.Medium
            color: Qt.rgba(1, 1, 1, 0.8)
        }
        BarText {
            visible: Config.lockShowGreeting
            text: root.greeting() + ", " + root.user
            font.pixelSize: 14
            color: Qt.rgba(1, 1, 1, 0.6)
        }
    }

    // ---- depth clock: iOS-style, behind the subject ----------------------------------
    Column {
        id: depthClock
        visible: root.depth
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Math.round(root.height * 0.07)
        }
        spacing: 0
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(Time.now, "ddd MMM d")
            font.family: clockCol.fam
            font.pixelSize: Math.round(root.height * 0.032)
            font.weight: Font.DemiBold
            color: Qt.rgba(1, 1, 1, 0.9)
        }
        BarText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clockCol.hh + ":" + clockCol.mm
            font.family: clockCol.fam
            font.pixelSize: Math.round(root.height * 0.3)
            font.weight: Font.DemiBold
            color: "#ffffff"
        }
    }
    Image {
        id: cutout
        anchors.fill: parent
        visible: !Depth.stale
        source: Config.clockDepth ? "file://" + Depth.file + "?" + Depth.rev + "-" + Wallpapers.imageRev : ""
        cache: false
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // ---- right: cards -----------------------------------------------------------
    Column {
        id: cards
        anchors {
            right: parent.right
            rightMargin: root.edge
            verticalCenter: parent.verticalCenter
        }
        width: Math.round(400 * Math.max(0.85, root.s))
        spacing: 14
        opacity: 0
        property real rise: 30
        transform: Translate { y: cards.rise }

        // sign in
        Rectangle {
            id: login
            width: parent.width
            height: loginCol.implicitHeight + 44
            radius: 26
            color: root.cardColor

            Column {
                id: loginCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 22
                    topMargin: 26
                }
                spacing: 12

                Rectangle {
                    id: avatar
                    visible: Config.lockAvatar
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 76
                    height: 76
                    radius: 38
                    color: Theme.primaryContainer

                    BarText {
                        anchors.centerIn: parent
                        visible: face.status !== Image.Ready
                        text: root.user.charAt(0).toUpperCase()
                        font.pixelSize: 34
                        font.bold: true
                        color: Theme.primaryContainerFg
                    }
                    Image {
                        id: face
                        anchors.fill: parent
                        source: "file://" + root.home + "/.face"
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: false
                    }
                    MultiEffect {
                        anchors.fill: face
                        source: face
                        visible: face.status === Image.Ready
                        maskEnabled: true
                        maskSource: faceMask
                    }
                    Rectangle {
                        id: faceMask
                        anchors.fill: face
                        radius: width / 2
                        visible: false
                        layer.enabled: true
                    }
                }
                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.user
                    font.pixelSize: 20
                    font.weight: Font.Medium
                }

                // password
                Rectangle {
                    id: field
                    width: parent.width
                    height: 52
                    radius: 26
                    color: Theme.surfaceHigh
                    border.width: 2
                    border.color: Lock.error !== "" ? Theme.error : input.activeFocus ? Theme.alpha(root.c1, 0.9) : "transparent"
                    Behavior on border.color {
                        ColorAnimation { duration: Theme.dur(150) }
                    }

                    SequentialAnimation {
                        id: shake
                        NumberAnimation { target: field; property: "x"; to: -12; duration: Theme.dur(50) }
                        NumberAnimation { target: field; property: "x"; to: 12; duration: Theme.dur(80) }
                        NumberAnimation { target: field; property: "x"; to: 0; duration: Theme.dur(50) }
                    }

                    BarText {
                        id: lockIcon
                        anchors {
                            left: parent.left
                            leftMargin: 18
                            verticalCenter: parent.verticalCenter
                        }
                        text: Lock.checking ? Theme.icon(0xf0450) : Theme.icon(0xf033e)
                        color: Theme.textDim
                        font.pixelSize: 18
                    }
                    TextField {
                        id: input
                        anchors {
                            left: lockIcon.right
                            right: submit.left
                            leftMargin: 10
                            rightMargin: 6
                            verticalCenter: parent.verticalCenter
                        }
                        background: null
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        enabled: !Lock.checking
                        focus: true
                        color: Theme.text
                        placeholderText: Lock.checking ? "Checking…" : "Password"
                        placeholderTextColor: Theme.alpha(Theme.text, 0.5)
                        font.family: Theme.font
                        font.pixelSize: 15
                        selectionColor: Theme.primary
                        selectedTextColor: Theme.primaryFg
                        onAccepted: {
                            Lock.submit(text);
                            if (Lock.preview)
                                text = "";
                        }
                        onTextChanged: if (Lock.error !== "") Lock.error = ""

                        Keys.onEscapePressed: {
                            if (text !== "")
                                text = "";
                            else if (root.demo)
                                Lock.unlock();
                        }
                        Connections {
                            target: Lock
                            function onFailed() {
                                input.text = "";
                                shake.restart();
                                input.forceActiveFocus();
                            }
                        }
                        Component.onCompleted: forceActiveFocus()
                    }
                    Rectangle {
                        id: submit
                        anchors {
                            right: parent.right
                            rightMargin: 7
                            verticalCenter: parent.verticalCenter
                        }
                        width: 38
                        height: 38
                        radius: 19
                        color: input.text !== "" ? root.c1 : Theme.surfaceHighest
                        scale: submitMouse.pressed ? 0.92 : 1
                        Behavior on color {
                            ColorAnimation { duration: Theme.dur(150) }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: Theme.dur(90) }
                        }
                        BarText {
                            anchors.centerIn: parent
                            text: Theme.icon(0xf0054)
                            font.pixelSize: 18
                            color: input.text !== "" ? Theme.primaryFg : Theme.textDim
                        }
                        MouseArea {
                            id: submitMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: input.accepted()
                        }
                    }
                }
                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 16
                    text: Lock.error !== "" ? Lock.error : root.demo ? "Preview: Enter or Esc closes it" : "Esc clears the field"
                    color: Lock.error !== "" ? Theme.error : Theme.alpha(Theme.textDim, 0.8)
                    font.pixelSize: 12
                }
            }
        }

        // music
        Rectangle {
            visible: Config.lockShowMedia && Media.available
            width: parent.width
            height: 112
            radius: 26
            color: root.cardColor

            Rectangle {
                id: art
                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                width: 80
                height: 80
                radius: 16
                clip: true
                color: Theme.tertiaryContainer
                Image {
                    anchors.fill: parent
                    source: Media.art
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }
                BarText {
                    anchors.centerIn: parent
                    visible: Media.art === ""
                    text: Theme.icon(0xf075a)
                    color: Theme.tertiaryContainerFg
                    font.pixelSize: 26
                }
            }
            Column {
                anchors {
                    left: art.right
                    leftMargin: 14
                    right: ctl.left
                    rightMargin: 8
                    top: art.top
                }
                spacing: 1
                BarText { width: parent.width; text: Media.title; font.pixelSize: 14; font.weight: Font.Medium; elide: Text.ElideRight }
                BarText { width: parent.width; text: Media.artist; font.pixelSize: 12; color: Theme.textDim; elide: Text.ElideRight }
            }
            Row {
                id: ctl
                anchors {
                    right: parent.right
                    rightMargin: 14
                    top: art.top
                }
                Chip { icon: Theme.icon(0xf04ae); onLeftClicked: Media.previous() }
                Chip { icon: Media.playing ? Theme.icon(0xf03e4) : Theme.icon(0xf040a); onLeftClicked: Media.toggle() }
                Chip { icon: Theme.icon(0xf04ad); onLeftClicked: Media.next() }
            }
            Rectangle {
                id: track
                anchors {
                    left: art.right
                    leftMargin: 14
                    right: parent.right
                    rightMargin: 18
                    bottom: art.bottom
                    bottomMargin: 16
                }
                height: 3
                radius: 2
                color: Theme.alpha(Theme.text, 0.18)
                Rectangle {
                    width: parent.width * Media.progress
                    height: parent.height
                    radius: 2
                    color: root.c1
                }
            }
            BarText {
                anchors { left: track.left; top: track.bottom; topMargin: 4 }
                text: Media.player ? root.mmss(Media.player.position) : ""
                font.pixelSize: 10
                color: Theme.textDim
            }
            BarText {
                anchors { right: track.right; top: track.bottom; topMargin: 4 }
                text: Media.player && Media.player.length > 0 ? root.mmss(Media.player.length) : ""
                font.pixelSize: 10
                color: Theme.textDim
            }
        }

        // notifications
        Rectangle {
            width: parent.width
            height: notifCol.implicitHeight + 34
            radius: 26
            color: root.cardColor

            Column {
                id: notifCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 20
                    topMargin: 18
                }
                spacing: 10
                BarText { text: "Notifications"; font.pixelSize: 13; font.weight: Font.Medium }

                Column {
                    visible: Notifs.count === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    topPadding: 10
                    bottomPadding: 6
                    BarText { anchors.horizontalCenter: parent.horizontalCenter; text: Theme.icon(0xf009c); font.pixelSize: 24; color: Theme.textDim }
                    BarText { anchors.horizontalCenter: parent.horizontalCenter; text: "You are all caught up"; font.pixelSize: 12; color: Theme.textDim }
                }
                Repeater {
                    model: Math.min(3, Notifs.count)
                    delegate: Row {
                        required property int index
                        readonly property var n: Notifs.list[Notifs.count - 1 - index]
                        width: notifCol.width
                        spacing: 10
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 8; height: 8; radius: 4
                            color: root.c1
                        }
                        Column {
                            width: parent.width - 18
                            BarText { width: parent.width; text: n ? n.summary : ""; font.pixelSize: 13; font.weight: Font.Medium; elide: Text.ElideRight }
                            BarText { width: parent.width; text: n ? n.appName : ""; font.pixelSize: 11; color: Theme.textDim; elide: Text.ElideRight }
                        }
                    }
                }
            }
        }
    }

    // ---- bottom left: power dock (tap twice) ------------------------------------
    Rectangle {
        id: dock
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: root.edge
            bottomMargin: 40
        }
        width: dockRow.implicitWidth + 28
        height: 54
        radius: 27
        color: root.cardColor
        opacity: 0

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 6
            Repeater {
                model: [
                    { g: 0xf0594, cmd: ["systemctl", "suspend"] },
                    { g: 0xf0717, cmd: ["systemctl", "hibernate"] },
                    { g: 0xf0343, cmd: ["sh", "-c", "hyprctl dispatch 'hl.dsp.exit()' | grep -q ok || hyprctl dispatch exit"] },
                    { g: 0xf0709, cmd: ["systemctl", "reboot"] },
                    { g: 0xf0425, cmd: ["systemctl", "poweroff"], warm: true }
                ]
                delegate: Rectangle {
                    id: pb
                    required property var modelData
                    property bool armed: false
                    width: 40
                    height: 40
                    radius: 20
                    color: armed ? Theme.alpha(Theme.error, 0.9) : pbMouse.containsMouse ? Theme.surfaceHigh : "transparent"
                    Behavior on color {
                        ColorAnimation { duration: Theme.dur(120) }
                    }
                    Timer {
                        id: disarm
                        interval: 2500
                        onTriggered: pb.armed = false
                    }
                    BarText {
                        anchors.centerIn: parent
                        text: Theme.icon(pb.modelData.g)
                        font.pixelSize: 19
                        color: pb.armed ? Theme.errorFg : pb.modelData.warm ? Theme.error : Theme.text
                    }
                    MouseArea {
                        id: pbMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (pb.armed) {
                                pb.armed = false;
                                Quickshell.execDetached(pb.modelData.cmd);
                            } else {
                                pb.armed = true;
                                disarm.restart();
                            }
                        }
                    }
                }
            }
        }
    }

    // Entrance: the clock fades down, the cards and dock fade in after it
    Component.onCompleted: enter.start()
    ParallelAnimation {
        id: enter
        NumberAnimation { target: clockCol; property: "opacity"; to: 1; duration: Theme.dur(500); easing.type: Easing.OutCubic }
        NumberAnimation { target: clockCol; property: "rise"; to: 0; duration: Theme.dur(500); easing.type: Easing.OutCubic }
        SequentialAnimation {
            PauseAnimation { duration: Theme.dur(120) }
            ParallelAnimation {
                NumberAnimation { target: cards; property: "opacity"; to: 1; duration: Theme.dur(450); easing.type: Easing.OutCubic }
                NumberAnimation { target: cards; property: "rise"; to: 0; duration: Theme.dur(450); easing.type: Easing.OutCubic }
                NumberAnimation { target: dock; property: "opacity"; to: 1; duration: Theme.dur(450); easing.type: Easing.OutCubic }
            }
        }
    }
}
