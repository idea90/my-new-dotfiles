import QtQuick
import qs
import qs.modules
import qs.services

// Three zones over the wallpaper (left, center, right); what goes in them is Config.barLayout
Item {
    id: content

    // One continuous bar behind the groups ("solid" style)
    Rectangle {
        anchors.fill: parent
        visible: Config.barBackground === "solid" || Config.barBackground === "band"
        radius: Math.min(Config.barRadius, height / 2)
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
        titleLimit: center.x - left.x
        anchors {
            left: parent.left
            leftMargin: Config.barBackground === "solid" || Config.barBackground === "band" ? 6 : 0
            verticalCenter: parent.verticalCenter
        }
    }

    BarZone {
        id: center
        name: "center"
        // Room the now-playing module can use without running under the side zones
        freeWidth: content.width - 2 * Math.max(left.width, right.width) - 48
        anchors.centerIn: parent
    }

    BarZone {
        id: right
        name: "right"
        anchors {
            right: parent.right
            rightMargin: Config.barBackground === "solid" || Config.barBackground === "band" ? 6 : 0
            verticalCenter: parent.verticalCenter
        }
    }
}
