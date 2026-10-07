import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.modules
import qs.notifications
import qs.services

// Right-hand panel: quick toggles, sliders, now playing, notifications
Card {
    id: panel

    implicitWidth: Config.ccWidth
    radius: Config.ccRadius >= 0 ? Config.ccRadius : Theme.radius

    // Touching the screen edge: square the corners on that side
    readonly property bool edgeRight: Config.ccSideMargin === 0 && Config.ccSide !== "left"
    readonly property bool edgeLeft: Config.ccSideMargin === 0 && Config.ccSide === "left"
    topRightRadius: edgeRight ? 0 : radius
    bottomRightRadius: edgeRight || Config.ccBottomMargin === 0 ? (edgeRight ? 0 : radius) : radius
    topLeftRadius: edgeLeft ? 0 : radius
    bottomLeftRadius: edgeLeft ? 0 : radius
    // With ccFit the panel is only as tall as its content
    implicitHeight: layoutColumn.implicitHeight + Config.ccPadding * 2

    // Every available quick toggle, keyed by the id used in Config.ccToggles
    readonly property var toggleDefs: ({
        wifi: {
            icon: Network.wifiEnabled ? Theme.icon(0xf05a9) : Theme.icon(0xf05aa),
            label: "Wi-Fi",
            big: true,
            sub: !Network.wifiEnabled ? "Off" : Network.kind === "none" ? "Not connected" : Network.name,
            on: Network.wifiEnabled,
            click: () => Network.setWifi(!Network.wifiEnabled),
            rightClick: () => Panels.toggle("wifi")
        },
        bluetooth: {
            icon: Theme.icon(Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled ? 0xf00af : 0xf00b2),
            label: "Bluetooth",
            sub: !Bluetooth.defaultAdapter ? "Unavailable"
                : !Bluetooth.defaultAdapter.enabled ? "Off"
                : (Bluetooth.defaultAdapter.devices.values.filter(d => d.connected).map(d => d.name)[0] ?? "On"),
            on: !!Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled,
            click: () => {
                if (Bluetooth.defaultAdapter)
                    Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                else
                    Panels.toggle("bluetooth");
            },
            rightClick: () => Panels.toggle("bluetooth")
        },
        sound: {
            icon: Audio.muted ? Theme.icon(0xf075f) : Theme.icon(0xf057e),
            label: "Sound",
            big: true,
            sub: Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%",
            on: !Audio.muted,
            click: () => Audio.toggleMute(),
            rightClick: () => Panels.toggle("mixer")
        },
        mic: {
            icon: Audio.micMuted ? Theme.icon(0xf036d) : Theme.icon(0xf036c),
            label: "Mic",
            on: Audio.micReady && !Audio.micMuted,
            click: () => Audio.toggleMicMute()
        },
        silent: {
            icon: Notifs.dnd ? Theme.icon(0xf009b) : Theme.icon(0xf009a),
            label: "Silent",
            on: Notifs.dnd,
            click: () => Notifs.toggleDnd()
        },
        game: {
            icon: Theme.icon(0xf0297),
            label: "Game",
            on: GameMode.active,
            click: () => GameMode.toggle()
        },
        awake: {
            icon: Idle.inhibited ? Theme.icon(0xf0208) : Theme.icon(0xf0209),
            label: "Awake",
            on: Idle.inhibited,
            click: () => Idle.toggle()
        },
        capture: {
            icon: Theme.icon(0xf019e),
            label: "Capture",
            click: () => Panels.toggle("screenshot"),
            rightClick: () => Shot.capture("screen")
        },
        theme: {
            icon: Theme.icon(0xf03d8),
            label: "Theme",
            click: () => Panels.toggle("theme")
        },
        settings: {
            icon: Theme.icon(0xf0493),
            label: "Settings",
            click: () => Panels.toggle("settings")
        }
    })

    ColumnLayout {
        id: layoutColumn
        anchors {
            fill: parent
            margins: Config.ccPadding
        }
        spacing: Config.ccSpacing

        // ---- header: who and when, plus settings / lock / power ----
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 2
            spacing: 12
            visible: Config.ccHeader && Config.ccHeaderStyle === "profile"

            Rectangle {
                width: 42
                height: 42
                radius: 21
                color: Theme.primaryContainer
                border.width: 2
                border.color: Theme.primary
                BarText {
                    anchors.centerIn: parent
                    text: Quickshell.env("USER").charAt(0).toUpperCase()
                    font.bold: true
                    font.pixelSize: 18
                    color: Theme.primaryContainerFg
                }
            }
            Column {
                Layout.fillWidth: true
                BarText {
                    text: Quickshell.env("USER")
                    font.bold: true
                    font.pixelSize: 16
                }
                BarText {
                    text: Qt.formatDateTime(Time.now, "dddd, d MMMM")
                    color: Theme.textDim
                    font.pixelSize: 12
                }
            }
            Chip {
                icon: Theme.icon(0xf0493)
                bg: Theme.surfaceHigh
                onLeftClicked: Panels.toggle("settings")
            }
            Chip {
                icon: Theme.icon(0xf033e)
                bg: Theme.surfaceHigh
                onLeftClicked: {
                    Panels.close();
                    Quickshell.execDetached(["qs", "ipc", "call", "lock", "lock"]);
                }
            }
        }

        // ---- "clock" header: big time and date, settings / lock on the right ----
        RowLayout {
            Layout.fillWidth: true
            visible: Config.ccHeader && Config.ccHeaderStyle === "clock"
            spacing: 8

            Column {
                Layout.fillWidth: true
                BarText {
                    text: Qt.formatDateTime(Time.now, Config.clock24h ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "")
                    font.pixelSize: 40
                    font.bold: true
                }
                BarText {
                    text: Qt.formatDateTime(Time.now, "dddd, d MMMM")
                    color: Theme.primary
                    font.pixelSize: 13
                }
            }
            Chip {
                Layout.alignment: Qt.AlignTop
                icon: Theme.icon(0xf0493)
                bg: Theme.surfaceHigh
                onLeftClicked: Panels.toggle("settings")
            }
            Chip {
                Layout.alignment: Qt.AlignTop
                icon: Theme.icon(0xf033e)
                bg: Theme.surfaceHigh
                onLeftClicked: {
                    Panels.close();
                    Quickshell.execDetached(["qs", "ipc", "call", "lock", "lock"]);
                }
            }
        }

        // ---- toggles: wide tiles for Wi-Fi / Sound, compact pills for the rest ----
        // Order and selection come from Config.ccToggles
        Item {
            id: bigBox
            Layout.fillWidth: true
            readonly property var bigs: Config.ccToggles.filter(id => id in panel.toggleDefs && panel.toggleDefs[id].big)
            visible: Config.ccToggleStyle === "mixed" && bigs.length > 0
            implicitHeight: 66

            Row {
                anchors.fill: parent
                spacing: 8

                Repeater {
                    model: bigBox.bigs
                    delegate: BigTile {
                        required property string modelData
                        readonly property var def: panel.toggleDefs[modelData]
                        width: (bigBox.width - (bigBox.bigs.length - 1) * 8) / bigBox.bigs.length
                        icon: def.icon
                        label: def.label
                        sub: def.sub ?? ""
                        on: def.on ?? false
                        onClicked: def.click()
                        onRightClicked: {
                            if (def.rightClick)
                                def.rightClick();
                        }
                    }
                }
            }
        }

        Item {
            id: pillBox
            Layout.fillWidth: true
            readonly property var smalls: Config.ccToggles.filter(id => id in panel.toggleDefs && !panel.toggleDefs[id].big)
            visible: Config.ccToggleStyle === "mixed" && smalls.length > 0
            implicitHeight: Math.ceil(smalls.length / 3) * 54 - 8

            Flow {
                anchors.fill: parent
                spacing: 8

                Repeater {
                    model: pillBox.smalls
                    delegate: PillTile {
                        required property string modelData
                        readonly property var def: panel.toggleDefs[modelData]
                        readonly property int lastRow: pillBox.smalls.length % 3 || 3
                        readonly property int perRow: index >= pillBox.smalls.length - lastRow ? lastRow : 3
                        required property int index
                        width: Math.floor((pillBox.width - (perRow - 1) * 8) / perRow)
                        icon: def.icon
                        label: def.label
                        on: def.on ?? false
                        onClicked: def.click()
                        onRightClicked: {
                            if (def.rightClick)
                                def.rightClick();
                        }
                    }
                }
            }
        }

        // ---- "tiles" style: every toggle as a square tile ----
        Item {
            id: tileBox
            Layout.fillWidth: true
            readonly property var all: Config.ccToggles.filter(id => id in panel.toggleDefs)
            readonly property int cols: Math.max(2, Config.ccColumns)
            visible: Config.ccToggleStyle === "tiles" && all.length > 0
            implicitHeight: Math.ceil(all.length / cols) * 84 - 8

            Flow {
                anchors.fill: parent
                spacing: 8

                Repeater {
                    model: tileBox.all
                    delegate: SquareTile {
                        required property string modelData
                        readonly property var def: panel.toggleDefs[modelData]
                        // The last row stretches so it has no hole
                        readonly property int lastRow: tileBox.all.length % tileBox.cols || tileBox.cols
                        readonly property int perRow: index >= tileBox.all.length - lastRow ? lastRow : tileBox.cols
                        required property int index
                        width: Math.floor((tileBox.width - (perRow - 1) * 8) / perRow)
                        icon: def.icon
                        label: def.label
                        on: def.on ?? false
                        onClicked: def.click()
                        onRightClicked: {
                            if (def.rightClick)
                                def.rightClick();
                        }
                    }
                }
            }
        }

        // ---- "icons" style: round icon-only buttons in a row ----
        Item {
            id: iconBox
            Layout.fillWidth: true
            readonly property var all: Config.ccToggles.filter(id => id in panel.toggleDefs)
            readonly property int perRow: Math.max(3, Math.floor((width + 10) / 58))
            visible: Config.ccToggleStyle === "icons" && all.length > 0
            implicitHeight: Math.ceil(all.length / perRow) * 58 - 10

            Flow {
                anchors.fill: parent
                spacing: 10

                Repeater {
                    model: iconBox.all
                    delegate: CircleTile {
                        required property string modelData
                        readonly property var def: panel.toggleDefs[modelData]
                        icon: def.icon
                        on: def.on ?? false
                        onClicked: def.click()
                        onRightClicked: {
                            if (def.rightClick)
                                def.rightClick();
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            visible: Config.ccSliders && Config.ccSliderStyle !== "big"
            implicitHeight: sliders.implicitHeight + (Config.ccSliderStyle === "inline" ? 0 : 12)
            radius: Config.itemRadius + 4
            color: Config.ccSliderStyle === "inline" ? "transparent" : Theme.surfaceHigh

            Column {
                id: sliders
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Config.ccSliderStyle === "inline" ? 0 : 12
                }

                Slider {
                    width: parent.width
                    visible: Audio.ready
                    icon: Audio.muted ? Theme.icon(0xf075f) : Theme.icon(0xf057e)
                    value: Audio.volume
                    onMoved: v => Audio.setVolume(v)
                    onIconClicked: Audio.toggleMute()
                }
                Slider {
                    width: parent.width
                    visible: Brightness.available
                    icon: Theme.icon(0xf00df)
                    value: Brightness.percent / 100
                    onMoved: v => Brightness.set(v)
                }
            }
        }

        // "big" sliders: thick filled bars
        Column {
            Layout.fillWidth: true
            visible: Config.ccSliders && Config.ccSliderStyle === "big"
            spacing: 8

            BigSlider {
                width: parent.width
                visible: Audio.ready
                icon: Audio.muted ? Theme.icon(0xf075f) : Theme.icon(0xf057e)
                value: Audio.muted ? 0 : Audio.volume
                onMoved: v => Audio.setVolume(v)
                onIconClicked: Audio.toggleMute()
            }
            BigSlider {
                width: parent.width
                visible: Brightness.available
                icon: Theme.icon(0xf00df)
                value: Brightness.percent / 100
                onMoved: v => Brightness.set(v)
            }
        }

        // Now playing
        Rectangle {
            Layout.fillWidth: true
            visible: Config.ccMedia && Media.available
            implicitHeight: 64
            radius: Config.itemRadius
            color: Theme.tertiaryContainer

            Column {
                anchors {
                    left: parent.left
                    right: controls.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 14
                    rightMargin: 8
                }
                BarText {
                    width: parent.width
                    text: Media.title
                    color: Theme.tertiaryContainerFg
                    font.bold: true
                    elide: Text.ElideRight
                }
                BarText {
                    width: parent.width
                    text: Media.artist
                    color: Theme.alpha(Theme.tertiaryContainerFg, 0.75)
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }

            Row {
                id: controls
                anchors {
                    right: parent.right
                    rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                Chip {
                    icon: Theme.icon(0xf04ae)
                    fg: Theme.tertiaryContainerFg
                    hoverBg: Theme.alpha(Theme.tertiaryContainerFg, 0.15)
                    onLeftClicked: Media.previous()
                }
                Chip {
                    icon: Media.playing ? Theme.icon(0xf03e4) : Theme.icon(0xf040a)
                    fg: Theme.tertiaryContainerFg
                    hoverBg: Theme.alpha(Theme.tertiaryContainerFg, 0.15)
                    onLeftClicked: Media.toggle()
                }
                Chip {
                    icon: Theme.icon(0xf04ad)
                    fg: Theme.tertiaryContainerFg
                    hoverBg: Theme.alpha(Theme.tertiaryContainerFg, 0.15)
                    onLeftClicked: Media.next()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: Config.ccNotifications

            BarText {
                Layout.fillWidth: true
                text: "Notifications" + (Notifs.count > 0 ? "  ·  " + Notifs.count : "")
                font.bold: true
                font.pixelSize: 15
            }
            Chip {
                visible: Notifs.count > 0
                label: "Clear all"
                bg: Theme.surfaceHigh
                hoverBg: Theme.error
                hoverFg: Theme.errorFg
                onLeftClicked: Notifs.clearAll()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: !Config.ccFit
            Layout.preferredHeight: Config.ccFit ? Math.min(Math.max(contentHeight, 110), 280) : -1
            visible: Config.ccNotifications
            clip: true
            spacing: 8
            model: Notifs.list.slice().reverse()   // newest first
            boundsBehavior: Flickable.StopAtBounds

            delegate: NotificationCard {
                required property var modelData
                width: ListView.view.width
                notification: modelData
            }

            Column {
                anchors.centerIn: parent
                visible: Notifs.count === 0
                spacing: 8
                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Theme.icon(0xf009a)
                    font.pixelSize: 42
                    color: Theme.alpha(Theme.text, 0.18)
                }
                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "You're all caught up"
                    color: Theme.textDim
                }
            }
        }
    }
}
