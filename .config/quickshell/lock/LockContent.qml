import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs
import qs.modules
import qs.services

// Lock screen contents: blurred wallpaper, clock, greeting, password field
Item {
    id: root

    property bool demo: false
    readonly property bool leftAlign: Config.lockAlign === "left"
    readonly property string home: Quickshell.env("HOME")

    function greeting() {
        const h = Time.now.getHours();
        const g = h >= 5 && h < 12 ? "Good morning" : h < 18 && h >= 12 ? "Good afternoon" : h >= 18 && h < 22 ? "Good evening" : "Good night";
        return g + ", " + Quickshell.env("USER");
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceLow
    }

    Image {
        id: wall
        anchors.fill: parent
        visible: false
        source: Config.lockWallpaper ? "file://" + root.home + "/.cache/lockscreen.png" : ""
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

    Column {
        id: col
        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -30
            horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
            left: root.leftAlign ? parent.left : undefined
            leftMargin: 120
        }
        spacing: 6

        BarText {
            anchors.horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
            text: Qt.formatDateTime(Time.now, Config.clock24h ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "")
            font.pixelSize: Config.lockClockSize
            font.bold: true
            color: Theme.text
        }
        BarText {
            visible: Config.lockShowDate
            anchors.horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
            text: Qt.formatDateTime(Time.now, "dddd, d MMMM")
            font.pixelSize: 20
            color: Theme.primary
        }
        BarText {
            visible: Config.lockShowGreeting
            anchors.horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
            text: root.greeting()
            font.pixelSize: 14
            color: Theme.textDim
        }
        Item {
            width: 1
            height: 18
        }

        // Password field
        Rectangle {
            id: field
            anchors.horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
            width: Config.lockFieldWidth
            height: 56
            radius: Config.panelRadius
            color: Theme.panelFill
            border.width: Math.max(2, Config.panelBorder)
            border.color: Lock.error !== "" ? Theme.error : input.activeFocus ? Theme.primary : Theme.panelBorderFill

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
                text: Lock.checking ? Theme.icon(0xf0450) : Theme.icon(0xf033e)
                color: Theme.primary
                font.pixelSize: 18
            }

            TextField {
                id: input
                anchors {
                    left: lockIcon.right
                    right: parent.right
                    leftMargin: 10
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                background: null
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

                Keys.onEscapePressed: if (root.demo) Lock.unlock()

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
        }

        BarText {
            anchors.horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
            height: 22
            text: Lock.error !== "" ? Lock.error : root.demo ? "Preview: Enter or Esc closes it" : ""
            color: Lock.error !== "" ? Theme.error : Theme.textDim
            font.pixelSize: 13
        }
    }

    // Bottom row: now playing, battery
    BarText {
        visible: Config.lockShowMedia && Media.available
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: 40
            bottomMargin: 30
        }
        width: Math.min(implicitWidth, parent.width / 3)
        elide: Text.ElideRight
        text: Theme.icon(0xf075a) + "  " + Media.title + (Media.artist !== "" ? " — " + Media.artist : "")
        color: Theme.textDim
        font.pixelSize: 13
    }
    BarText {
        visible: Config.lockShowBattery && Battery.available
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 40
            bottomMargin: 30
        }
        text: Theme.icon(Battery.charging ? 0xf0084 : 0xf0079) + "  " + Battery.percent + "%"
        color: Theme.textDim
        font.pixelSize: 13
    }
}
