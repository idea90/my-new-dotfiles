pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

// Changes the wallpaper (and so the colors) by itself.
//   slideMode "minutes" / "hours": a new one every slideMinutes / slideHours
//   slideMode "daytime": one per part of the day (slideMorning / Day / Evening / Night)
//   slideSource "local": random from ~/wallpapers
//   slideSource "wallhaven": random wallhaven picture for one of slideTopics
//     ("nature, cyberpunk city, anime"), a different topic picked each time
// The last change time is kept on disk, so "every 24 hours" survives reboots.
//   qs ipc call slideshow next
Singleton {
    id: root

    property string lastPart: ""
    property real lastChange: 0          // ms since epoch
    property string lastTopic: ""
    property bool busy: false
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/apply-wal"
    readonly property string haven: Quickshell.env("HOME") + "/.config/hypr/scripts/wallhaven"

    readonly property real intervalMs: Config.slideMode === "hours" ? Math.max(1, Config.slideHours) * 3600000
        : Math.max(1, Config.slideMinutes) * 60000
    readonly property real nextChange: lastChange > 0 ? lastChange + intervalMs : 0

    readonly property var topics: Config.slideTopics.split(",").map(t => t.trim()).filter(t => t !== "")

    function partOfDay(d) {
        const h = d.getHours();
        return h >= 6 && h < 11 ? "morning" : h >= 11 && h < 17 ? "day" : h >= 17 && h < 21 ? "evening" : "night";
    }

    // Pick and apply a new wallpaper now
    function next() {
        if (busy)
            return;
        if (Config.slideSource === "wallhaven") {
            const list = topics.length ? topics : [""];
            // a different topic from last time when there is a choice
            let pick = list[Math.floor(Math.random() * list.length)];
            if (list.length > 1)
                while (pick === lastTopic)
                    pick = list[Math.floor(Math.random() * list.length)];
            lastTopic = pick;
            busy = true;
            const env = "WALLHAVEN_PURITY=100 WALLHAVEN_CATEGORIES=" + Wallpapers.categories
                + " WALLHAVEN_ATLEAST=" + (Wallpapers.resolution === "any" ? "1920x1080" : Wallpapers.resolution);
            fetch.command = ["sh", "-c", env + ' "$1" random "$2"', "sh", haven, pick];
            fetch.running = true;
        } else {
            Quickshell.execDetached([script, "--random"]);
        }
        markChanged();
    }

    function markChanged() {
        lastChange = Date.now();
        stamp.setText(JSON.stringify({ time: lastChange, topic: lastTopic }));
    }

    // wallhaven download + apply; if it fails (offline, no results), use a local one
    Process {
        id: fetch
        onExited: code => {
            root.busy = false;
            if (code !== 0) {
                console.warn("Slideshow: wallhaven failed, using a local wallpaper");
                Quickshell.execDetached([root.script, "--random"]);
            }
        }
    }

    FileView {
        id: stamp
        path: Quickshell.env("HOME") + "/.cache/quickshell/slideshow.json"
        printErrors: false
        onLoaded: {
            try {
                const d = JSON.parse(text());
                root.lastChange = d.time || 0;
                root.lastTopic = d.topic || "";
            } catch (e) {}
        }
    }

    // One clock for every mode: checks each minute (and right after start-up)
    Timer {
        interval: 60 * 1000
        running: Config.slideshow
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (Config.slideMode === "daytime") {
                const part = root.partOfDay(new Date());
                if (part === root.lastPart)
                    return;
                root.lastPart = part;
                const file = { morning: Config.slideMorning, day: Config.slideDay, evening: Config.slideEvening, night: Config.slideNight }[part];
                if (file !== "") {
                    Quickshell.execDetached([root.script, "--apply", file.startsWith("/") ? file : Quickshell.env("HOME") + "/wallpapers/" + file]);
                    root.markChanged();
                } else {
                    root.next();
                }
            } else if (root.lastChange === 0) {
                // First run: start counting from now instead of changing at once
                root.markChanged();
            } else if (Date.now() >= root.nextChange) {
                root.next();
            }
        }
    }

    IpcHandler {
        target: "slideshow"
        function next(): void {
            root.next();
        }
    }
}
