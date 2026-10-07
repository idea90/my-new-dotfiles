import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules
import qs.services

// "Dynamic island" bar mode (Config.barMode === "island"): one black pill at the
// top center instead of a bar. It grows to show what is happening:
//   volume / brightness change   level bar          (replaces the OSD pop-up)
//   new notification             app and summary    (replaces the pop-ups)
//   hover                        workspaces, clock, status, media or shortcuts
//   music playing                album art, title and a little equalizer
//   otherwise                    workspaces, clock and battery
// Click: control center. Right-click: app launcher.
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    visible: Config.barMode === "island"
    color: "transparent"
    anchors.top: true
    margins.top: Config.islandTop
    implicitWidth: 800
    implicitHeight: 190
    exclusiveZone: Config.islandCompactHeight + 4
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-island"

    // Only the pill takes input; the rest of the window is click-through
    mask: Region { item: pill }

    // ---- state ---------------------------------------------------------------
    readonly property var latest: Notifs.popups.length > 0 ? Notifs.popups[Notifs.popups.length - 1] : null
    property bool hovered: false
    readonly property string mode: Osd.shown && Config.islandOsd ? "osd"
        : latest && !Notifs.dnd && Config.islandNotifs ? "notif"
        : hovered && Config.islandHover ? "expanded"
        : Media.available && Media.playing && Config.islandMedia ? "media"
        : "compact"

    function act(what) {
        if (what === "controlcenter")
            Panels.toggle("controlcenter");
        else if (what === "launcher")
            AppMenu.toggle();
        else if (what === "calendar")
            Panels.toggle("calendar");
    }

    // The normal pop-up window (and its timers) is hidden in island mode, so the
    // island expires notifications itself; critical ones stay a little longer
    Timer {
        id: notifTimer
        interval: win.latest ? (Notifs.popupSeconds(win.latest) || 10) * 1000 : 5000
        running: win.visible && !!win.latest && Config.islandNotifs
        onTriggered: if (win.latest) Notifs.hidePopup(win.latest)
    }
    onLatestChanged: if (latest) notifTimer.restart()

    Timer {
        id: unhover
        interval: 350
        onTriggered: win.hovered = false
    }

    readonly property int compactH: Config.islandCompactHeight
    readonly property var sizes: ({
        compact: [compactRow.implicitWidth + 32, compactH],
        media: [mediaRow.implicitWidth + 28, compactH],
        osd: [330, compactH + 10],
        notif: [440, 64],
        expanded: [Config.islandHoverWidth, Media.available ? 150 : 128]
    })

    // ---- the pill ----------------------------------------------------------
    Rectangle {
        id: pill

        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        width: win.sizes[win.mode][0]
        height: win.sizes[win.mode][1]
        radius: Math.min(height / 2, win.mode === "expanded" ? 30 : 99)
        color: Theme.alpha(Config.islandColor === "black" ? "#000000" : Theme.surfaceLow, Config.islandPillOpacity)
        border.width: Config.islandColor === "black" ? 0 : 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.8)
        clip: true

        // Springy grow / shrink
        Behavior on width {
            SpringAnimation { spring: 4; damping: 0.38; epsilon: 0.5 }
        }
        Behavior on height {
            SpringAnimation { spring: 4; damping: 0.38; epsilon: 0.5 }
        }

        layer.enabled: Config.shadows
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.5)
            shadowBlur: 0.8
            shadowVerticalOffset: 4
        }

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    unhover.stop();
                    win.hovered = true;
                } else {
                    unhover.restart();
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: event => {
                if (win.mode === "notif") {
                    Notifs.hidePopup(win.latest);
                    Panels.toggle("controlcenter");
                } else if (event.button === Qt.RightButton) {
                    win.act(Config.islandRightClick);
                } else if (win.mode !== "expanded") {
                    win.act(Config.islandClick);
                }
            }
        }

        // ---- compact: workspaces, clock, battery -----------------------------
        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: 14
            opacity: win.mode === "compact" ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation { duration: Theme.dur(160) }
            }

            Row {
                visible: Config.islandWorkspaces
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                Repeater {
                    model: Hypr.ids
                    delegate: Rectangle {
                        required property int modelData
                        readonly property bool focused: modelData === Hypr.focusedId
                        anchors.verticalCenter: parent.verticalCenter
                        width: focused ? 16 : 6
                        height: 6
                        radius: 3
                        color: focused ? Theme.primary : Hypr.occupied(modelData) ? "#ffffff" : Qt.rgba(1, 1, 1, 0.3)
                        Behavior on width {
                            NumberAnimation { duration: Theme.dur(160) }
                        }
                    }
                }
            }
            IslandClock {
                visible: Config.islandClock
                anchors.verticalCenter: parent.verticalCenter
                u: Config.islandCompactHeight >= 40 ? 1.12 : 1
            }
            Text {
                visible: Config.islandDate
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(Time.now, "ddd d MMM")
                color: Qt.rgba(1, 1, 1, 0.7)
                font.family: Theme.font
                font.pixelSize: 12
            }
            Text {
                visible: Battery.available && Config.islandBattery
                anchors.verticalCenter: parent.verticalCenter
                text: Theme.icon(Battery.charging ? 0xf0084 : 0xf0079) + " " + Battery.percent
                color: !Battery.charging && Battery.percent <= 20 ? Theme.error : Qt.rgba(1, 1, 1, 0.8)
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        // ---- media: art, title, equalizer ----------------------------------
        Row {
            id: mediaRow
            anchors.centerIn: parent
            spacing: 12
            opacity: win.mode === "media" ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation { duration: Theme.dur(160) }
            }

            ClippingRectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: win.compactH - 12
                height: width
                radius: width / 2
                color: Theme.tertiaryContainer
                Image {
                    anchors.fill: parent
                    source: Media.art
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 200)
                elide: Text.ElideRight
                text: Media.title
                color: "#ffffff"
                font.family: Theme.font
                font.pixelSize: 13
                font.bold: true
            }
            Equalizer {
                anchors.verticalCenter: parent.verticalCenter
                running: win.mode === "media"
            }
        }

        // ---- osd: icon, level bar, percent ---------------------------------
        Row {
            anchors.centerIn: parent
            spacing: 14
            opacity: win.mode === "osd" ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation { duration: Theme.dur(120) }
            }

            readonly property real level: Osd.kind === "brightness" ? Brightness.percent / 100
                : Osd.kind === "mic" ? (Audio.micMuted ? 0 : 1)
                : (Audio.muted ? 0 : Audio.volume)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Osd.kind === "brightness" ? Theme.icon(0xf00df)
                    : Osd.kind === "mic" ? Theme.icon(Audio.micMuted ? 0xf036d : 0xf036c)
                    : Theme.icon(Audio.muted ? 0xf075f : 0xf057e)
                color: Theme.primary
                font.family: Theme.font
                font.pixelSize: 20
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 200
                height: 6
                radius: 3
                color: Qt.rgba(1, 1, 1, 0.18)
                Rectangle {
                    width: parent.width * Math.min(1, parent.parent.level)
                    height: parent.height
                    radius: 3
                    color: Theme.primary
                    Behavior on width {
                        NumberAnimation { duration: Theme.dur(120) }
                    }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                text: Math.round(parent.level * 100) + "%"
                color: "#ffffff"
                font.family: Theme.font
                font.pixelSize: 12
            }
        }

        // ---- notification: app and summary ---------------------------------
        Row {
            anchors {
                left: parent.left
                leftMargin: 18
                right: parent.right
                rightMargin: 18
                verticalCenter: parent.verticalCenter
            }
            spacing: 12
            opacity: win.mode === "notif" ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation { duration: Theme.dur(160) }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                height: 36
                radius: 18
                color: Theme.primaryContainer
                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 22
                    source: win.latest && win.latest.appIcon !== ""
                        ? (win.latest.appIcon.startsWith("/") ? win.latest.appIcon : Quickshell.iconPath(win.latest.appIcon, true))
                        : ""
                }
                Text {
                    anchors.centerIn: parent
                    visible: !win.latest || win.latest.appIcon === ""
                    text: Theme.icon(0xf009a)
                    color: Theme.primaryContainerFg
                    font.family: Theme.font
                    font.pixelSize: 16
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 48
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: win.latest ? (win.latest.appName || "Notification") : ""
                    color: Theme.primary
                    font.family: Theme.font
                    font.pixelSize: 11
                }
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: win.latest ? win.latest.summary : ""
                    color: "#ffffff"
                    font.family: Theme.font
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    visible: text !== ""
                    text: win.latest ? win.latest.body.replace(/<[^>]*>/g, "") : ""
                    color: Qt.rgba(1, 1, 1, 0.7)
                    font.family: Theme.font
                    font.pixelSize: 12
                }
            }
        }

        // ---- expanded (hover) ----------------------------------------------
        Column {
            anchors {
                fill: parent
                margins: 18
                topMargin: 16
            }
            spacing: 14
            opacity: win.mode === "expanded" ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation { duration: Theme.dur(180) }
            }

            Item {
                width: parent.width
                height: 34

                Workspaces {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                }
                Column {
                    anchors.centerIn: parent
                    IslandClock {
                        anchors.horizontalCenter: parent.horizontalCenter
                        u: 1.2
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(Time.now, "ddd d MMM") + (Weather.ready && Config.weatherEnabled ? "  ·  " + Weather.line : "")
                        color: Qt.rgba(1, 1, 1, 0.6)
                        font.family: Theme.font
                        font.pixelSize: 11
                    }
                }
                Row {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2
                    StatusRings {}
                    WifiChip {}
                }
            }

            // Media controls when something is loaded, shortcuts otherwise
            Item {
                width: parent.width
                height: Media.available ? 58 : 40

                Row {
                    visible: Media.available
                    anchors.fill: parent
                    spacing: 14
                    ClippingRectangle {
                        width: 54
                        height: 54
                        radius: 12
                        color: Theme.tertiaryContainer
                        Image {
                            anchors.fill: parent
                            source: Media.art
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 54 - 14 - controls.width - 14
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: Media.title
                            color: "#ffffff"
                            font.family: Theme.font
                            font.pixelSize: 14
                            font.bold: true
                        }
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: Media.artist
                            color: Qt.rgba(1, 1, 1, 0.6)
                            font.family: Theme.font
                            font.pixelSize: 12
                        }
                        MiniBar {
                            width: parent.width
                            value: Media.progress
                        }
                    }
                    Row {
                        id: controls
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

                Row {
                    visible: !Media.available
                    anchors.centerIn: parent
                    spacing: 8
                    Repeater {
                        model: [
                            { icon: 0xf0349, label: "Apps", act: () => AppMenu.toggle() },
                            { icon: 0xf03d8, label: "Theme", act: () => Panels.toggle("theme") },
                            { icon: 0xf009a, label: "Center", act: () => Panels.toggle("controlcenter") },
                            { icon: 0xf0493, label: "Settings", act: () => Panels.toggle("settings") },
                            { icon: 0xf0425, label: "Power", act: () => Panels.toggle("power") }
                        ]
                        delegate: Chip {
                            required property var modelData
                            icon: Theme.icon(modelData.icon)
                            label: modelData.label
                            bg: Qt.rgba(1, 1, 1, 0.08)
                            hoverBg: Theme.primaryContainer
                            onLeftClicked: modelData.act()
                        }
                    }
                }
            }
        }
    }
}
