import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Replaces hyprlock: a Wayland session lock with one surface per monitor.
// The preview is the same content in a normal overlay window.
Scope {
    WlSessionLock {
        locked: Lock.locked

        WlSessionLockSurface {
            LockContent {
                anchors.fill: parent
            }
        }
    }

    Variants {
        model: Lock.preview ? Quickshell.screens : []

        PanelWindow {
            required property var modelData
            screen: modelData
            color: "black"
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell-lock-preview"

            LockContent {
                anchors.fill: parent
                demo: true
            }
        }
    }
}
