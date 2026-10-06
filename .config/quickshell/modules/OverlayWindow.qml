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
    property string namespace: "qs-panel"   // Hyprland blur rules match on this
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
    WlrLayershell.namespace: win.namespace
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open && grabKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onOpenChanged: {
        if (open) {
            holder.forceActiveFocus();
            appear.restart();
        }
    }

    // Panels fade and grow in
    ParallelAnimation {
        id: appear
        NumberAnimation { target: holder; property: "opacity"; from: 0; to: 1; duration: Theme.dur(180); easing.type: Easing.OutCubic }
        NumberAnimation { target: holder; property: "scale"; from: 0.96; to: 1; duration: Theme.dur(220); easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        // Light scrim: it stays under the blur threshold, so only the panel itself blurs
        color: win.dim ? Theme.alpha("#000000", 0.18) : "transparent"

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
