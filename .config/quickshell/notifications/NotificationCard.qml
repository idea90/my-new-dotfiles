import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs
import qs.modules

// One notification: icon or image, app and summary, body, action buttons,
// close button. Clicking the card runs the app's default action.
Rectangle {
    id: card

    required property var notification
    property bool popup: false
    readonly property bool critical: notification.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: notification.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: notification.actions.filter(a => a.identifier !== "default")
    readonly property string iconSource: notification.image !== "" ? notification.image
        : notification.appIcon !== "" ? (notification.appIcon.startsWith("/") || notification.appIcon.includes("://")
            ? notification.appIcon : Quickshell.iconPath(notification.appIcon, true))
        : ""

    implicitHeight: content.implicitHeight + 24
    radius: Config.itemRadius
    // Pop-ups are see-through so Hyprland's blur shows behind them
    color: popup ? Theme.alpha(hover.hovered ? Theme.surfaceHigh : Theme.surfaceMid, Config.notifOpacity)
                 : hover.hovered ? Theme.surfaceHigh : Theme.surfaceMid
    border.width: 1
    border.color: critical ? Theme.error : Theme.outlineVariant

    Behavior on color {
        ColorAnimation { duration: Theme.dur(150) }
    }

    HoverHandler {
        id: hover
    }

    // Red stripe for critical
    Rectangle {
        visible: card.critical
        width: 3
        radius: 2
        color: Theme.error
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 8
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: card.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (card.defaultAction)
                card.defaultAction.invoke();
            else if (card.popup)
                Notifs.hidePopup(card.notification);
        }
    }

    Column {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 12
            leftMargin: card.critical ? 18 : 12
        }
        spacing: 8

        Row {
            width: parent.width
            spacing: 12

            IconImage {
                id: icon
                visible: card.iconSource !== ""
                implicitSize: 40
                source: card.iconSource
                mipmap: true
            }

            Column {
                width: parent.width - (icon.visible ? icon.width + 12 : 0) - 26
                spacing: 2

                BarText {
                    width: parent.width
                    text: card.notification.appName || "Notification"
                    color: Theme.textDim
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
                BarText {
                    width: parent.width
                    text: card.notification.summary
                    font.bold: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
                BarText {
                    width: parent.width
                    visible: text !== ""
                    text: card.notification.body
                    textFormat: Text.StyledText
                    color: Theme.textDim
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    wrapMode: Text.Wrap
                    maximumLineCount: card.popup ? 3 : 6
                    elide: Text.ElideRight
                }
            }
        }

        Row {
            visible: card.buttons.length > 0
            spacing: 6

            Repeater {
                model: card.buttons

                Chip {
                    required property var modelData
                    label: modelData.text
                    bg: Theme.surfaceHighest
                    hoverBg: Theme.primaryContainer
                    hoverFg: Theme.primaryContainerFg
                    onLeftClicked: modelData.invoke()
                }
            }
        }
    }

    // Close: dismisses it everywhere
    Chip {
        anchors {
            top: parent.top
            right: parent.right
            margins: 6
        }
        implicitHeight: 24
        padding: 5
        icon: Theme.icon(0xf0156)
        fg: Theme.textDim
        hoverBg: Theme.error
        hoverFg: Theme.errorFg
        onLeftClicked: card.notification.dismiss()
    }
}
