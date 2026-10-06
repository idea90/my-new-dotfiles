pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper list and theme state. The work (thumbnails, awww, matugen) is
// done by ~/.config/hypr/scripts/apply-wal; this only calls it.
Singleton {
    id: root

    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/apply-wal"
    readonly property var schemes: ["tonal-spot", "content", "expressive", "fidelity", "fruit-salad", "monochrome", "neutral", "rainbow"]

    property var items: []          // [{ name, path, thumb }], newest first
    property bool loading: false
    property string current: ""
    property string mode: "dark"
    property string scheme: "tonal-spot"

    function refresh() {
        loading = true;
        list.running = true;
    }

    function apply(path) {
        Quickshell.execDetached([script, "--apply", path]);
        current = path;
    }

    function random() {
        Quickshell.execDetached([script, "--random"]);
    }

    function toggleMode() {
        mode = mode === "dark" ? "light" : "dark";
        Quickshell.execDetached([script, "--mode", mode]);
    }

    function setScheme(name) {
        scheme = name;
        Quickshell.execDetached([script, "--scheme", "scheme-" + name]);
    }

    // apply-wal --list makes missing thumbnails, then prints name<TAB>path<TAB>thumb
    Process {
        id: list
        command: [root.script, "--list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.items = text.trim().split("\n").filter(l => l).map(l => {
                    const [name, path, thumb] = l.split("\t");
                    return { name, path, thumb };
                });
                root.loading = false;
            }
        }
    }

    FileView {
        path: Quickshell.env("HOME") + "/.cache/current_wallpaper"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.current = text().trim()
    }

    // MODE=dark / TYPE=scheme-tonal-spot, written by apply-wal
    FileView {
        path: Quickshell.env("HOME") + "/.config/hypr/scripts/.env"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            for (const line of text().split("\n")) {
                const [key, value] = line.split("=");
                if (key === "MODE" && value)
                    root.mode = value.trim();
                else if (key === "TYPE" && value)
                    root.scheme = value.trim().replace(/^scheme-/, "");
            }
        }
    }
}
