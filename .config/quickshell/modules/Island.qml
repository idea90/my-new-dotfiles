import QtQuick
import QtQuick.Effects
import qs

// One floating island of the bar
Rectangle {
    id: island

    default property alias content: row.data
    property int padding: 4
    // Set from outside: an island can't tell from its children, because a
    // hidden island also hides them (and could then never come back)
    property bool shown: true

    implicitWidth: Theme.vertical ? Theme.islandHeight : row.implicitWidth + padding * 2
    implicitHeight: Theme.vertical ? row.implicitHeight + padding * 2 : Theme.islandHeight
    radius: Math.min(Config.islandRadius, Math.min(width, height) / 2)
    readonly property bool plain: Config.barBackground === "solid" || Config.barBackground === "none"
    color: plain ? "transparent" : Theme.alpha(Theme.byName(Config.barColor, Theme.surfaceLow), Config.islandOpacity)
    border.width: plain ? 0 : Config.islandBorder
    border.color: Theme.alpha(Theme.byName(Config.borderColor, Theme.outlineVariant), 0.8)
    visible: shown

    layer.enabled: Config.islandShadow && !plain
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.5)
        shadowBlur: 0.7
        shadowVerticalOffset: 3
    }

    Behavior on implicitHeight {
        enabled: Theme.vertical
        NumberAnimation { duration: Theme.dur(200); easing.type: Easing.OutCubic }
    }
    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.dur(200); easing.type: Easing.OutCubic }
    }

    // A row on a top/bottom bar, a column on a side bar
    Grid {
        id: row
        anchors.centerIn: parent
        columns: Theme.vertical ? 1 : 100
        spacing: 2
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
    }
}
