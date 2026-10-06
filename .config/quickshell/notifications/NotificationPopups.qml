import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// New notifications, top right under the bar
PanelWindow {
    visible: Notifs.popups.length > 0 && Panels.open !== "controlcenter"
    color: "transparent"
    anchors {
        top: true
        right: true
    }
    margins {
        top: 8
        right: 12
    }
    implicitWidth: 380
    implicitHeight: column.implicitHeight
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    Column {
        id: column
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.popups.slice().reverse()   // newest on top

            NotificationCard {
                id: popup
                required property var modelData
                notification: modelData
                popup: true
                width: column.width

                Timer {
                    interval: Notifs.popupSeconds(popup.notification) * 1000
                    running: interval > 0
                    onTriggered: Notifs.hidePopup(popup.notification)
                }
            }
        }
    }
}
