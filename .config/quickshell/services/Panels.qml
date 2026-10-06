pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which panel is open. Only one at a time; each has an IPC target so
// Hyprland keybinds can use `qs ipc call <target> toggle`.
Singleton {
    id: root

    property string open: ""   // "" | controlcenter | calendar | power | wallpaper | wifi

    function toggle(name) {
        open = open === name ? "" : name;
    }

    function close() {
        open = "";
    }

    IpcHandler {
        target: "controlcenter"
        function toggle(): void {
            root.toggle("controlcenter");
        }
    }
    IpcHandler {
        target: "calendar"
        function toggle(): void {
            root.toggle("calendar");
        }
    }
    IpcHandler {
        target: "power"
        function toggle(): void {
            root.toggle("power");
        }
    }
    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            root.toggle("wallpaper");
        }
    }
    IpcHandler {
        target: "wifi"
        function toggle(): void {
            root.toggle("wifi");
        }
    }
}
