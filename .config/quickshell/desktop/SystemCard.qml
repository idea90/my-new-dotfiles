import QtQuick
import qs
import qs.modules
import qs.services

// CPU, RAM, disk and battery bars, plus uptime
WidgetCard {
    component Meter: Item {
        id: meter
        property string icon
        property string name
        property real value: 0   // 0..1
        property color barColor: value >= 0.9 ? Theme.error : value >= 0.75 ? Theme.tertiary : Theme.primary

        width: parent.width
        height: 30

        BarText {
            id: meterIcon
            width: 22
            anchors.verticalCenter: parent.verticalCenter
            text: meter.icon
            font.pixelSize: 15
            color: meter.barColor
        }
        BarText {
            id: meterName
            width: 60
            anchors {
                left: meterIcon.right
                leftMargin: 6
                verticalCenter: parent.verticalCenter
            }
            text: meter.name
            font.pixelSize: 12
            color: Theme.textDim
        }
        Rectangle {
            anchors {
                left: meterName.right
                right: meterValue.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            height: 6
            radius: 3
            color: Theme.surfaceHighest

            Rectangle {
                width: parent.width * Math.min(1, meter.value)
                height: parent.height
                radius: 3
                color: meter.barColor
                Behavior on width {
                    NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                }
            }
        }
        BarText {
            id: meterValue
            width: 40
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            horizontalAlignment: Text.AlignRight
            text: Math.round(meter.value * 100) + "%"
            font.pixelSize: 12
        }
    }

    Column {
        width: parent.width
        spacing: 2

        Meter {
            icon: Theme.icon(0xf0ee0)
            name: "CPU"
            value: Sys.cpu / 100
        }
        Meter {
            icon: Theme.icon(0xf035b)
            name: "RAM"
            value: Sys.memory / 100
        }
        Meter {
            icon: Theme.icon(0xf02ca)
            name: "Disk"
            value: Sys.disk / 100
        }
        Meter {
            visible: Battery.available
            icon: Battery.charging ? Theme.icon(0xf0084) : Theme.icon(0xf0079)
            name: "Battery"
            value: Battery.percent / 100
            barColor: !Battery.charging && Battery.percent <= 15 ? Theme.error
                    : Battery.charging ? Theme.tertiary : Theme.primary
        }

        BarText {
            topPadding: 6
            text: Theme.icon(0xf0954) + "  up " + Sys.uptime
                + (Sys.temperature >= 0 ? "    " + Theme.icon(0xf050f) + " " + Sys.temperature + "°C" : "")
            font.pixelSize: 12
            color: Theme.textDim
        }
    }
}
