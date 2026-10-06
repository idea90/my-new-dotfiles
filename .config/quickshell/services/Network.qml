pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Connection state via nmcli (polled every 5s)
Singleton {
    id: root

    property string kind: "none"   // wifi | ethernet | none
    property string name: ""
    property int signal: 0          // wifi only, 0-100

    Process {
        id: proc
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device | awk -F: '$2==\"connected\" && ($1==\"wifi\" || $1==\"ethernet\") {print $1\"|\"$3; exit}';"
            + " nmcli -t -f IN-USE,SIGNAL device wifi list --rescan no 2>/dev/null | awk -F: '$1==\"*\" {print \"signal|\"$2; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let kind = "none", name = "", signal = 0;
                for (const line of text.trim().split("\n")) {
                    const [key, value] = line.split("|");
                    if (key === "wifi" || key === "ethernet") {
                        kind = key;
                        name = value ?? "";
                    } else if (key === "signal") {
                        signal = parseInt(value) || 0;
                    }
                }
                root.kind = kind;
                root.name = name;
                root.signal = signal;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
