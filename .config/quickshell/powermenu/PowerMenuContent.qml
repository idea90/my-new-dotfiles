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
        { key: "e", label: "Log out",   icon: 0xf0343, kind: "logout", command: ["sh", "-c", "hyprctl dispatch 'hl.dsp.exit()' | grep -q ok || hyprctl dispatch exit"] },
        { key: "u", label: "Suspend",   icon: 0xf04b2, kind: "suspend", command: ["systemctl", "suspend"] },
        { key: "h", label: "Hibernate", icon: 0xf0717, kind: "hibernate", command: ["systemctl", "hibernate"] },
        { key: "r", label: "Reboot",    icon: 0xf0709, kind: "reboot", command: ["systemctl", "reboot"], danger: true },
        { key: "s", label: "Shut down", icon: 0xf0425, kind: "poweroff", command: ["systemctl", "poweroff"], danger: true }
    ]
    property int current: 0

    function run(action) {
        Panels.close();
        if (action.kind)
            Goodbye.run(action.kind, action.command, Theme.icon(action.icon));
        else
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

    readonly property int cols: Config.powerLayout === "column" ? 1 : Config.powerLayout === "grid" ? 3 : actions.length
    readonly property string shape: Config.powerShape   // card | circle | pill

    function move(d) {
        current = (current + d + actions.length) % actions.length;
    }

    readonly property string pos: Config.powerPosition   // center | bottom | left | right | corner
    readonly property bool side: pos === "left" || pos === "right"
    readonly property bool outline: Config.powerHighlight === "outline"

    // Panel behind the buttons for the side / corner placements
    Rectangle {
        visible: root.side || root.pos === "corner"
        // Plain x/y/width/height (no left/right anchors) so switching sides never
        // leaves both anchors set and collapses the width
        x: root.pos === "left" ? 0 : parent.width - width - (root.pos === "corner" ? 12 : 0)
        y: root.side ? 0 : Config.barMarginTop + Config.barHeight + 8
        width: menu.width + 64
        height: root.side ? parent.height : menu.height + 48
        radius: root.side ? 0 : Config.panelRadius
        color: Theme.alpha(Theme.surfaceHigh, 0.9)
        border.width: root.side ? 0 : Config.panelBorder
        border.color: Theme.panelBorderFill

        // Inner edge line for the side panels
        Rectangle {
            visible: root.side
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: root.pos === "left" ? parent.right : undefined
                left: root.pos === "left" ? undefined : parent.left
            }
            color: Theme.alpha(Theme.outline, 0.6)
        }

        MouseArea {
            anchors.fill: parent
        }
    }

    Column {
        id: menu
        x: root.pos === "left" ? 32
         : root.side || root.pos === "corner" ? parent.width - width - 32 - (root.pos === "corner" ? 12 : 0)
         : (parent.width - width) / 2
        y: root.pos === "bottom" ? parent.height - height - 70
         : root.pos === "corner" ? Config.barMarginTop + Config.barHeight + 32
         : (parent.height - height) / 2
        spacing: 28

        // Optional header: avatar, big clock and a goodbye line
        Column {
            visible: Config.powerHeader
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Rectangle {
                visible: Config.powerAvatar
                anchors.horizontalCenter: parent.horizontalCenter
                width: 72
                height: 72
                radius: 36
                color: Theme.primaryContainer
                border.width: 3
                border.color: Theme.primary
                BarText {
                    anchors.centerIn: parent
                    text: Quickshell.env("USER").charAt(0).toUpperCase()
                    font.pixelSize: 32
                    font.bold: true
                    color: Theme.primaryContainerFg
                }
            }
            BarText {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: Config.powerClock
                text: Qt.formatDateTime(Time.now, Config.clock24h ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "")
                font.pixelSize: root.side || root.pos === "corner" ? 48 : 72
                font.bold: true
                color: "#ffffff"
            }
            BarText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "See you later, " + Quickshell.env("USER")
                font.pixelSize: 16
                color: Qt.rgba(1, 1, 1, 0.8)
            }
        }

        Grid {
            id: row
            anchors.horizontalCenter: parent.horizontalCenter
            columns: root.cols
            spacing: Config.powerSpacing
            focus: true

            Keys.onPressed: event => {
                const index = root.actions.findIndex(a => a.key === event.text.toLowerCase());
                if (index >= 0)
                    root.run(root.actions[index]);
                else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab)
                    root.move(-1);
                else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab)
                    root.move(1);
                else if (event.key === Qt.Key_Up)
                    root.move(-root.cols);
                else if (event.key === Qt.Key_Down)
                    root.move(root.cols);
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

                Item {
                    id: button

                    required property var modelData
                    required property int index
                    readonly property bool selected: root.current === index || mouse.containsMouse
                    readonly property bool danger: !!modelData.danger
                    readonly property color fg: !selected ? Theme.text : root.outline ? (danger ? Theme.error : Theme.primary) : danger ? Theme.errorContainerFg : Theme.primaryContainerFg

                    width: root.shape === "pill" ? Config.powerButtonWidth * 1.6
                         : root.shape === "circle" ? Config.powerButtonWidth * 0.62 + 20 : Config.powerButtonWidth
                    height: root.shape === "pill" ? 58
                          : root.shape === "circle" ? Config.powerButtonWidth * 0.62 + (Config.powerLabels ? 34 : 0)
                          : Config.powerButtonHeight

                    Rectangle {
                        id: face
                        width: root.shape === "circle" ? Config.powerButtonWidth * 0.62 : parent.width
                        height: root.shape === "circle" ? width : parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: root.shape === "circle" || root.shape === "pill" ? height / 2 : Theme.radius
                        color: button.selected && !root.outline ? (button.danger ? Theme.errorContainer : Theme.primaryContainer)
                             : Theme.alpha(Theme.surfaceMid, Config.powerOpacity)
                        border.width: button.selected && root.outline ? 2 : Config.powerBorder ? 1 : 0
                        border.color: button.selected ? (button.danger ? Theme.error : Theme.primary) : Theme.alpha(Theme.outlineVariant, 0.8)
                        scale: button.selected ? 1.05 : 1

                        Behavior on color {
                            ColorAnimation { duration: Theme.dur(150) }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: Theme.dur(150); easing.type: Easing.OutCubic }
                        }

                        // card: icon over label over key
                        Column {
                            visible: root.shape === "card"
                            anchors.centerIn: parent
                            spacing: 14
                            BarText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Theme.icon(button.modelData.icon)
                                font.pixelSize: Config.powerIconSize
                                color: button.selected ? button.fg : Theme.textDim
                            }
                            BarText {
                                visible: Config.powerLabels
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: button.modelData.label
                                color: button.fg
                            }
                            BarText {
                                visible: Config.powerKeys
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: button.modelData.key.toUpperCase()
                                font.pixelSize: 11
                                color: Theme.alpha(Theme.text, 0.45)
                            }
                        }

                        // circle: icon only (label sits under the circle)
                        BarText {
                            visible: root.shape === "circle"
                            anchors.centerIn: parent
                            text: Theme.icon(button.modelData.icon)
                            font.pixelSize: Config.powerIconSize * 0.75
                            color: button.selected ? button.fg : Theme.textDim
                        }

                        // pill: icon, label, key in a row
                        Row {
                            visible: root.shape === "pill"
                            anchors {
                                left: parent.left
                                leftMargin: 22
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: 14
                            BarText {
                                text: Theme.icon(button.modelData.icon)
                                font.pixelSize: 22
                                color: button.selected ? button.fg : Theme.textDim
                            }
                            BarText {
                                visible: Config.powerLabels
                                text: button.modelData.label
                                font.pixelSize: 15
                                color: button.fg
                            }
                        }
                        BarText {
                            visible: root.shape === "pill" && Config.powerKeys
                            anchors {
                                right: parent.right
                                rightMargin: 22
                                verticalCenter: parent.verticalCenter
                            }
                            text: button.modelData.key.toUpperCase()
                            font.pixelSize: 11
                            color: Theme.alpha(Theme.text, 0.45)
                        }
                    }

                    BarText {
                        visible: root.shape === "circle" && Config.powerLabels
                        anchors {
                            top: face.bottom
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: button.modelData.label + (Config.powerKeys ? "  " + button.modelData.key.toUpperCase() : "")
                        font.pixelSize: 13
                        color: button.selected ? Theme.text : Qt.rgba(1, 1, 1, 0.8)
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
}
