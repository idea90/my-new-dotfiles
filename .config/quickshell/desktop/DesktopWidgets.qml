import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Desktop widgets on the layer below windows: the clock on the left,
// cards bottom right. Each is its own small window, so the empty desktop
// around them stays clickable. `qs ipc call desktop toggle` hides them.
Scope {
    PanelWindow {
        visible: Panels.desktopWidgets
        color: "transparent"
        anchors {
            top: true
            left: true
        }
        margins {
            top: 140
            left: 70
        }
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: clock.implicitWidth + 20
        implicitHeight: clock.implicitHeight + 20
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell-desktop"

        ClockFace {
            id: clock
            x: 10
            y: 10
        }
    }

    PanelWindow {
        visible: Panels.desktopWidgets && cards.implicitHeight > 0
        color: "transparent"
        anchors {
            bottom: true
            right: true
        }
        margins {
            bottom: 24
            right: 24
        }
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 300
        implicitHeight: cards.implicitHeight
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell-desktop"

        Column {
            id: cards
            width: parent.width
            spacing: 12

            WeatherCard {
                width: parent.width
            }
            MediaCard {
                width: parent.width
            }
            SystemCard {
                width: parent.width
            }
        }
    }
}
