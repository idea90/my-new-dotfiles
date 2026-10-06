pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Connection state, Wi-Fi list and connecting, all via nmcli
Singleton {
    id: root

    // Current connection (polled every 5s)
    property string kind: "none"   // wifi | ethernet | none
    property string name: ""
    property int signal: 0          // wifi only, 0-100
    property bool wifiEnabled: true

    // Wi-Fi menu
    property var networks: []       // [{ ssid, signal, secure, active, saved }]
    property bool scanning: false
    property string busySsid: ""    // network being connected to
    property string error: ""

    // nmcli -t escapes ':' as '\:' inside fields
    function splitFields(line) {
        const fields = [""];
        for (let i = 0; i < line.length; i++) {
            if (line[i] === "\\" && i + 1 < line.length) {
                fields[fields.length - 1] += line[++i];
            } else if (line[i] === ":") {
                fields.push("");
            } else {
                fields[fields.length - 1] += line[i];
            }
        }
        return fields;
    }

    function refresh() {
        status.running = true;
    }

    function scan() {
        scanning = true;
        scanProc.running = true;
    }

    function setWifi(on) {
        wifiEnabled = on;
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        delayedRefresh.restart();
    }

    function connect(ssid, password) {
        busySsid = ssid;
        error = "";
        const net = networks.find(n => n.ssid === ssid);
        if (net && net.saved && !password)
            connectProc.command = ["nmcli", "connection", "up", "id", ssid];
        else if (password)
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        else
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        connectProc.running = true;
    }

    function disconnect() {
        Quickshell.execDetached(["nmcli", "connection", "down", "id", name]);
        delayedRefresh.restart();
    }

    Process {
        id: status
        command: ["sh", "-c", "nmcli -t -f WIFI radio;"
            + " nmcli -t -f TYPE,STATE,CONNECTION device | awk -F: '$2==\"connected\" && ($1==\"wifi\" || $1==\"ethernet\") {print $1\"|\"$3; exit}';"
            + " nmcli -t -f IN-USE,SIGNAL device wifi list --rescan no 2>/dev/null | awk -F: '$1==\"*\" {print \"signal|\"$2; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                root.wifiEnabled = lines[0] === "enabled";
                let kind = "none", name = "", signal = 0;
                for (const line of lines.slice(1)) {
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

    Process {
        id: scanProc
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE connection show | awk -F: '$2 ~ /wireless/ {print \"saved:\"$1}';"
            + " nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                const saved = new Set();
                const bySsid = new Map();
                for (const line of text.trim().split("\n")) {
                    if (line.startsWith("saved:")) {
                        saved.add(line.slice(6));
                        continue;
                    }
                    const [inUse, ssid, signal, security] = root.splitFields(line);
                    if (!ssid)
                        continue;   // hidden networks
                    const net = { ssid, signal: parseInt(signal) || 0, secure: !!security && security !== "--", active: inUse === "*" };
                    const old = bySsid.get(ssid);
                    if (!old || net.active || net.signal > old.signal)
                        bySsid.set(ssid, net);
                }
                root.networks = [...bySsid.values()]
                    .map(n => Object.assign(n, { saved: saved.has(n.ssid) }))
                    .sort((a, b) => b.active - a.active || b.signal - a.signal);
                root.scanning = false;
            }
        }
    }

    Process {
        id: connectProc
        stderr: StdioCollector {
            id: connectErr
        }
        onExited: code => {
            if (code !== 0)
                root.error = connectErr.text.trim().replace(/^Error: /, "") || "Could not connect";
            root.busySsid = "";
            root.refresh();
            root.scan();
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: status.running = true
    }

    Timer {
        id: delayedRefresh
        interval: 800
        onTriggered: {
            root.refresh();
            root.scan();
        }
    }
}
