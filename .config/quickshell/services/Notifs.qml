pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Unread count and Do Not Disturb from swaync (streamed by swaync-client -swb)
Singleton {
    id: root

    property int count: 0
    property bool dnd: false

    function togglePanel() {
        Quickshell.execDetached(["swaync-client", "-t", "-sw"]);
    }

    function toggleDnd() {
        Quickshell.execDetached(["swaync-client", "-d", "-sw"]);
    }

    Process {
        id: proc
        running: true
        command: ["swaync-client", "-swb"]
        stdout: SplitParser {
            // {"text": "2", "alt": "dnd-notification", ...}
            onRead: line => {
                try {
                    const state = JSON.parse(line);
                    root.count = parseInt(state.text) || 0;
                    root.dnd = String(state.alt).startsWith("dnd");
                } catch (e) {}
            }
        }
        // swaync restarted or not up yet: try again shortly
        onRunningChanged: if (!running) retry.start()
    }

    Timer {
        id: retry
        interval: 3000
        onTriggered: proc.running = true
    }
}
