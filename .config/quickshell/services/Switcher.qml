pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Alt+Tab window switcher state.
//   qs ipc call switcher next | prev   open, or move the selection
//   qs ipc call switcher commit        focus the selected window and close (Alt released)
//   qs ipc call switcher cancel
Singleton {
    id: root

    property bool open: false
    property int index: 0
    // [{ address, title, appClass, icon, workspace }] most recently used first
    property var windows: []
    property int openDir: 1        // direction used to open (next / prev)
    property bool moved: false     // user moved the selection after opening

    function build() {
        const list = [];
        for (const top of Hyprland.toplevels.values) {
            const o = top.lastIpcObject;
            if (!o || !o.address || o.mapped === false || o.hidden)
                continue;
            const cls = o["class"] || o.initialClass || "";
            const entry = DesktopEntries.heuristicLookup(cls);
            list.push({
                address: o.address,
                title: o.title || cls,
                appClass: entry ? entry.name : cls,
                icon: Quickshell.iconPath(entry ? entry.icon : cls.toLowerCase(), "application-x-executable"),
                workspace: o.workspace ? o.workspace.name : "",
                order: o.focusHistoryID ?? 999
            });
        }
        list.sort((a, b) => a.order - b.order);
        windows = list;
    }

    function step(d) {
        if (!open) {
            Hyprland.refreshToplevels();
            build();
            if (windows.length === 0)
                return;
            // Start on the previous window, like every Alt+Tab
            index = windows.length > 1 ? (d > 0 ? 1 : windows.length - 1) : 0;
            openDir = d;
            moved = false;
            open = true;
            settle.restart();
            return;
        }
        if (windows.length > 0)
            index = (index + d + windows.length) % windows.length;
        moved = true;
    }

    function commit() {
        if (!open)
            return;
        const w = windows[index];
        open = false;
        if (w)
            Hyprland.dispatch('hl.dsp.focus({ window = "address:' + w.address + '" })');
    }

    // Window details (titles, focus order) can land a moment after the refresh;
    // rebuild once more and keep the same window selected
    Timer {
        id: settle
        interval: 120
        onTriggered: {
            const keep = root.windows[root.index] ? root.windows[root.index].address : "";
            root.build();
            const n = root.windows.length;
            if (!root.moved)
                // Fresh focus order: start on the previous window again
                root.index = n > 1 ? (root.openDir > 0 ? 1 : n - 1) : 0;
            else {
                const i = root.windows.findIndex(w => w.address === keep);
                root.index = i >= 0 ? i : Math.min(root.index, n - 1);
            }
        }
    }

    function cancel() {
        open = false;
    }

    // Toplevel info arrives asynchronously after a refresh; rebuild while open
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activewindowv2")
                Hyprland.refreshToplevels();
            if (root.open && (event.name === "closewindow" || event.name === "openwindow"))
                root.build();
        }
    }

    IpcHandler {
        target: "switcher"
        function next(): void {
            root.step(1);
        }
        function prev(): void {
            root.step(-1);
        }
        function commit(): void {
            root.commit();
        }
        function cancel(): void {
            root.cancel();
        }
    }
}
