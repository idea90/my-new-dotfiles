import QtQuick
import qs
import qs.services

// Weather in the bar; hover for the description, click to refresh
Chip {
    implicitHeight: Theme.barItem
    radius: Theme.chipRadius
    padding: 9
    label: Theme.vertical ? "" : Weather.temp + Weather.unit
    icon: Weather.glyph
    fontFamily: Theme.barFont
    hoverBg: Theme.surfaceHigh
    onLeftClicked: Weather.refresh()
}
