pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

// Screenshot capture on top of ~/.config/hypr/scripts/screenshot.sh.
//   qs ipc call screenshot toggle    toolbar
//   qs ipc call screenshot area|window|screen   capture now with the saved delay/action
Singleton {
    id: root

    property int countdown: 0          // seconds left, 0 = idle
    property bool capturing: false
    property string lastFile: ""
    property bool previewShown: false
    property string pendingMode: ""

    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/screenshot.sh"
    readonly property var flags: ({ area: "--area", window: "--win", screen: "--now" })

    // mode: "area" | "window" | "screen"; empty uses Config.shotMode
    function capture(mode) {
        if (countdown > 0 || capturing)
            return;
        pendingMode = mode || Config.shotMode;
        Panels.close();
        previewShown = false;
        countdown = Config.shotDelay;
        // Let the toolbar fade out, and honor the delay
        start.interval = countdown > 0 ? 1000 : 250;
        start.restart();
    }

    function cancel() {
        start.stop();
        countdown = 0;
    }

    function run() {
        const args = ["bash", script, flags[pendingMode] ?? "--area", "--quiet"];
        if (Config.shotAction === "save")
            args.push("--no-copy");
        else if (Config.shotAction === "copy")
            args.push("--copy-only");
        capturing = true;
        proc.command = args;
        proc.running = true;
    }

    function copy() {
        if (lastFile !== "")
            Quickshell.execDetached(["sh", "-c", "wl-copy --type image/png < \"$1\"", "sh", lastFile]);
    }
    function open() {
        if (lastFile !== "")
            Quickshell.execDetached(["xdg-open", lastFile]);
    }
    function showInFolder() {
        if (lastFile !== "")
            Quickshell.execDetached(["xdg-open", lastFile.replace(/\/[^/]*$/, "")]);
    }
    function discard() {
        if (lastFile !== "")
            Quickshell.execDetached(["rm", "-f", lastFile]);
        previewShown = false;
        lastFile = "";
    }

    Timer {
        id: start
        onTriggered: {
            if (root.countdown > 1) {
                root.countdown -= 1;
                start.restart();
            } else {
                root.countdown = 0;
                // A beat for the countdown card to disappear before grim runs
                grab.restart();
            }
        }
    }
    Timer {
        id: grab
        interval: 200
        onTriggered: root.run()
    }

    Process {
        id: proc
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "") {
                    root.lastFile = data.trim();
                    root.previewShown = Config.shotPreview;
                }
            }
        }
        onExited: root.capturing = false
    }

    IpcHandler {
        target: "screenshot"
        function toggle(): void {
            Panels.toggle("screenshot");
        }
        function area(): void {
            root.capture("area");
        }
        function window(): void {
            root.capture("window");
        }
        function screen(): void {
            root.capture("screen");
        }
        function cancel(): void {
            root.cancel();
        }
    }
}
