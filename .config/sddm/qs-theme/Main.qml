import QtQuick 2.15

// SDDM login screen matching the Quickshell lock screen. Plain QtQuick only
// (no SddmComponents), and the wallpaper is pre-blurred by `sddm-theme refresh`.
Rectangle {
    id: root

    width: 1280
    height: 720
    color: cfg("surfaceLow", "#211b13")

    function cfg(key, fallback) {
        const v = config[key];
        return v === undefined || v === "" ? fallback : v;
    }

    readonly property string fontFamily: cfg("font", "sans-serif")
    readonly property int radius: parseInt(cfg("radius", "14"))
    readonly property color cPrimary: cfg("primary", "#f6bc70")
    readonly property color cPrimaryFg: cfg("primaryFg", "#462b00")
    readonly property color cSurface: cfg("surfaceLow", "#211b13")
    readonly property color cHigh: cfg("surfaceHigh", "#302921")
    readonly property color cHighest: cfg("surfaceHighest", "#3b342b")
    readonly property color cText: cfg("text", "#ede0d4")
    readonly property color cDim: cfg("textDim", "#d3c4b4")
    readonly property color cError: cfg("error", "#ffb4ab")
    readonly property color cLine: cfg("outlineVariant", "#4f4539")

    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool failed: false
    property bool busy: false
    property date now: new Date()

    function userName() {
        return userModel.data(userModel.index(userIndex, 0), 257) || "";   // Qt::UserRole + 1 = name
    }
    function userReal() {
        return userModel.data(userModel.index(userIndex, 0), 258) || userName();
    }
    function sessionName() {
        return sessionModel.data(sessionModel.index(sessionIndex, 0), 258) || "";   // name role
    }
    function login() {
        if (busy)
            return;
        busy = true;
        failed = false;
        sddm.login(userName(), password.text, sessionIndex);
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false;
            root.failed = true;
            password.text = "";
            shake.restart();
            password.forceActiveFocus();
        }
        function onLoginSucceeded() {
            root.busy = false;
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Image {
        anchors.fill: parent
        source: root.cfg("background", "")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Clock, date, greeting
    Column {
        id: col
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -30
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, root.cfg("clock24h", "false") === "true" ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "")
            font.family: root.fontFamily
            font.pixelSize: 96
            font.bold: true
            color: root.cText
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "dddd, d MMMM")
            font.family: root.fontFamily
            font.pixelSize: 20
            color: root.cPrimary
        }

        // User switcher (arrows only when there is more than one user)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14
            height: 40

            Text {
                visible: userModel.count > 1
                anchors.verticalCenter: parent.verticalCenter
                text: "‹"
                font.pixelSize: 26
                color: root.cDim
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    onClicked: root.userIndex = (root.userIndex + userModel.count - 1) % userModel.count
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.userReal()
                font.family: root.fontFamily
                font.pixelSize: 16
                color: root.cDim
            }
            Text {
                visible: userModel.count > 1
                anchors.verticalCenter: parent.verticalCenter
                text: "›"
                font.pixelSize: 26
                color: root.cDim
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    onClicked: root.userIndex = (root.userIndex + 1) % userModel.count
                }
            }
        }

        // Password
        Rectangle {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 56
            radius: root.radius
            color: root.cSurface
            opacity: 0.95
            border.width: 2
            border.color: root.failed ? root.cError : password.activeFocus ? root.cPrimary : root.cLine

            SequentialAnimation {
                id: shake
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -14; duration: 50 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 14; duration: 80 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
            }

            Text {
                id: lockIcon
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: root.busy ? "…" : ""
                font.family: root.fontFamily
                font.pixelSize: 18
                color: root.cPrimary
            }

            TextInput {
                id: password
                anchors.left: lockIcon.right
                anchors.right: parent.right
                anchors.leftMargin: 12
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                echoMode: TextInput.Password
                passwordCharacter: "●"
                enabled: !root.busy
                focus: true
                color: root.cText
                font.family: root.fontFamily
                font.pixelSize: 16
                selectionColor: root.cPrimary
                selectedTextColor: root.cPrimaryFg
                clip: true
                onAccepted: root.login()
                onTextChanged: root.failed = false
                Keys.onEscapePressed: text = ""

                Text {
                    visible: password.text === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.busy ? "Logging in…" : "Password"
                    font: password.font
                    color: Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.45)
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            height: 22
            text: root.failed ? "Wrong password" : ""
            font.family: root.fontFamily
            font.pixelSize: 13
            color: root.cError
        }
    }

    // Session picker (click to cycle)
    Rectangle {
        visible: sessionModel.count > 1
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 30
        width: sessionLabel.implicitWidth + 28
        height: 36
        radius: root.radius
        color: sessionMouse.containsMouse ? root.cHighest : root.cHigh
        opacity: 0.95

        Text {
            id: sessionLabel
            anchors.centerIn: parent
            text: "  " + root.sessionName()
            font.family: root.fontFamily
            font.pixelSize: 13
            color: root.cText
        }
        MouseArea {
            id: sessionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count
        }
    }

    // Power buttons
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 30
        spacing: 8

        Repeater {
            model: [
                { icon: "", ok: sddm.canSuspend, act: 0 },
                { icon: "", ok: sddm.canReboot, act: 1 },
                { icon: "", ok: sddm.canPowerOff, act: 2 }
            ]

            Rectangle {
                required property var modelData
                visible: modelData.ok
                width: 36
                height: 36
                radius: root.radius
                color: powerMouse.containsMouse ? (modelData.act === 0 ? root.cHighest : root.cError) : root.cHigh
                opacity: 0.95

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.family: root.fontFamily
                    font.pixelSize: 15
                    color: powerMouse.containsMouse && modelData.act !== 0 ? "#690005" : root.cText
                }
                MouseArea {
                    id: powerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.act === 0 ? sddm.suspend() : modelData.act === 1 ? sddm.reboot() : sddm.powerOff()
                }
            }
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
