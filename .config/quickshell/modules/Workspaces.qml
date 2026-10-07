import QtQuick
import Quickshell.Widgets
import qs
import qs.services

// Workspace pills: number plus the icons of the apps on it.
// Focused = filled accent, occupied = normal, empty = dim. Scroll to cycle.
Grid {
    // a row on a top/bottom bar, a column on a side bar
    columns: Theme.vertical ? 1 : 100
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter
    spacing: Config.wsStyle === "dots" ? (Theme.vertical ? 8 : 10) : Config.wsStyle === "lines" ? 6 : 2

    Repeater {
        model: Hypr.ids

        Rectangle {
            id: ws

            required property int modelData
            readonly property bool focused: modelData === Hypr.focusedId
            readonly property var icons: Hypr.appIcons(modelData, 3)
            readonly property bool urgent: Hypr.urgent(modelData)

            readonly property bool dots: Config.wsStyle === "dots"
            readonly property bool lines: Config.wsStyle === "lines"
            // Long side of a dot / line runs along the bar
            readonly property int along: lines ? (focused ? Math.round(30 * Theme.barScale) : Math.round(16 * Theme.barScale))
                 : dots ? (focused ? Math.round(34 * Theme.barScale) : Math.round(11 * Theme.barScale)) : content.implicitWidth + 16
            readonly property int across: lines ? 4 : dots ? Math.round(11 * Theme.barScale) : Theme.barItem
            width: Theme.vertical && (dots || lines) ? across : Theme.vertical ? Theme.barItem : along
            height: Theme.vertical && (dots || lines) ? along : Theme.vertical ? content.implicitHeight + 10 : across
            radius: dots || lines ? Math.min(width, height) / 2 : Theme.chipRadius
            color: urgent ? Theme.error
                 : focused ? Theme.primary
                 : mouse.containsMouse ? Theme.surfaceHigh
                 : (dots || lines ? Theme.alpha(Theme.text, ws.icons.length > 0 ? 0.95 : 0.28) : "transparent")

            Behavior on width {
                NumberAnimation { duration: Theme.dur(420); easing.type: Easing.OutBack; easing.overshoot: 2 }
            }
            Behavior on height {
                NumberAnimation { duration: Theme.dur(420); easing.type: Easing.OutBack; easing.overshoot: 2 }
            }
            Behavior on color {
                ColorAnimation { duration: Theme.dur(200) }
            }

            Grid {
                id: content
                columns: Theme.vertical ? 1 : 100
                horizontalItemAlignment: Grid.AlignHCenter
                verticalItemAlignment: Grid.AlignVCenter
                visible: !ws.dots && !ws.lines
                anchors.centerIn: parent
                spacing: 5

                BarText {
                    text: ws.modelData
                    font.bold: ws.focused
                    font.pixelSize: 13
                    font.family: Theme.barFont
                    color: ws.urgent ? Theme.errorFg
                         : ws.focused ? Theme.primaryFg
                         : ws.icons.length > 0 ? Theme.text
                         : Theme.alpha(Theme.text, 0.4)
                }

                Repeater {
                    model: Config.wsStyle === "numbers" ? [] : ws.icons

                    IconImage {
                        required property string modelData
                        implicitSize: 16
                        source: modelData
                        mipmap: true
                    }
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hypr.focus(ws.modelData)
                onWheel: event => Hypr.cycle(event.angleDelta.y > 0 ? -1 : 1)
            }
        }
    }
}
