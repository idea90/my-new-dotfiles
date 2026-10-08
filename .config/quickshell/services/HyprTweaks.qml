pragma Singleton

import QtQuick
import Quickshell
import qs
import qs.services

// Window shape set from Kaleido (theme packs use it): corner rounding, gaps,
// border width, window opacity. -1 leaves each one as hyprland.lua has it.
// Applied with `hyprctl eval`, so nothing in hyprland.lua is rewritten; going
// back to all -1 reloads Hyprland's own config.
Singleton {
    id: root

    property bool applied: false
    readonly property string key: [Config.hyprRounding, Config.hyprGapsIn, Config.hyprGapsOut, Config.hyprBorder,
        Config.hyprOpacity].join("|")

    function apply() {
        const parts = [];
        const general = [], deco = [];
        if (Config.hyprGapsIn >= 0)
            general.push("gaps_in = " + Config.hyprGapsIn);
        if (Config.hyprGapsOut >= 0)
            general.push("gaps_out = " + Config.hyprGapsOut);
        if (Config.hyprBorder >= 0)
            general.push("border_size = " + Config.hyprBorder);
        if (Config.hyprRounding >= 0)
            deco.push("rounding = " + Config.hyprRounding);
        if (Config.hyprOpacity >= 0)
            deco.push("active_opacity = " + Config.hyprOpacity, "inactive_opacity = " + Math.max(0.5, Config.hyprOpacity - 0.04));
        if (general.length)
            parts.push("general = { " + general.join(", ") + " }");
        if (deco.length)
            parts.push("decoration = { " + deco.join(", ") + " }");
        if (parts.length === 0) {
            if (applied)
                Quickshell.execDetached(["hyprctl", "reload"]);
            applied = false;
            return;
        }
        Quickshell.execDetached(["hyprctl", "eval", "hl.config({ " + parts.join(", ") + " })"]);
        applied = true;
    }

    // Several settings usually change together; apply once they settle
    onKeyChanged: debounce.restart()
    Timer {
        id: debounce
        interval: 350
        onTriggered: root.apply()
    }
    Component.onCompleted: startup.start()
    // Hyprland re-reads its config on reload; put our values back on top afterwards
    Timer {
        id: startup
        interval: 1500
        onTriggered: root.apply()
    }
}
