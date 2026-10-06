import QtQuick
import Quickshell
import qs
import qs.modules
import qs.services

// Six buttons. Keys: the letter shown on each, or arrows + Enter.
Item {
    id: root

    readonly property var actions: [
        { key: "l", label: "Lock",      icon: 0xf033e, command: ["qs", "ipc", "call", "lock", "lock"] },
        { key: "e", label: "Log out",   icon: 0xf0343, command: ["hyprctl", "dispatch", "exit"] },
        { key: "u", label: "Suspend",   icon: 0xf04b2, command: ["systemctl", "suspend"] },
        { key: "h", label: "Hibernate", icon: 0xf0717, command: ["systemctl", "hibernate"] },
        { key: "r", label: "Reboot",    icon: 0xf0709, command: ["systemctl", "reboot"], danger: true },
        { key: "s", label: "Shut down", icon: 0xf0425, command: ["systemctl", "poweroff"], danger: true }
    ]
    property int current: 0

    function run(action) {
        Panels.close();
        Quickshell.execDetached(action.command);
    }

    Connections {
        target: Panels
        function onOpenChanged() {
            if (Panels.open === "power") {
                root.current = 0;
                row.forceActiveFocus();
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 12
        focus: true

        Keys.onPressed: event => {
            const index = root.actions.findIndex(a => a.key === event.text.toLowerCase());
            if (index >= 0)
                root.run(root.actions[index]);
            else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab)
                root.current = (root.current + root.actions.length - 1) % root.actions.length;
            else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab)
                root.current = (root.current + 1) % root.actions.length;
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                root.run(root.actions[root.current]);
            else if (event.key === Qt.Key_Escape)
                Panels.close();
            else
                return;
            event.accepted = true;
        }

        Repeater {
            model: root.actions

            Rectangle {
                id: button

                required property var modelData
                required property int index
                readonly property bool selected: root.current === index || mouse.containsMouse
                readonly property bool danger: !!modelData.danger

                width: Config.powerButtonWidth
                height: Config.powerButtonHeight
                radius: Theme.radius
                color: selected ? (danger ? Theme.errorContainer : Theme.primaryContainer) : Theme.surfaceMid
                border.width: 1
                border.color: selected ? (danger ? Theme.error : Theme.primary) : Theme.outlineVariant
                scale: selected ? 1.04 : 1

                Behavior on color {
                    ColorAnimation { duration: Theme.dur(150) }
                }
                Behavior on scale {
                    NumberAnimation { duration: Theme.dur(150); easing.type: Easing.OutCubic }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 14

                    BarText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Theme.icon(button.modelData.icon)
                        font.pixelSize: 48
                        color: !button.selected ? Theme.textDim
                             : button.danger ? Theme.errorContainerFg : Theme.primaryContainerFg
                    }
                    BarText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: button.modelData.label
                        color: !button.selected ? Theme.text
                             : button.danger ? Theme.errorContainerFg : Theme.primaryContainerFg
                    }
                    BarText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: button.modelData.key.toUpperCase()
                        font.pixelSize: 11
                        color: Theme.alpha(Theme.text, 0.45)
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.current = button.index
                    onClicked: root.run(button.modelData)
                }
            }
        }
    }
}
