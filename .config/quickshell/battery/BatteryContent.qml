import QtQuick
import QtQuick.Layouts
import qs
import qs.modules
import qs.services

// Battery and power profile panel (click the battery in the bar)
Card {
    id: panel
    implicitWidth: 340
    implicitHeight: col.implicitHeight + 28

    function hm(seconds) {
        if (!seconds || seconds <= 0)
            return "";
        const h = Math.floor(seconds / 3600), m = Math.round((seconds % 3600) / 60);
        return (h > 0 ? h + " h " : "") + m + " min";
    }

    ColumnLayout {
        id: col
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 14

        RowLayout {
            spacing: 14
            BarText {
                text: Theme.icon(Battery.charging ? 0xf0084 : 0xf0079)
                font.pixelSize: 34
                color: !Battery.charging && Battery.percent <= 20 ? Theme.error : Theme.primary
            }
            Column {
                Layout.fillWidth: true
                BarText {
                    text: Battery.available ? Battery.percent + "%" : "No battery"
                    font.pixelSize: 26
                    font.bold: true
                }
                BarText {
                    text: !Battery.available ? ""
                        : Battery.full ? "Fully charged"
                        : Battery.charging ? "Charging" + (Battery.device.timeToFull > 0 ? " · full in " + panel.hm(Battery.device.timeToFull) : "")
                        : "On battery" + (Battery.device.timeToEmpty > 0 ? " · " + panel.hm(Battery.device.timeToEmpty) + " left" : "")
                    color: Theme.textDim
                    font.pixelSize: 12
                }
            }
        }

        MiniBar {
            Layout.fillWidth: true
            implicitHeight: 8
            value: Battery.percent / 100
            fill: !Battery.charging && Battery.percent <= 20 ? Theme.error : Theme.primary
        }

        BarText {
            text: "POWER MODE"
            color: Theme.primary
            font.pixelSize: 11
            font.bold: true
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: Power.available
                delegate: Rectangle {
                    required property string modelData
                    readonly property bool on: Power.profile === modelData
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: Config.itemRadius + 2
                    color: on ? Theme.primaryContainer : pm.containsMouse ? Theme.surfaceHighest : Theme.surfaceHigh
                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        BarText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Power.glyph(modelData)
                            font.pixelSize: 20
                            color: on ? Theme.primary : Theme.text
                        }
                        BarText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Power.label(modelData)
                            font.pixelSize: 11
                            color: on ? Theme.primaryContainerFg : Theme.textDim
                        }
                    }
                    MouseArea {
                        id: pm
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Power.set(modelData)
                    }
                }
            }
        }

        BarText {
            visible: Battery.available && Battery.device.healthPercentage > 0
            text: "Battery health " + Math.round(Battery.device.healthPercentage) + "%"
            color: Theme.textDim
            font.pixelSize: 11
        }
    }
}
