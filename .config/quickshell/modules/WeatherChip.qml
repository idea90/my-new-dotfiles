import QtQuick
import qs
import qs.services

// Weather in the bar; click to refresh. Config.barWeatherWide gives the Windows
// taskbar widget: big icon, temperature over the condition.
Rectangle {
    id: wx

    readonly property bool wide: Config.barWeatherWide && !Theme.vertical
    implicitWidth: wide ? wideRow.implicitWidth + 24 : chip.implicitWidth
    implicitHeight: Theme.barItem
    radius: Theme.chipRadius
    color: wide && mouse.containsMouse ? Theme.alpha(Theme.text, 0.08) : "transparent"

    Chip {
        id: chip
        visible: !wx.wide
        anchors.fill: parent
        implicitHeight: Theme.barItem
        radius: Theme.chipRadius
        padding: 9
        label: Theme.vertical ? "" : Weather.temp + Weather.unit
        icon: Weather.glyph
        fontFamily: Theme.barFont
        hoverBg: Theme.surfaceHigh
        onLeftClicked: Weather.refresh()
    }

    Row {
        id: wideRow
        visible: wx.wide
        anchors.centerIn: parent
        spacing: 10
        BarText {
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.glyph
            font.pixelSize: Math.round(26 * Theme.barScale)
            color: Theme.primary
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            BarText { text: Weather.temp + Weather.unit; font.pixelSize: Math.round(12 * Theme.barScale); font.bold: true }
            BarText { text: Weather.desc; font.pixelSize: Math.round(11 * Theme.barScale); color: Theme.textDim; elide: Text.ElideRight; width: Math.min(implicitWidth, 110) }
        }
    }
    MouseArea {
        id: mouse
        visible: wx.wide
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Weather.refresh()
    }
}
