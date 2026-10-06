pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

// Shows a goodbye message, then runs the power command. Cancel with Esc or a click.
Singleton {
    id: root

    property bool showing: false
    property string message: ""
    property string icon: ""
    property var pending: []

    function pick(kind) {
        const list = Config.goodbyeMessages[kind] ?? [];
        const text = list.length > 0 ? list[Math.floor(Math.random() * list.length)] : "";
        return text.replace("{user}", Quickshell.env("USER"));
    }

    // kind: logout | suspend | hibernate | reboot | poweroff
    function run(kind, command, glyph) {
        const text = Config.goodbyeEnabled ? pick(kind) : "";
        if (text === "") {
            Quickshell.execDetached(command);
            return;
        }
        message = text;
        icon = glyph;
        pending = command;
        showing = true;
        timer.interval = Math.max(300, Config.goodbyeSeconds * 1000);
        timer.restart();
    }

    function cancel() {
        timer.stop();
        showing = false;
        pending = [];
    }

    Timer {
        id: timer
        onTriggered: {
            const command = root.pending;
            root.showing = false;
            root.pending = [];
            Quickshell.execDetached(command);
        }
    }

    // `qs ipc call goodbye preview suspend`: shows the message, runs nothing
    IpcHandler {
        target: "goodbye"
        function preview(kind: string): void {
            root.run(kind || "poweroff", ["true"], String.fromCodePoint(0xf0425));
        }
    }
}
