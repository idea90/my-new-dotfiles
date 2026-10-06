import QtQuick 2.15

// SDDM login screen matching the Quickshell lock screen: lightly blurred wallpaper,
// big clock, and a floating card with avatar, name and password. Plain QtQuick only
// (no SddmComponents); the wallpaper is pre-blurred by `sddm-theme sync`.
Rectangle {
    id: root

    width: 1280
    height: 720
    color: cfg("surfaceLow", "#211b13")

    function cfg(key, fallback) {
        const v = config[key];
        return v === undefined || v === "" ? fallback : v;
    }
    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    readonly property string fontFamily: cfg("font", "sans-serif")
    readonly property int radius: parseInt(cfg("radius", "14"))
    readonly property color cPrimary: cfg("primary", "#f6bc70")
    readonly property color cPrimaryFg: cfg("primaryFg", "#462b00")
    readonly property color cPrimaryContainer: cfg("primaryContainer", "#643f00")
    readonly property color cPrimaryContainerFg: cfg("primaryContainerFg", "#ffddb6")
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
    function userIcon() {
        return userModel.data(userModel.index(userIndex, 0), 260) || "";   // icon role
    }
    function sessionName() {
        return sessionModel.data(sessionModel.index(sessionIndex, 0), 258) || "";   // name role
    }
    function greeting() {
        const h = now.getHours();
        return h >= 5 && h < 12 ? "Good morning" : h >= 12 && h < 18 ? "Good afternoon" : h >= 18 && h < 22 ? "Good evening" : "Good night";
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

    // ---- background -------------------------------------------------------
    Image {
        anchors.fill: parent
        source: root.cfg("background", "")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.35) }
            GradientStop { position: 0.35; color: "transparent" }
            GradientStop { position: 0.7; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.45) }
        }
    }

    // ---- top row ----------------------------------------------------------
    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 40
        anchors.topMargin: 30
        text: Qt.formatDate(root.now, "dddd, d MMMM")
        font.family: root.fontFamily
        font.pixelSize: 16
        color: Qt.rgba(1, 1, 1, 0.92)
    }

    // Session picker (click to cycle)
    Rectangle {
        visible: sessionModel.count > 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 40
        anchors.topMargin: 24
        width: sessionLabel.implicitWidth + 28
        height: 34
        radius: height / 2
        color: root.alpha(root.cSurface, sessionMouse.containsMouse ? 0.9 : 0.7)
        border.width: 1
        border.color: root.alpha(root.cLine, 0.8)

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

    // ---- clock + card -----------------------------------------------------
    Column {
        id: col
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        spacing: 26
        opacity: 0
        property real rise: 24
        transform: Translate { y: col.rise }

        Component.onCompleted: enter.start()
        ParallelAnimation {
            id: enter
            NumberAnimation { target: col; property: "opacity"; to: 1; duration: 450; easing.type: Easing.OutCubic }
            NumberAnimation { target: col; property: "rise"; to: 0; duration: 450; easing.type: Easing.OutCubic }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, root.cfg("clock24h", "false") === "true" ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "")
            font.family: root.fontFamily
            font.pixelSize: 96
            font.bold: true
            color: "#ffffff"
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.25)
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 396
            height: cardCol.implicitHeight + 48
            radius: root.radius + 8
            color: root.alpha(root.cSurface, 0.8)
            border.width: 1
            border.color: root.alpha(root.cLine, 0.9)

            Column {
                id: cardCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 28
                anchors.topMargin: 24
                spacing: 14

                // Avatar: the account's icon if SDDM can read it, else the initial
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 84
                    height: 84
                    radius: 42
                    color: root.cPrimaryContainer
                    border.width: 3
                    border.color: root.cPrimary
                    clip: true

                    Text {
                        anchors.centerIn: parent
                        visible: face.status !== Image.Ready
                        text: root.userReal().charAt(0).toUpperCase()
                        font.family: root.fontFamily
                        font.pixelSize: 38
                        font.bold: true
                        color: root.cPrimaryContainerFg
                    }
                    Image {
                        id: face
                        anchors.fill: parent
                        source: root.userIcon() !== "" ? "file://" + root.userIcon() : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 2

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 14

                        Text {
                            visible: userModel.count > 1
                            anchors.verticalCenter: parent.verticalCenter
                            text: "‹"
                            font.pixelSize: 26
                            color: root.cDim
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.userIndex = (root.userIndex + userModel.count - 1) % userModel.count
                            }
                        }
                        Text {
                            text: root.userReal()
                            font.family: root.fontFamily
                            font.pixelSize: 20
                            font.bold: true
                            color: root.cText
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
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.userIndex = (root.userIndex + 1) % userModel.count
                            }
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.greeting() + " · enter your password"
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        color: root.cDim
                    }
                }

                // Password field
                Rectangle {
                    id: field
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 340
                    height: 52
                    radius: root.radius
                    color: root.cHigh
                    border.width: 2
                    border.color: root.failed ? root.cError : password.activeFocus ? root.cPrimary : root.alpha(root.cLine, 0.9)

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
                        anchors.right: submit.left
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
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
                            color: root.alpha(root.cText, 0.45)
                        }
                    }

                    Rectangle {
                        id: submit
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36
                        height: 36
                        radius: Math.max(0, root.radius - 4)
                        color: password.text !== "" ? root.cPrimary : root.cHighest

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            color: password.text !== "" ? root.cPrimaryFg : root.cDim
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.login()
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 18
                    text: root.failed ? "Wrong password" : "Esc clears the field"
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    color: root.failed ? root.cError : root.alpha(root.cDim, 0.8)
                }
            }
        }
    }

    // ---- power buttons ----------------------------------------------------
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 34
        spacing: 10

        Repeater {
            model: [
                { icon: "", ok: sddm.canSuspend, act: 0 },
                { icon: "", ok: sddm.canReboot, act: 1 },
                { icon: "", ok: sddm.canPowerOff, act: 2 }
            ]

            Rectangle {
                required property var modelData
                visible: modelData.ok
                width: 44
                height: 44
                radius: 22
                color: powerMouse.containsMouse ? (modelData.act === 0 ? root.alpha(root.cHighest, 0.95) : root.cError) : root.alpha(root.cSurface, 0.78)
                border.width: 1
                border.color: root.alpha(root.cLine, 0.8)

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.family: root.fontFamily
                    font.pixelSize: 16
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
