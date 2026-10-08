import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import qs
import qs.modules
import qs.services

// Lock screen "Aurora": blurred wallpaper with slow color glows, a big thin clock with a
// glow, and one frosted pill at the bottom holding your picture and the password field.
Item {
    id: root

    property bool demo: false
    readonly property string home: Quickshell.env("HOME")
    readonly property string user: Quickshell.env("USER")
    readonly property bool hasWall: wall.status === Image.Ready
    readonly property color c1: Qt.lighter(Theme.primary, 1.3)
    readonly property color c2: Qt.lighter(Theme.tertiary, 1.25)

    function greeting() {
        const h = Time.now.getHours();
        return h >= 5 && h < 12 ? "Good morning" : h >= 12 && h < 18 ? "Good afternoon" : h >= 18 && h < 22 ? "Good evening" : "Good night";
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
        id: bg
        anchors.fill: parent
        source: wall
        visible: root.hasWall
        blurEnabled: Config.lockBlur > 0
        blurMax: 64
        blur: Config.lockBlur / 64
        saturation: 0.15
        autoPaddingEnabled: false
    }
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", Config.lockDim)
    }

    // Two big color glows in the wallpaper colors, drifting slowly
    Item {
        id: glows
        anchors.fill: parent
        visible: Config.lockGlow
        property real drift: 0
        SequentialAnimation on drift {
            running: Config.lockGlow
            loops: Animation.Infinite
            NumberAnimation { to: 1; duration: 16000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: 16000; easing.type: Easing.InOutSine }
        }
        Glow {
            size: root.width * 1.0
            tint: Theme.primary
            strength: 0.55
            x: -size * 0.25 + glows.drift * root.width * 0.14
            y: -size * 0.45
        }
        Glow {
            size: root.width * 0.9
            tint: Theme.tertiary
            strength: 0.5
            x: root.width - size * 0.7 - glows.drift * root.width * 0.12
            y: root.height - size * 0.6
        }
    }
    component Glow: Shape {
        property real size: 800
        property color tint: "white"
        property real strength: 0.5
        width: size
        height: size
        ShapePath {
            strokeWidth: -1
            fillGradient: RadialGradient {
                centerX: size / 2; centerY: size / 2; centerRadius: size / 2
                focalX: centerX; focalY: centerY
                GradientStop { position: 0.0; color: Theme.alpha(tint, strength) }
                GradientStop { position: 0.55; color: Theme.alpha(tint, strength * 0.35) }
                GradientStop { position: 1.0; color: "transparent" }
            }
            startX: 0; startY: 0
            PathLine { x: size; y: 0 }
            PathLine { x: size; y: size }
            PathLine { x: 0; y: size }
        }
    }
    // Vignette: darker top and bottom so text always reads
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha("#000000", 0.4) }
            GradientStop { position: 0.3; color: "transparent" }
            GradientStop { position: 0.65; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.alpha("#000000", 0.55) }
        }
    }

    // ---- status pills, top right -----------------------------------------
    Row {
        visible: Config.lockShowStatus
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: 40
            topMargin: 28
        }
        spacing: 8

        Pill {
            visible: Network.kind !== "none"
            glyph: Network.kind === "ethernet" ? 0xf0200 : 0xf05a9
            label: Network.kind === "wifi" ? Network.name : "wired"
        }
        Pill {
            visible: Battery.available
            glyph: Battery.charging ? 0xf0084 : 0xf0079
            label: Battery.percent + "%"
        }
    }

    component Pill: Rectangle {
        property int glyph: 0
        property string label: ""
        height: 34
        width: pillRow.implicitWidth + 24
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.2)

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 8
            BarText {
                visible: glyph > 0
                text: Theme.icon(glyph)
                color: Theme.primary
                font.pixelSize: 15
            }
            BarText {
                visible: label !== ""
                text: label
                font.pixelSize: 13
                color: Qt.rgba(1, 1, 1, 0.95)
            }
        }
    }

    // ---- clock ------------------------------------------------------------
    Column {
        id: clockCol
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Math.round(root.height * 0.15)
        }
        spacing: 0
        opacity: 0
        property real rise: 28
        readonly property bool typing: input.text !== ""
        transform: [
            Translate { y: clockCol.rise },
            Scale { origin.x: clockCol.width / 2; origin.y: 0; xScale: clockCol.typing ? 0.94 : 1; yScale: xScale
                Behavior on xScale { NumberAnimation { duration: Theme.dur(300); easing.type: Easing.OutCubic } } }
        ]

        // The time: thin digits, hours and minutes in the two wallpaper colors, with a soft glow
        Row {
            id: timeRow
            anchors.horizontalCenter: parent.horizontalCenter
            readonly property string hm: Qt.formatDateTime(Time.now, Config.clock24h ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "")
            readonly property int colon: hm.indexOf(":")
            readonly property string fam: Config.lockClockFont !== "" ? Config.lockClockFont : "Outfit"
            spacing: 0
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Theme.alpha(Theme.primary, 0.75)
                shadowBlur: 1.0
                shadowOpacity: 0.9
                shadowVerticalOffset: 6
            }
            Repeater {
                model: [
                    { t: timeRow.hm.substring(0, timeRow.colon), c: root.c1 },
                    { t: ":", c: Qt.rgba(1, 1, 1, 0.55) },
                    { t: timeRow.hm.substring(timeRow.colon + 1), c: root.c2 }
                ]
                delegate: BarText {
                    required property var modelData
                    text: modelData.t
                    color: modelData.c
                    font.family: timeRow.fam
                    font.pixelSize: Config.lockClockSize
                    font.weight: Config.lockClockWeight
                    font.letterSpacing: Config.lockClockSpacing
                    bottomPadding: modelData.t === ":" ? Math.round(Config.lockClockSize * 0.08) : 0
                }
            }
        }
        // A thin line that fills with the seconds
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.round(timeRow.width * 0.42)
            height: 2
            SystemClock {
                id: secClock
                precision: SystemClock.Seconds
            }
            Rectangle { anchors.fill: parent; radius: 1; color: Qt.rgba(1, 1, 1, 0.14) }
            Rectangle {
                height: parent.height
                radius: 1
                width: parent.width * (secClock.date.getSeconds() + 1) / 60
                color: root.c1
                Behavior on width { NumberAnimation { duration: Theme.dur(300) } }
            }
        }

        // Date and weather as two glass chips under the time
        Row {
            visible: Config.lockShowDate
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 14
            spacing: 10
            Repeater {
                model: [
                    { t: Qt.formatDateTime(Time.now, "dddd, d MMMM"), g: 0xf00ed, show: true },
                    { t: Weather.glyph + "  " + Weather.temp + "°  " + Weather.desc, g: 0, show: Config.weatherEnabled && Weather.ready }
                ]
                delegate: Rectangle {
                    required property var modelData
                    visible: modelData.show
                    height: 36
                    width: chipRow.implicitWidth + 28
                    radius: 18
                    color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.2)
                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 8
                        BarText {
                            visible: modelData.g > 0
                            text: Theme.icon(modelData.g)
                            color: root.c1
                            font.pixelSize: 15
                        }
                        BarText {
                            text: modelData.t
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: Qt.rgba(1, 1, 1, 0.95)
                        }
                    }
                }
            }
        }
    }

    // ---- frosted pill: picture, password, submit ---------------------------
    Item {
        id: dock
        width: Math.max(440, Config.lockFieldWidth + 100)
        height: 76
        x: Math.round((root.width - width) / 2)
        y: root.height - height - Math.round(root.height * (Config.lockShowMedia && Media.available ? 0.23 : 0.17))
        opacity: 0
        property real rise: 36
        property real pulse: 0
        transform: Translate { y: dock.rise }
        SequentialAnimation on pulse {
            running: input.activeFocus
            loops: Animation.Infinite
            NumberAnimation { to: 1; duration: 1800; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: 1800; easing.type: Easing.InOutSine }
        }

        // Glass: soft shadow, a darkened base and a light-to-clear gradient with a lit rim
        Rectangle {
            id: glass
            anchors.fill: parent
            radius: height / 2
            color: Theme.alpha("#000000", root.hasWall ? 0.28 : 0.0)
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Theme.alpha("#000000", 0.55)
                shadowBlur: 1.0
                shadowVerticalOffset: 14
            }
        }
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, root.hasWall ? 0.2 : 0.12) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, root.hasWall ? 0.05 : 0.03) }
            }
            border.width: 1.5
            border.color: Lock.error !== "" ? Theme.error : input.activeFocus ? Theme.alpha(root.c1, 0.55 + 0.4 * dock.pulse) : Qt.rgba(1, 1, 1, 0.24)
        }
        // Thin highlight along the top edge
        Rectangle {
            anchors {
                top: parent.top
                topMargin: 1
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - parent.height
            height: 1
            color: Qt.rgba(1, 1, 1, 0.35)
        }

        SequentialAnimation {
            id: shake
            NumberAnimation { target: dock; property: "x"; to: Math.round((root.width - dock.width) / 2) - 14; duration: Theme.dur(50) }
            NumberAnimation { target: dock; property: "x"; to: Math.round((root.width - dock.width) / 2) + 14; duration: Theme.dur(80) }
            NumberAnimation { target: dock; property: "x"; to: Math.round((root.width - dock.width) / 2); duration: Theme.dur(50) }
        }

        // Avatar: ~/.face if present, else the initial
        Rectangle {
            id: avatar
            visible: Config.lockAvatar
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }
            width: 52
            height: 52
            radius: 26
            color: Theme.primaryContainer
            border.width: 2
            border.color: root.c1

            BarText {
                anchors.centerIn: parent
                visible: face.status !== Image.Ready
                text: root.user.charAt(0).toUpperCase()
                font.pixelSize: 24
                font.bold: true
                color: Theme.primaryContainerFg
            }
            Image {
                id: face
                anchors.fill: parent
                anchors.margins: 2
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

        TextField {
            id: input
            anchors {
                left: Config.lockAvatar ? avatar.right : parent.left
                right: submit.left
                leftMargin: Config.lockAvatar ? 14 : 28
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            background: null
            echoMode: TextInput.Password
            passwordCharacter: "●"
            enabled: !Lock.checking
            focus: true
            color: "#ffffff"
            placeholderText: Lock.checking ? "Checking…" : "Enter password"
            placeholderTextColor: Qt.rgba(1, 1, 1, 0.55)
            font.family: Theme.font
            font.pixelSize: 17
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
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            width: 52
            height: 52
            radius: 26
            color: input.text !== "" ? root.c1 : Qt.rgba(1, 1, 1, 0.14)
            scale: submitMouse.pressed ? 0.92 : 1

            Behavior on color {
                ColorAnimation { duration: Theme.dur(150) }
            }
            Behavior on scale {
                NumberAnimation { duration: Theme.dur(90) }
            }

            BarText {
                anchors.centerIn: parent
                text: Lock.checking ? Theme.icon(0xf0450) : Theme.icon(0xf0054)
                font.pixelSize: 22
                color: input.text !== "" ? Theme.primaryFg : "#ffffff"
            }
            MouseArea {
                id: submitMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: input.accepted()
            }
        }
    }

    // Greeting above and hint below the pill
    BarText {
        visible: Config.lockShowGreeting
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: dock.top
            bottomMargin: 16
        }
        opacity: dock.opacity
        text: root.greeting() + ", " + root.user
        font.pixelSize: 18
        font.weight: Font.Medium
        color: Qt.rgba(1, 1, 1, 0.92)
    }
    BarText {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: dock.bottom
            topMargin: 14
        }
        opacity: dock.opacity
        text: Lock.error !== "" ? Lock.error : root.demo ? "Preview: Enter or Esc closes it" : "Esc clears the field"
        color: Lock.error !== "" ? Theme.error : Qt.rgba(1, 1, 1, 0.6)
        font.pixelSize: 12
    }

    // Entrance: the clock fades down into place, then the pill rises
    Component.onCompleted: enter.start()
    SequentialAnimation {
        id: enter
        ParallelAnimation {
            NumberAnimation { target: clockCol; property: "opacity"; to: 1; duration: Theme.dur(550); easing.type: Easing.OutCubic }
            NumberAnimation { target: clockCol; property: "rise"; to: 0; duration: Theme.dur(550); easing.type: Easing.OutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: dock; property: "opacity"; to: 1; duration: Theme.dur(400); easing.type: Easing.OutCubic }
            NumberAnimation { target: dock; property: "rise"; to: 0; duration: Theme.dur(400); easing.type: Easing.OutCubic }
        }
    }

    // ---- bottom right: sleep, restart, shut down (tap twice) ----------------
    Row {
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 40
            bottomMargin: 30
        }
        spacing: 10
        Repeater {
            model: [
                { g: 0xf0904, cmd: ["systemctl", "suspend"], tip: "Sleep" },
                { g: 0xf0709, cmd: ["systemctl", "reboot"], tip: "Restart" },
                { g: 0xf0425, cmd: ["systemctl", "poweroff"], tip: "Shut down" }
            ]
            delegate: Rectangle {
                id: pb
                required property var modelData
                property bool armed: false
                width: 44
                height: 44
                radius: 22
                color: armed ? Theme.alpha(Theme.error, 0.85) : pbMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.24) : Qt.rgba(1, 1, 1, 0.12)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.2)
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
                    color: pb.armed ? Theme.errorFg : "#ffffff"
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

    // ---- bottom: now playing ---------------------------------------------
    Rectangle {
        id: music
        visible: Config.lockShowMedia && Media.available
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 34
        }
        height: 56
        width: Math.min(420, musicRow.implicitWidth + 28)
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.2)

        Row {
            id: musicRow
            anchors.centerIn: parent
            spacing: 12

            Rectangle {
                width: 40
                height: 40
                radius: 20
                clip: true
                color: Theme.tertiaryContainer
                anchors.verticalCenter: parent.verticalCenter

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
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(220, Math.max(titleText.implicitWidth, artistText.implicitWidth))
                BarText {
                    id: titleText
                    width: parent.width
                    text: Media.title
                    font.bold: true
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
                BarText {
                    id: artistText
                    width: parent.width
                    text: Media.artist
                    font.pixelSize: 11
                    color: Theme.textDim
                    elide: Text.ElideRight
                }
            }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                Chip {
                    icon: Theme.icon(0xf04ae)
                    onLeftClicked: Media.previous()
                }
                Chip {
                    icon: Media.playing ? Theme.icon(0xf03e4) : Theme.icon(0xf040a)
                    onLeftClicked: Media.toggle()
                }
                Chip {
                    icon: Theme.icon(0xf04ad)
                    onLeftClicked: Media.next()
                }
            }
        }
    }
}
