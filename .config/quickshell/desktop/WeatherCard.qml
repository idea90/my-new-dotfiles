import QtQuick
import qs
import qs.modules
import qs.services

WidgetCard {
    visible: Weather.available

    Row {
        width: parent.width
        spacing: 14

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Theme.icon(Weather.icon)
            font.pixelSize: 48
            color: Theme.primary
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 62
            spacing: 2

            BarText {
                text: Weather.temperature + "°C"
                font.pixelSize: 28
                font.bold: true
            }
            BarText {
                width: parent.width
                text: Weather.condition
                color: Theme.textDim
                font.pixelSize: 13
                elide: Text.ElideRight
            }
            BarText {
                width: parent.width
                text: "Feels " + Weather.feelsLike + "°  ·  " + Theme.icon(0xf058e) + " " + Weather.humidity + "%"
                    + (Weather.place ? "  ·  " + Weather.place : "")
                color: Theme.textDim
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }
}
