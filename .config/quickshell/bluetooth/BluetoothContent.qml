import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.modules
import qs.services

// Bluetooth: power, scan, paired and nearby devices with battery levels
Card {
    id: bt

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter ? adapter.devices.values : []
    readonly property var known: devices.filter(d => d.paired || d.connected)
        .sort((a, b) => (b.connected ? 1 : 0) - (a.connected ? 1 : 0))
    readonly property var nearby: devices.filter(d => !d.paired && !d.connected && d.name !== "")

    implicitWidth: 380
    implicitHeight: Math.min(540, col.implicitHeight + 28)

    function glyph(d) {
        const i = (d.icon || "").toLowerCase();
        return i.includes("headset") || i.includes("headphone") ? 0xf02cb
            : i.includes("audio") || i.includes("speaker") ? 0xf04c3
            : i.includes("mouse") ? 0xf037d
            : i.includes("keyboard") ? 0xf030c
            : i.includes("phone") ? 0xf011c
            : i.includes("gaming") || i.includes("joystick") ? 0xf0297
            : 0xf00af;
    }

    ColumnLayout {
        id: col
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            BarText {
                Layout.fillWidth: true
                text: Theme.icon(0xf00af) + "  Bluetooth"
                font.bold: true
                font.pixelSize: 16
            }
            Chip {
                visible: !!bt.adapter && bt.adapter.enabled
                icon: Theme.icon(0xf0450)
                label: bt.adapter && bt.adapter.discovering ? "Scanning…" : "Scan"
                bg: Theme.surfaceHigh
                onLeftClicked: bt.adapter.discovering = !bt.adapter.discovering
            }
            // On/off switch
            Rectangle {
                visible: !!bt.adapter
                width: 44
                height: 24
                radius: 12
                color: bt.adapter && bt.adapter.enabled ? Theme.primary : Theme.surfaceHighest
                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    y: 3
                    x: bt.adapter && bt.adapter.enabled ? parent.width - width - 3 : 3
                    color: bt.adapter && bt.adapter.enabled ? Theme.primaryFg : Theme.textDim
                    Behavior on x {
                        NumberAnimation { duration: Theme.dur(150) }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bt.adapter.enabled = !bt.adapter.enabled
                }
            }
        }

        BarText {
            visible: !bt.adapter
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: "No Bluetooth adapter found. Is the service running?\nsudo systemctl enable --now bluetooth"
            color: Theme.textDim
        }
        BarText {
            visible: !!bt.adapter && !bt.adapter.enabled
            text: "Bluetooth is off"
            color: Theme.textDim
        }

        component DeviceRow: Rectangle {
            id: row
            required property var dev
            Layout.fillWidth: true
            implicitHeight: 48
            radius: Config.itemRadius
            color: dev.connected ? Theme.primaryContainer : rowMouse.containsMouse ? Theme.surfaceHigh : "transparent"

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }
                spacing: 12
                BarText {
                    text: Theme.icon(bt.glyph(row.dev))
                    font.pixelSize: 18
                    color: row.dev.connected ? Theme.primary : Theme.text
                }
                Column {
                    Layout.fillWidth: true
                    BarText {
                        width: parent.width
                        text: row.dev.name || row.dev.deviceName
                        elide: Text.ElideRight
                        color: row.dev.connected ? Theme.primaryContainerFg : Theme.text
                    }
                    BarText {
                        text: row.dev.pairing ? "Pairing…"
                            : row.dev.state === BluetoothDeviceState.Connecting ? "Connecting…"
                            : row.dev.connected ? "Connected" + (row.dev.batteryAvailable ? " · " + Math.round(row.dev.battery * 100) + "% battery" : "")
                            : row.dev.paired ? "Paired" : "Click to pair"
                        font.pixelSize: 11
                        color: row.dev.connected ? Theme.alpha(Theme.primaryContainerFg, 0.75) : Theme.textDim
                    }
                }
                Chip {
                    visible: row.dev.paired && rowMouse.containsMouse
                    icon: Theme.icon(0xf01b4)
                    hoverBg: Theme.error
                    hoverFg: Theme.errorFg
                    onLeftClicked: row.dev.forget()
                }
            }
            MouseArea {
                id: rowMouse
                anchors.fill: parent
                anchors.rightMargin: 44
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (row.dev.connected)
                        row.dev.disconnect();
                    else if (row.dev.paired)
                        row.dev.connect();
                    else {
                        row.dev.trusted = true;
                        row.dev.pair();
                    }
                }
            }
        }

        BarText {
            visible: bt.known.length > 0 && !!bt.adapter && bt.adapter.enabled
            text: "MY DEVICES"
            color: Theme.primary
            font.pixelSize: 11
            font.bold: true
        }
        Repeater {
            model: bt.adapter && bt.adapter.enabled ? bt.known : []
            delegate: DeviceRow {
                required property var modelData
                dev: modelData
            }
        }

        BarText {
            visible: !!bt.adapter && bt.adapter.enabled
            text: "NEARBY" + (bt.adapter && bt.adapter.discovering ? "  ·  scanning" : "")
            color: Theme.primary
            font.pixelSize: 11
            font.bold: true
        }
        BarText {
            visible: !!bt.adapter && bt.adapter.enabled && bt.nearby.length === 0
            text: bt.adapter && bt.adapter.discovering ? "Looking for devices…" : "Press Scan to find devices"
            color: Theme.textDim
        }
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 220)
            visible: !!bt.adapter && bt.adapter.enabled
            clip: true
            spacing: 4
            model: bt.nearby
            boundsBehavior: Flickable.StopAtBounds
            delegate: Item {
                required property var modelData
                width: ListView.view.width
                height: 48
                DeviceRow {
                    anchors.fill: parent
                    dev: modelData
                }
            }
        }
    }
}
