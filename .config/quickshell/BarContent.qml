import QtQuick
import qs
import qs.modules
import qs.services

// Three zones over the wallpaper (left, center, right; top, middle, bottom on a
// side bar); what goes in them is Config.barLayout
Item {
    id: content

    // One continuous bar behind the groups ("solid" style)
    Rectangle {
        anchors.fill: parent
        visible: Config.barBackground === "solid" || Config.barBackground === "band"
        radius: Math.min(Config.barRadius, Math.min(width, height) / 2)
        color: Config.barBackground === "band"
            ? Theme.alpha(Theme.byName(Config.bandColor, Theme.primaryContainer), Config.bandOpacity)
            : Theme.alpha(Theme.byName(Config.barColor, Theme.surfaceLow), Config.islandOpacity)
        border.width: Config.barBackground === "band" ? 0 : Config.islandBorder
        border.color: Theme.alpha(Theme.byName(Config.borderColor, Theme.outlineVariant), 0.8)
    }

    BarZone {
        id: left
        name: "left"
        // The title may grow until it reaches the center zone
        titleLimit: Theme.vertical ? -1 : center.x - left.x
        x: Theme.vertical ? (parent.width - width) / 2 : (Config.barBackground === "solid" || Config.barBackground === "band" ? 6 : 0)
        y: Theme.vertical ? (Config.barBackground === "solid" || Config.barBackground === "band" ? 6 : 0) : (parent.height - height) / 2
    }

    BarZone {
        id: center
        name: "center"
        // Room the now-playing module can use without running under the side zones
        freeWidth: Theme.vertical ? 0 : content.width - 2 * Math.max(left.width, right.width) - 48
        anchors.centerIn: parent
    }

    BarZone {
        id: right
        name: "right"
        readonly property int inset: Config.barBackground === "solid" || Config.barBackground === "band" ? 6 : 0
        x: Theme.vertical ? (parent.width - width) / 2 : parent.width - width - inset
        y: Theme.vertical ? parent.height - height - inset : (parent.height - height) / 2
    }
}
