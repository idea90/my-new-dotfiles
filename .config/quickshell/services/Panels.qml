pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which panel is open. Only one at a time; each has an IPC target so
// Hyprland keybinds can use `qs ipc call <target> toggle`.
Singleton {
    id: root

    property string settingsTab: ""   // set to jump the settings panel to a section
    property string open: ""   // "" | controlcenter | calendar | power | theme | wifi | settings | screenshot

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
        target: "theme"
        function toggle(): void {
            root.toggle("theme");
        }
    }
    // Old name, kept so existing keybinds still work
    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            root.toggle("theme");
        }
    }
    IpcHandler {
        target: "wifi"
        function toggle(): void {
            root.toggle("wifi");
        }
    }
    IpcHandler {
        target: "settings"
        function toggle(): void {
            root.toggle("settings");
        }
        // qs ipc call settings tab "Control center"
        function tab(name: string): void {
            root.settingsTab = name;
            root.open = "settings";
        }
    }
    IpcHandler {
        target: "mixer"
        function toggle(): void {
            root.toggle("mixer");
        }
    }
    IpcHandler {
        target: "bluetooth"
        function toggle(): void {
            root.toggle("bluetooth");
        }
    }
    IpcHandler {
        target: "battery"
        function toggle(): void {
            root.toggle("battery");
        }
    }
}
