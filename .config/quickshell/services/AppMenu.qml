pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// App launcher state, usage counts and ranking.
// Opened by Super+D (`qs ipc call launcher toggle`) or the bar's Arch button.
Singleton {
    id: root

    property bool open: false
    property var usage: ({})   // desktop entry id -> launch count

    function toggle() {
        open = !open;
    }

    // Lower is better; -1 = no match
    function score(entry, query) {
        if (query === "")
            return 0;
        const name = entry.name.toLowerCase();
        if (name.startsWith(query))
            return 0;
        if (name.split(/[\s\-_.]+/).some(word => word.startsWith(query)))
            return 1;
        if (name.includes(query))
            return 2;
        // Description, keywords, categories: whole-word starts only, to avoid noise
        const extra = [entry.genericName, entry.comment, ...entry.keywords, ...entry.categories].join(" ").toLowerCase();
        if (extra.split(/[\s\-_.;,]+/).some(word => word.startsWith(query)))
            return 3;
        return -1;
    }

    // Matching apps: best match first, then most launched, then A-Z
    function search(entries, text) {
        const query = text.trim().toLowerCase();
        return entries
            .filter(e => !e.noDisplay)
            .map(e => ({ entry: e, score: score(e, query), uses: usage[e.id] ?? 0 }))
            .filter(r => r.score >= 0)
            .sort((a, b) => a.score - b.score || b.uses - a.uses || a.entry.name.localeCompare(b.entry.name))
            .map(r => r.entry);
    }

    function launch(entry) {
        if (entry.runInTerminal)
            Quickshell.execDetached({ command: ["alacritty", "-e", ...entry.command], workingDirectory: entry.workingDirectory });
        else
            entry.execute();
        const counts = Object.assign({}, usage);
        counts[entry.id] = (counts[entry.id] ?? 0) + 1;
        usage = counts;
        usageFile.setText(JSON.stringify(counts));
        open = false;
    }

    FileView {
        id: usageFile
        path: Quickshell.env("HOME") + "/.cache/quickshell/launcher-usage.json"
        onLoaded: {
            try {
                root.usage = JSON.parse(text());
            } catch (e) {}
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle();
        }
        function show(): void {
            root.open = true;
        }
        function hide(): void {
            root.open = false;
        }
    }
}
