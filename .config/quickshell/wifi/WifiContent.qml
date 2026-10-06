import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules
import qs.services

// Wi-Fi networks: click to connect, password field for new secured ones
Card {
    id: menu

    property string askingFor: ""   // SSID waiting for a password

    implicitWidth: 360
    implicitHeight: Math.min(520, column.implicitHeight + 28)

    Connections {
        target: Panels
        function onOpenChanged() {
            if (Panels.open === "wifi") {
                menu.askingFor = "";
                Network.error = "";
                Network.scan();
            }
        }
    }

    ColumnLayout {
        id: column
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            BarText {
                Layout.fillWidth: true
                text: "Wi-Fi"
                font.bold: true
                font.pixelSize: 16
            }
            Chip {
                icon: Theme.icon(0xf0450)
                visible: Network.wifiEnabled
                fg: Network.scanning ? Theme.primary : Theme.textDim
                onLeftClicked: Network.scan()
            }
            // On/off switch
            Rectangle {
                width: 44
                height: 24
                radius: 12
                color: Network.wifiEnabled ? Theme.primary : Theme.surfaceHighest

                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    y: 3
                    x: Network.wifiEnabled ? parent.width - width - 3 : 3
                    color: Network.wifiEnabled ? Theme.primaryFg : Theme.textDim
                    Behavior on x {
                        NumberAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Network.setWifi(!Network.wifiEnabled)
                }
            }
        }

        BarText {
            Layout.fillWidth: true
            visible: Network.error !== ""
            text: Network.error
            color: Theme.error
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }

        BarText {
            visible: !Network.wifiEnabled || (Network.networks.length === 0 && !Network.scanning)
            text: Network.wifiEnabled ? "No networks found" : "Wi-Fi is off"
            color: Theme.textDim
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 400)
            visible: Network.wifiEnabled
            clip: true
            spacing: 2
            model: Network.networks
            boundsBehavior: Flickable.StopAtBounds

            delegate: Column {
                id: row

                required property var modelData
                readonly property bool asking: menu.askingFor === modelData.ssid
                readonly property bool busy: Network.busySsid === modelData.ssid

                width: list.width
                spacing: 6

                Rectangle {
                    width: parent.width
                    height: 44
                    radius: Theme.innerRadius + 2
                    color: row.modelData.active ? Theme.primaryContainer
                         : mouse.containsMouse ? Theme.surfaceHigh : "transparent"

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                        }
                        spacing: 10

                        BarText {
                            text: Theme.icon([0xf091f, 0xf0922, 0xf0925, 0xf0928][Math.min(3, Math.floor(row.modelData.signal / 25))])
                            font.pixelSize: 16
                            color: row.modelData.active ? Theme.primaryContainerFg : Theme.text
                        }
                        BarText {
                            Layout.fillWidth: true
                            text: row.modelData.ssid
                            elide: Text.ElideRight
                            color: row.modelData.active ? Theme.primaryContainerFg : Theme.text
                            font.bold: row.modelData.active
                        }
                        BarText {
                            text: row.busy ? "connecting…"
                                : row.modelData.active ? "connected"
                                : row.modelData.saved ? "saved" : ""
                            visible: text !== ""
                            font.pixelSize: 11
                            color: row.modelData.active ? Theme.primaryContainerFg : Theme.textDim
                        }
                        BarText {
                            visible: row.modelData.secure
                            text: Theme.icon(0xf033e)
                            font.pixelSize: 12
                            color: Theme.textDim
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const net = row.modelData;
                            if (net.active)
                                Network.disconnect();
                            else if (net.secure && !net.saved)
                                menu.askingFor = net.ssid;
                            else
                                Network.connect(net.ssid, "");
                        }
                    }
                }

                // Password for a new secured network
                Rectangle {
                    visible: row.asking
                    width: parent.width
                    height: 40
                    radius: Theme.innerRadius + 2
                    color: Theme.surfaceHigh

                    TextField {
                        id: password
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        background: null
                        echoMode: TextInput.Password
                        placeholderText: "Password, then Enter"
                        placeholderTextColor: Theme.alpha(Theme.text, 0.45)
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 13
                        onVisibleChanged: if (visible) forceActiveFocus()
                        onAccepted: {
                            Network.connect(row.modelData.ssid, text);
                            text = "";
                            menu.askingFor = "";
                        }
                        Keys.onEscapePressed: menu.askingFor = ""
                    }
                }
            }
        }

        Chip {
            Layout.alignment: Qt.AlignRight
            label: "Network settings"
            fg: Theme.textDim
            onLeftClicked: {
                Panels.close();
                Quickshell.execDetached(["nm-connection-editor"]);
            }
        }
    }
}
