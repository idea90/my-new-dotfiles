import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules
import qs.services

// Alt+Tab overlay. Config.switcherStyle picks the look:
//   cards  big app tiles in a row, window title under each
//   list   vertical list with icon, title and app name
//   icons  compact row of icons, the selected window's title underneath
PanelWindow {
    id: win

    readonly property string look: Config.switcherStyle
    visible: Switcher.open
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Switcher.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "qs-panel"

    onVisibleChanged: if (visible) keys.forceActiveFocus()

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", 0.18)
        MouseArea {
            anchors.fill: parent
            onClicked: Switcher.cancel()
        }
    }

    // Keyboard: releasing Alt picks the window; Tab / arrows move; Esc cancels
    Item {
        id: keys
        focus: true
        Keys.onReleased: event => {
            if (event.key === Qt.Key_Alt || event.key === Qt.Key_Meta || event.key === Qt.Key_Super_L) {
                Switcher.commit();
                event.accepted = true;
            }
        }
        Keys.onPressed: event => {
            const k = event.key;
            if (k === Qt.Key_Escape)
                Switcher.cancel();
            else if (k === Qt.Key_Return || k === Qt.Key_Enter)
                Switcher.commit();
            else if (k === Qt.Key_Tab || k === Qt.Key_Right || k === Qt.Key_Down)
                Switcher.step(1);
            else if (k === Qt.Key_Backtab || k === Qt.Key_Left || k === Qt.Key_Up)
                Switcher.step(-1);
            else
                return;
            event.accepted = true;
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, body.implicitWidth + 36)
        height: body.implicitHeight + 36
        radius: Config.panelRadius + 4
        color: Theme.panelFill
        border.width: Config.panelBorder
        border.color: Theme.panelBorderFill

        MouseArea {
            anchors.fill: parent
        }

        Loader {
            id: body
            anchors.centerIn: parent
            sourceComponent: win.look === "list" ? listLook : win.look === "icons" ? iconsLook : cardsLook
        }
    }

    // ---- cards ----
    Component {
        id: cardsLook
        Row {
            spacing: 10
            Repeater {
                model: Switcher.windows.slice(0, 8)
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === Switcher.index
                    width: 132
                    height: 140
                    radius: Config.itemRadius + 4
                    color: sel ? Theme.primaryContainer : Theme.alpha(Theme.surfaceHigh, 0.7)
                    border.width: sel ? 2 : 0
                    border.color: Theme.primary
                    scale: sel ? 1.05 : 1
                    Behavior on scale {
                        NumberAnimation { duration: Theme.dur(120); easing.type: Easing.OutCubic }
                    }
                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 16
                        spacing: 10
                        IconImage {
                            anchors.horizontalCenter: parent.horizontalCenter
                            implicitSize: 56
                            source: modelData.icon
                            mipmap: true
                        }
                        BarText {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData.appClass
                            font.bold: true
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            color: sel ? Theme.primaryContainerFg : Theme.text
                        }
                        BarText {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData.title
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            color: sel ? Theme.alpha(Theme.primaryContainerFg, 0.75) : Theme.textDim
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: Switcher.index = index
                        onClicked: Switcher.commit()
                    }
                }
            }
        }
    }

    // ---- list ----
    Component {
        id: listLook
        Column {
            spacing: 4
            Repeater {
                model: Switcher.windows.slice(0, 10)
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === Switcher.index
                    width: 460
                    height: 52
                    radius: Config.itemRadius + 2
                    color: sel ? Theme.primaryContainer : "transparent"
                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: 14
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 14
                        IconImage {
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 32
                            source: modelData.icon
                            mipmap: true
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            BarText {
                                width: 330
                                text: modelData.title
                                elide: Text.ElideRight
                                color: sel ? Theme.primaryContainerFg : Theme.text
                            }
                            BarText {
                                text: modelData.appClass + "  ·  workspace " + modelData.workspace
                                font.pixelSize: 11
                                color: sel ? Theme.alpha(Theme.primaryContainerFg, 0.7) : Theme.textDim
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: Switcher.index = index
                        onClicked: Switcher.commit()
                    }
                }
            }
        }
    }

    // ---- icons ----
    Component {
        id: iconsLook
        Column {
            spacing: 14
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                Repeater {
                    model: Switcher.windows.slice(0, 12)
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        readonly property bool sel: index === Switcher.index
                        width: 76
                        height: 76
                        radius: Config.itemRadius + 6
                        color: sel ? Theme.alpha(Theme.text, 0.16) : "transparent"
                        border.width: sel ? 2 : 0
                        border.color: Theme.primary
                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 52
                            source: modelData.icon
                            mipmap: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: Switcher.index = index
                            onClicked: Switcher.commit()
                        }
                    }
                }
            }
            BarText {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(implicitWidth, 520)
                elide: Text.ElideRight
                text: Switcher.windows[Switcher.index] ? Switcher.windows[Switcher.index].title : ""
                font.pixelSize: 14
            }
        }
    }
}
