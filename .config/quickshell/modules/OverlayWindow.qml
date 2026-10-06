import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

// Full-screen overlay for panels and menus. Clicking the backdrop or pressing
// Esc emits dismissed(); put the panel itself in as a child and give it a
// MouseArea so clicks on it don't reach the backdrop.
PanelWindow {
    id: win

    property bool open: false
    property bool dim: true
    property bool grabKeyboard: true
    default property alias content: holder.data

    signal dismissed

    visible: open
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open && grabKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onOpenChanged: if (open) holder.forceActiveFocus()

    Rectangle {
        anchors.fill: parent
        color: win.dim ? Theme.alpha("#000000", 0.35) : "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: win.dismissed()
        }
    }

    Item {
        id: holder
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: win.dismissed()
    }
}
