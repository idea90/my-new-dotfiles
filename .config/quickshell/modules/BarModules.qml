pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs
import qs.services

// Registry of bar modules: id -> component, plus whether each should show.
// To add a module: write it in modules/, add a Component and a case below,
// and list its id in Config.barLayout and the settings GUI.
Singleton {
    id: root

    readonly property var ids: ["launcher", "workspaces", "title", "clock", "media", "tray", "status", "wifi", "shortcuts", "resources", "controls", "network", "actions"]

    readonly property var modules: ({
        launcher: launcher,
        workspaces: workspaces,
        clock: clock,
        media: media,
        tray: tray,
        status: status,
        wifi: wifi,
        shortcuts: shortcuts,
        resources: resources,
        controls: controls,
        network: network,
        actions: actions
    })

    // free: width the center zone may use (-1 = don't care)
    function wanted(id, free) {
        switch (id) {
        case "launcher": return Config.showLauncher;
        case "workspaces": return Config.showWorkspaces;
        case "title": return Config.showWindowTitle && Hypr.title !== "";
        case "clock": return Config.showClock;
        case "media": {
            if (!Config.showNowPlaying || !Media.available)
                return false;
            const needs = 260 + (Config.showClock && (Config.barLayout.center ?? []).includes("clock") ? 220 : 0);
            return free < 0 || free > needs;
        }
        case "tray": return Config.showTray && SystemTray.items.values.length > 0;
        case "status": return Config.showStatus;
        case "wifi": return Config.showWifi;
        case "network": return Config.showWifi;
        case "shortcuts": return Config.showShortcuts;
        case "resources": return Config.showResources;
        case "controls": return Config.showControls;
        case "actions": return Config.showActions;
        }
        return false;
    }

    Component { id: launcher; Launcher {} }
    Component { id: workspaces; Workspaces {} }
    Component { id: clock; Clock {} }
    Component { id: media; NowPlaying {} }
    Component { id: tray; Tray {} }
    Component { id: status; StatusRings {} }
    Component { id: wifi; WifiChip {} }
    Component { id: shortcuts; Shortcuts {} }
    Component { id: resources; Resources {} }
    Component { id: controls; Controls {} }
    Component { id: network; NetworkChip {} }
    Component { id: actions; Actions {} }
}
