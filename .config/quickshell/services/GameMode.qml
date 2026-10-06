pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Game mode (no animations/blur/gaps) via ~/.config/hypr/scripts/gamemode.sh
Singleton {
    id: root

    property bool active: false

    function toggle() {
        active = !active;
        Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/gamemode.sh"]);
        check.restart();
    }

    function refresh() {
        proc.running = true;
    }

    Process {
        id: proc
        command: ["sh", "-c", "test -f ~/.cache/gamemode"]
        onExited: code => root.active = code === 0
    }

    Timer {
        id: check
        interval: 500
        onTriggered: proc.running = true
    }

    Component.onCompleted: refresh()
}
