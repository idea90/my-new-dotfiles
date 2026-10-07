pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history on top of cliphist (wl-paste --watch cliphist store runs at login).
//   qs ipc call clipboard toggle
Singleton {
    id: root

    property bool open: false
    property var items: []      // [{ id, text, image (file path or ""), line (raw cliphist line) }]
    readonly property string cache: Quickshell.env("HOME") + "/.cache/qs-clipboard"

    function toggle() {
        open = !open;
        if (open)
            refresh();
    }

    function refresh() {
        listProc.running = true;
    }

    // Copy the item back, close, then paste it into the window underneath
    function pick(item) {
        open = false;
        Quickshell.execDetached(["sh", "-c",
            'printf "%s" "$1" | cliphist decode | wl-copy && sleep 0.15 && wtype -M ctrl -k v -m ctrl', "sh", item.line]);
    }

    function remove(item) {
        Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | cliphist delete', "sh", item.line]);
        items = items.filter(i => i.id !== item.id);
    }

    function clear() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        items = [];
    }

    // Lists entries and writes image previews (binary entries) into the cache
    Process {
        id: listProc
        command: ["sh", "-c", `
            mkdir -p "$1"
            cliphist list 2>/dev/null | head -n 80 | while IFS= read -r line; do
                id=\${line%%$(printf '\\t')*}
                case "$line" in
                    *"[[ binary data"*)
                        [ -s "$1/$id.png" ] || printf '%s' "$line" | cliphist decode > "$1/$id.png" 2>/dev/null
                        printf 'I\\t%s\\n' "$line" ;;
                    *) printf 'T\\t%s\\n' "$line" ;;
                esac
            done`, "sh", root.cache]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const l of text.split("\n")) {
                    if (l.length < 3)
                        continue;
                    const kind = l[0];
                    const line = l.slice(2);
                    const tab = line.indexOf("\t");
                    const id = line.slice(0, tab);
                    out.push({
                        id: id,
                        line: line,
                        text: kind === "T" ? line.slice(tab + 1) : "Image",
                        image: kind === "I" ? root.cache + "/" + id + ".png" : ""
                    });
                }
                root.items = out;
            }
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void {
            root.toggle();
        }
    }
}
