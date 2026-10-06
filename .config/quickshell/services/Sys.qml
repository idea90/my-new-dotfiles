pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU, memory and temperature (polled every 3s)
Singleton {
    id: root

    property int cpu: 0
    property int memory: 0
    property int temperature: -1   // -1 when the machine exposes none

    property var lastIdle: 0
    property var lastTotal: 0

    Process {
        id: proc
        command: ["sh", "-c", "head -n1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo;"
            + " cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo none"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                // cpu  user nice system idle iowait irq softirq steal
                const t = lines[0].split(/\s+/).slice(1).map(Number);
                const idle = t[3] + (t[4] || 0);
                const total = t.reduce((a, b) => a + b, 0);
                if (root.lastTotal > 0 && total > root.lastTotal)
                    root.cpu = Math.round(100 * (1 - (idle - root.lastIdle) / (total - root.lastTotal)));
                root.lastIdle = idle;
                root.lastTotal = total;

                const kb = name => parseInt(lines.find(l => l.startsWith(name)).split(/\s+/)[1]);
                root.memory = Math.round(100 * (1 - kb("MemAvailable") / kb("MemTotal")));

                const temp = parseInt(lines[3]);
                root.temperature = isNaN(temp) ? -1 : Math.round(temp / 1000);
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
