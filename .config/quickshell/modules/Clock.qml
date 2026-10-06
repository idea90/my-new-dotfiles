import QtQuick
import qs
import qs.services

// Click to switch between time and date
Chip {
    property bool showDate: false

    padding: 14
    radius: Theme.pillRadius
    fg: Theme.primaryContainerFg
    bg: Theme.primaryContainer
    hoverBg: Theme.alpha(Theme.primaryContainer, 0.85)
    icon: showDate ? Theme.icon(0xf00ed) : Theme.icon(0xf0150)
    label: Qt.formatDateTime(Time.now, showDate ? "ddd d MMM" : "hh:mm AP")
    onLeftClicked: showDate = !showDate
}
