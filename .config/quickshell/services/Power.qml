pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

// Power profiles through power-profiles-daemon: power-saver | balanced | performance
Singleton {
    id: root

    property string profile: "balanced"
    property var available: ["power-saver", "balanced"]

    function set(p) {
        profile = p;
        Quickshell.execDetached(["powerprofilesctl", "set", p]);
    }
    function cycle() {
        const i = available.indexOf(profile);
        set(available[(i + 1) % available.length]);
    }
    function label(p) {
        return p === "power-saver" ? "Saver" : p === "performance" ? "Performance" : "Balanced";
    }
    function glyph(p) {
        return String.fromCodePoint(p === "power-saver" ? 0xf032a : p === "performance" ? 0xf04c5 : 0xf05d1);
    }

    Process {
        id: read
        running: true
        command: ["sh", "-c", "powerprofilesctl get; powerprofilesctl list | grep -oE '^[ *]+[a-z-]+:' | tr -d ' *:'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.trim().split("\n");
                if (l.length > 0 && l[0] !== "")
                    root.profile = l[0];
                const av = l.slice(1).filter(s => s !== "").reverse();
                if (av.length > 0)
                    root.available = av;
            }
        }
    }
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: read.running = true
    }
}
