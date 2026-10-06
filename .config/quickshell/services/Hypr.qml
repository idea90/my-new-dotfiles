pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Workspaces and focused window from Hyprland IPC
Singleton {
    id: root

    readonly property var workspaces: Hyprland.workspaces.values
    readonly property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    // Workspaces 1-5 always shown, plus any other (non-special) one that exists
    readonly property var ids: {
        const set = new Set([1, 2, 3, 4, 5]);
        for (const ws of workspaces)
            if (ws.id > 0)
                set.add(ws.id);
        return [...set].sort((a, b) => a - b);
    }

    // Title of the focused window, only if it's on the focused workspace
    readonly property string title: {
        const top = Hyprland.activeToplevel;
        if (!top || !top.workspace || top.workspace.id !== focusedId)
            return "";
        return top.title;
    }

    function find(id) {
        return workspaces.find(ws => ws.id === id) ?? null;
    }

    function occupied(id) {
        const ws = find(id);
        return !!ws && ws.toplevels.values.length > 0;
    }

    function urgent(id) {
        const ws = find(id);
        return !!ws && ws.urgent;
    }

    function focus(id) {
        Hyprland.dispatch("workspace " + id);
    }

    function cycle(step) {
        Hyprland.dispatch(step > 0 ? "workspace r+1" : "workspace r-1");
    }
}
