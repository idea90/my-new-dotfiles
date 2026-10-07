import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs
import qs.modules
import qs.services

// Volume mixer: output device picker, master volume, and one slider per app
Card {
    id: mixer

    implicitWidth: 400
    implicitHeight: Math.min(560, col.implicitHeight + 28)

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.name.startsWith("alsa_output") || n.isSink && !n.isStream && n.name.startsWith("bluez_output"))
    // Apps playing sound are "streams" that feed a sink
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isStream && n.isSink)

    // Volume / mute are only readable on bound nodes
    PwObjectTracker {
        objects: mixer.sinks.concat(mixer.streams)
    }

    function appName(node) {
        const p = node.properties ?? {};
        return p["application.name"] || node.description || node.nickname || node.name || "App";
    }
    function appIcon(node) {
        const p = node.properties ?? {};
        const id = p["application.icon-name"] || p["application.process.binary"] || p["application.name"] || "";
        const entry = id ? DesktopEntries.heuristicLookup(id) : null;
        return Quickshell.iconPath(entry ? entry.icon : id.toLowerCase(), "audio-volume-high");
    }

    ColumnLayout {
        id: col
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 12

        BarText {
            text: Theme.icon(0xf057e) + "  Sound"
            font.bold: true
            font.pixelSize: 16
        }

        // Output device
        BarText {
            text: "OUTPUT"
            color: Theme.primary
            font.pixelSize: 11
            font.bold: true
        }
        Repeater {
            model: mixer.sinks
            delegate: Rectangle {
                required property var modelData
                readonly property bool current: Pipewire.defaultAudioSink === modelData
                Layout.fillWidth: true
                implicitHeight: 40
                radius: Config.itemRadius
                color: current ? Theme.primaryContainer : sinkMouse.containsMouse ? Theme.surfaceHigh : "transparent"
                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    BarText {
                        text: Theme.icon(current ? 0xf0765 : 0xf0766)
                        color: current ? Theme.primary : Theme.textDim
                    }
                    BarText {
                        Layout.fillWidth: true
                        text: modelData.description || modelData.nickname || modelData.name
                        elide: Text.ElideRight
                        color: current ? Theme.primaryContainerFg : Theme.text
                    }
                }
                MouseArea {
                    id: sinkMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }
        }

        Slider {
            Layout.fillWidth: true
            visible: Audio.ready
            icon: Audio.muted ? Theme.icon(0xf075f) : Theme.icon(0xf057e)
            value: Audio.volume
            onMoved: v => Audio.setVolume(v)
            onIconClicked: Audio.toggleMute()
        }

        // Apps
        BarText {
            text: "APPS"
            color: Theme.primary
            font.pixelSize: 11
            font.bold: true
        }
        BarText {
            visible: mixer.streams.length === 0
            text: "Nothing is playing sound"
            color: Theme.textDim
        }
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 260)
            clip: true
            spacing: 6
            model: mixer.streams
            boundsBehavior: Flickable.StopAtBounds

            delegate: Column {
                required property var modelData
                width: ListView.view.width
                spacing: 2
                Row {
                    spacing: 8
                    IconImage {
                        implicitSize: 18
                        source: mixer.appIcon(modelData)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    BarText {
                        text: mixer.appName(modelData)
                        font.pixelSize: 13
                    }
                }
                Slider {
                    width: parent.width
                    icon: modelData.audio && modelData.audio.muted ? Theme.icon(0xf075f) : Theme.icon(0xf057e)
                    value: modelData.audio ? modelData.audio.volume : 0
                    onMoved: v => {
                        if (modelData.audio)
                            modelData.audio.volume = v;
                    }
                    onIconClicked: {
                        if (modelData.audio)
                            modelData.audio.muted = !modelData.audio.muted;
                    }
                }
            }
        }
    }
}
