import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs
import qs.modules
import qs.services

// Lock screen: lightly blurred wallpaper, big clock, and a floating card with
// avatar, name and the password field. Pills along the bottom show status and music.
Item {
    id: root

    property bool demo: false
    readonly property bool leftAlign: Config.lockAlign === "left"
    readonly property bool corner: Config.lockAlign === "corner"
    readonly property bool split: Config.lockLayout === "split"
    readonly property bool plainCard: !Config.lockCard
    readonly property string fs: Config.lockFieldStyle   // box | pill | line | dots
    readonly property string home: Quickshell.env("HOME")
    readonly property string user: Quickshell.env("USER")

    function greeting() {
        const h = Time.now.getHours();
        return h >= 5 && h < 12 ? "Good morning" : h >= 12 && h < 18 ? "Good afternoon" : h >= 18 && h < 22 ? "Good evening" : "Good night";
    }

    // ---- background -------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceLow
    }
    // "gradient" background: wallpaper colors instead of the picture
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
        visible: wall.status === Image.Ready
        blurEnabled: Config.lockBlur > 0
        blurMax: 64
        blur: Config.lockBlur / 64
        autoPaddingEnabled: false
    }
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", Config.lockDim)
    }
    // Darker edges so the card and pills read against any wallpaper
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha("#000000", 0.35) }
            GradientStop { position: 0.35; color: "transparent" }
            GradientStop { position: 0.7; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.alpha("#000000", 0.45) }
        }
    }

    // ---- top row: date and status ----------------------------------------
    BarText {
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 40
            topMargin: 30
        }
        visible: Config.lockShowDate && Config.lockClockStyle !== "pixel"
        text: Qt.formatDateTime(Time.now, "dddd, d MMMM")
        font.pixelSize: 16
        color: Qt.rgba(1, 1, 1, 0.92)
    }

    Row {
        visible: Config.lockShowStatus
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: 40
            topMargin: 24
        }
        spacing: 8

        Pill {
            visible: Network.kind !== "none"
            glyph: Network.kind === "ethernet" ? 0xf0200 : 0xf05a9
            label: Network.kind === "wifi" ? Network.name : "wired"
        }
        Pill {
            visible: Config.weatherEnabled && Weather.ready && Config.lockClockStyle !== "pixel"
            label: Weather.glyph + "  " + Weather.temp + Weather.unit
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
        color: Theme.alpha(Theme.surfaceLow, 0.7)
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.8)

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
            }
        }
    }

    // ---- clock + card -----------------------------------------------------
    // stack: clock above the card; split: clock and card side by side
    Grid {
        id: col
        anchors {
            verticalCenter: root.corner ? undefined : parent.verticalCenter
            verticalCenterOffset: -20
            bottom: root.corner ? parent.bottom : undefined
            bottomMargin: 110
            horizontalCenter: root.leftAlign || root.corner ? undefined : parent.horizontalCenter
            left: root.leftAlign || root.corner ? parent.left : undefined
            leftMargin: root.corner ? 70 : 140
        }
        columns: root.split ? 2 : 1
        // lockFieldBottom: the clock stays up top and the password drops to the bottom
        rowSpacing: Config.lockFieldBottom && !root.split
            ? Math.max(26, root.height - 150 - clockBox.height - card.height)
            : 26
        columnSpacing: 90
        horizontalItemAlignment: root.leftAlign || root.corner ? Grid.AlignLeft : Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter

        // Entrance: fade and rise
        opacity: 0
        property real rise: 24
        transform: Translate { y: col.rise }
        Component.onCompleted: enter.start()
        ParallelAnimation {
            id: enter
            NumberAnimation { target: col; property: "opacity"; to: 1; duration: Theme.dur(450); easing.type: Easing.OutCubic }
            NumberAnimation { target: col; property: "rise"; to: 0; duration: Theme.dur(450); easing.type: Easing.OutCubic }
        }

        // The clock: plain text styles here, designed ones in LockClock.qml
        Item {
            id: clockBox
            readonly property bool fancy: ["pixel", "analog", "words", "ring", "flip", "neon", "outline", "editorial", "progress"].includes(Config.lockClockStyle)
            readonly property bool onLeft: root.leftAlign || root.corner
            implicitWidth: fancy ? fancyClock.implicitWidth : clockText.implicitWidth
            implicitHeight: fancy ? fancyClock.implicitHeight : clockText.implicitHeight

            BarText {
                id: clockText
                visible: !clockBox.fancy
                anchors.horizontalCenter: clockBox.onLeft ? undefined : parent.horizontalCenter
                readonly property string hm: Qt.formatDateTime(Time.now, Config.clock24h ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "")
                // "stacked" puts the hours above the minutes
                text: Config.lockClockStyle === "stacked" ? hm.replace(":", "\n") : hm
                lineHeight: Config.lockClockStyle === "stacked" ? 0.82 : 1
                horizontalAlignment: clockBox.onLeft ? Text.AlignLeft : Text.AlignHCenter
                font.pixelSize: Config.lockClockStyle === "small" ? Math.round(Config.lockClockSize * 0.55) : Config.lockClockSize
                font.family: Config.lockClockFont !== "" ? Config.lockClockFont : Theme.font
                font.weight: Config.lockClockWeight
                font.letterSpacing: Config.lockClockSpacing
                color: Config.lockClockAccent ? Theme.primary : "#ffffff"
                style: Text.Outline
                styleColor: Theme.alpha("#000000", 0.25)
            }

            // Every other design lives in LockClock.qml
            LockClock {
                id: fancyClock
                visible: clockBox.fancy
                anchors.horizontalCenter: clockBox.onLeft ? undefined : parent.horizontalCenter
                onLeft: clockBox.onLeft
            }
        }

        Rectangle {
            id: card
            width: Config.lockFieldWidth + 56
            height: cardCol.implicitHeight + 48
            radius: Config.panelRadius + 8
            color: root.plainCard ? "transparent" : Theme.alpha(Theme.surfaceLow, Config.lockCardOpacity)
            border.width: root.plainCard ? 0 : Math.max(1, Config.panelBorder)
            border.color: Theme.alpha(Theme.panelBorderFill, 0.9)

            Column {
                id: cardCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 28
                    topMargin: 24
                }
                spacing: 14

                // Avatar: ~/.face if present, else the initial on an accent circle
                Rectangle {
                    id: avatar
                    visible: Config.lockAvatar
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 84
                    height: 84
                    radius: 42
                    color: Theme.primaryContainer
                    border.width: 3
                    border.color: Theme.primary

                    BarText {
                        anchors.centerIn: parent
                        visible: face.status !== Image.Ready
                        text: root.user.charAt(0).toUpperCase()
                        font.pixelSize: 38
                        font.bold: true
                        color: Theme.primaryContainerFg
                    }
                    Image {
                        id: face
                        anchors.fill: parent
                        anchors.margins: 3
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

                Column {
                    visible: Config.lockAvatar || Config.lockShowGreeting
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 2
                    BarText {
                        visible: Config.lockAvatar
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.user
                        font.pixelSize: 20
                        font.bold: true
                    }
                    BarText {
                        visible: Config.lockShowGreeting
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.greeting() + " · enter your password"
                        font.pixelSize: 13
                        color: Theme.textDim
                    }
                }

                // Password field
                Rectangle {
                    id: field
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Config.lockFieldWidth
                    height: root.fs === "dots" ? 40 : 52
                    radius: root.fs === "pill" ? height / 2 : root.fs === "box" ? Config.panelRadius : 0
                    color: root.fs === "box" || root.fs === "pill" ? Theme.surfaceHigh : "transparent"
                    border.width: root.fs === "box" || root.fs === "pill" ? 2 : 0

                    // "line": an underline that lights up while typing
                    Rectangle {
                        visible: root.fs === "line"
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 2
                        color: Lock.error !== "" ? Theme.error : input.text !== "" ? Theme.primary : Theme.alpha("#ffffff", 0.5)
                    }

                    // "dots": no box, one dot per typed character
                    Row {
                        visible: root.fs === "dots"
                        anchors.centerIn: parent
                        spacing: 10
                        Repeater {
                            model: Math.min(24, input.text.length)
                            delegate: Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: Lock.error !== "" ? Theme.error : Theme.primary
                            }
                        }
                    }
                    BarText {
                        visible: root.fs === "dots" && input.text === ""
                        anchors.centerIn: parent
                        text: Lock.checking ? "Checking…" : "Type your password"
                        color: Qt.rgba(1, 1, 1, 0.65)
                        font.pixelSize: 15
                    }
                    border.color: Lock.error !== "" ? Theme.error : input.activeFocus ? Theme.primary : Theme.alpha(Theme.outlineVariant, 0.9)

                    SequentialAnimation {
                        id: shake
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -14; duration: Theme.dur(50) }
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 14; duration: Theme.dur(80) }
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: Theme.dur(50) }
                    }

                    BarText {
                        id: lockIcon
                        anchors {
                            left: parent.left
                            leftMargin: 16
                            verticalCenter: parent.verticalCenter
                        }
                        visible: root.fs !== "dots"
                        text: Lock.checking ? Theme.icon(0xf0450) : Theme.icon(0xf033e)
                        color: Theme.primary
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
                        opacity: root.fs === "dots" ? 0 : 1
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        enabled: !Lock.checking
                        focus: true
                        color: Theme.text
                        placeholderText: Lock.checking ? "Checking…" : "Password"
                        placeholderTextColor: Theme.alpha(Theme.text, 0.45)
                        font.family: Theme.font
                        font.pixelSize: 16
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

                    // Submit arrow
                    Rectangle {
                        id: submit
                        visible: root.fs !== "dots"
                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        width: 36
                        height: 36
                        radius: root.fs === "pill" ? height / 2 : Math.max(0, Config.panelRadius - 4)
                        color: input.text !== "" ? Theme.primary : root.fs === "line" ? "transparent" : Theme.surfaceHighest

                        Behavior on color {
                            ColorAnimation { duration: Theme.dur(150) }
                        }

                        BarText {
                            anchors.centerIn: parent
                            text: Theme.icon(0xf0054)
                            font.pixelSize: 18
                            color: input.text !== "" ? Theme.primaryFg : Theme.textDim
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: input.accepted()
                        }
                    }
                }

                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 18
                    text: Lock.error !== "" ? Lock.error : root.demo ? "Preview: Enter or Esc closes it" : "Esc clears the field"
                    color: Lock.error !== "" ? Theme.error : Theme.alpha(Theme.textDim, 0.8)
                    font.pixelSize: 12
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
        color: Theme.alpha(Theme.surfaceLow, 0.78)
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.8)

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
