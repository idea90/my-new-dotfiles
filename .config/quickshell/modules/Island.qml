import QtQuick
import qs

// One floating island of the bar
Rectangle {
    id: island

    default property alias content: row.data
    property int padding: 4
    // Set from outside: an island can't tell from its children, because a
    // hidden island also hides them (and could then never come back)
    property bool shown: true

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Config.barHeight
    radius: Math.min(Config.islandRadius, height / 2)
    readonly property bool plain: Config.barBackground !== "islands"
    color: plain ? "transparent" : Theme.alpha(Theme.byName(Config.barColor, Theme.surfaceLow), Config.islandOpacity)
    border.width: plain ? 0 : Config.islandBorder
    border.color: Theme.alpha(Theme.byName(Config.borderColor, Theme.outlineVariant), 0.8)
    visible: shown

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.dur(200); easing.type: Easing.OutCubic }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2
    }
}
