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

    // Wallhaven browsing (~/.config/hypr/scripts/wallhaven)
    readonly property string havenScript: Quickshell.env("HOME") + "/.config/hypr/scripts/wallhaven"
    property bool online: false
    property var onlineItems: []    // [{ name, path (wallhaven id), thumb (url) }]
    property bool searching: false
    property bool downloading: false
    property string query: ""
    property int page: 1
    property bool error: false
    readonly property var sorts: ["toplist", "relevance", "random", "date_added", "views", "favorites"]
    readonly property var ranges: ["1d", "3d", "1w", "1M", "3M", "6M", "1y"]
    readonly property var resolutions: ["any", "1920x1080", "2560x1440", "3840x2160"]
    readonly property var ratioList: ["any", "16x9", "16x10", "21x9", "9x16"]
    readonly property var colorList: ["any", "660000", "cc3333", "ea4c88", "993399", "0066cc", "0099cc", "66cccc", "77cc33", "999900", "ffcc33", "ff9900", "ff6600", "424153", "999999", "000000", "ffffff"]
    property string sort: "toplist"
    property string range: "1M"
    property string categories: "111"   // general, anime, people
    property string resolution: "1920x1080"
    property string ratio: "any"
    property string color: "any"
    property bool nsfw: false           // needs an API key

    function refresh() {
        loading = true;
        list.running = true;
    }

    function apply(path) {
        Quickshell.execDetached([script, "--apply", path]);
        current = path;
    }

    function search(q, p) {
        query = q;
        page = p || 1;
        searching = true;
        error = false;
        const cmd = [havenScript, "search", query, String(page), "--sort", sort, "--categories", categories,
            "--purity", nsfw ? "111" : "100", "--range", range];
        if (resolution !== "any")
            cmd.push("--atleast", resolution);
        if (ratio !== "any")
            cmd.push("--ratios", ratio);
        if (color !== "any")
            cmd.push("--colors", color);
        haven.command = cmd;
        haven.running = true;
    }

    function toggleCategory(i) {
        const c = categories.split("");
        c[i] = c[i] === "1" ? "0" : "1";
        categories = c.join("") === "000" ? categories : c.join("");
        search(query, 1);
    }

    function set(prop, value) {
        root[prop] = value;
        search(query, 1);
    }

    function download(id) {
        downloading = true;
        dl.command = [havenScript, "get", id, "--apply"];
        dl.running = true;
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

    Process {
        id: haven
        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.trim().split("\n").filter(l => l).map(l => {
                    const [id, , thumb, res] = l.split("\t");
                    return { name: id + "  " + res, path: id, thumb };
                });
                root.onlineItems = root.page > 1 ? root.onlineItems.concat(rows) : rows;
                root.searching = false;
            }
        }
        onExited: code => {
            if (code !== 0) {
                root.error = true;
                root.searching = false;
            }
        }
    }

    Process {
        id: dl
        onExited: root.downloading = false
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
