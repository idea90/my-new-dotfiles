pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen backlight via brightnessctl (polled; sysfs doesn't notify)
Singleton {
    id: root

    property bool available: false
    property int percent: 0

    function set(fraction) {
        percent = Math.max(1, Math.round(fraction * 100));
        Quickshell.execDetached(["brightnessctl", "-c", "backlight", "set", percent + "%"]);
    }

    function change(step) {
        Quickshell.execDetached(["brightnessctl", "-c", "backlight", "set", step > 0 ? "5%+" : "5%-"]);
        refresh.restart();
    }

    Process {
        id: proc
        // backlight class only, so a keyboard LED is never picked
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            // e.g. "intel_backlight,backlight,1200,40%,3000"
            onStreamFinished: {
                const fields = text.trim().split(",");
                root.available = fields.length >= 4;
                if (root.available)
                    root.percent = parseInt(fields[3]);
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Timer {
        id: refresh
        interval: 100
        onTriggered: proc.running = true
    }
}
