import QtQuick
import qs
import qs.services

Pill {
    padding: 3

    Repeater {
        model: Hypr.ids

        Rectangle {
            id: ws

            required property int modelData
            readonly property bool focused: modelData === Hypr.focusedId
            readonly property bool occupied: Hypr.occupied(modelData)
            readonly property bool urgent: Hypr.urgent(modelData)

            width: focused ? 36 : 26
            height: 22
            radius: 7
            color: urgent ? Theme.error
                 : focused ? Theme.primary
                 : mouse.containsMouse ? Theme.alpha(Theme.primaryContainer, 0.6)
                 : "transparent"

            Behavior on width {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            BarText {
                anchors.centerIn: parent
                text: ws.modelData
                font.bold: ws.focused
                color: ws.urgent ? Theme.errorFg
                     : ws.focused ? Theme.primaryFg
                     : ws.occupied ? Theme.text
                     : Theme.alpha(Theme.text, 0.4)
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
