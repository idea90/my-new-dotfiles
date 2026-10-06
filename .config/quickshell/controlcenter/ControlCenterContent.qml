import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules
import qs.notifications
import qs.services

// Right-hand panel: quick toggles, sliders, now playing, notifications
Card {
    id: panel

    implicitWidth: Config.ccWidth

    // Every available quick toggle, keyed by the id used in Config.ccToggles
    readonly property var toggleDefs: ({
        wifi: {
            icon: Network.wifiEnabled ? Theme.icon(0xf05a9) : Theme.icon(0xf05aa),
            label: "Wi-Fi",
            on: Network.wifiEnabled,
            click: () => Network.setWifi(!Network.wifiEnabled),
            rightClick: () => Panels.toggle("wifi")
        },
        sound: {
            icon: Audio.muted ? Theme.icon(0xf075f) : Theme.icon(0xf057e),
            label: "Sound",
            on: !Audio.muted,
            click: () => Audio.toggleMute()
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
            click: () => Panels.toggle("screenshot")
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
        anchors {
            fill: parent
            margins: Config.ccPadding
        }
        spacing: Config.ccSpacing

        GridLayout {
            Layout.fillWidth: true
            columns: Config.ccColumns
            rowSpacing: 8
            columnSpacing: 8

            // Order and selection come from Config.ccToggles
            Repeater {
                model: Config.ccToggles.filter(id => id in panel.toggleDefs)

                delegate: Toggle {
                    id: tile
                    required property string modelData
                    readonly property var def: panel.toggleDefs[modelData]

                    Layout.fillWidth: true
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

        Rectangle {
            Layout.fillWidth: true
            visible: Config.ccSliders
            implicitHeight: sliders.implicitHeight + 12
            radius: Config.itemRadius
            color: Theme.surfaceMid

            Column {
                id: sliders
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 12
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
                text: "Notifications"
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
            Layout.fillHeight: true
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

            BarText {
                anchors.centerIn: parent
                visible: Notifs.count === 0
                text: Theme.icon(0xf009a) + "  No notifications"
                color: Theme.textDim
            }
        }
    }
}
