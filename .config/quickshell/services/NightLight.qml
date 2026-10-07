pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

// Warm screen at night via hyprsunset (started at login). On by toggle, or on a
// schedule (Config.nightAuto between nightFrom and nightTo).
Singleton {
    id: root

    property bool manual: false     // toggled by hand
    readonly property bool scheduled: Config.nightAuto && inWindow(Time.now)
    readonly property bool active: manual || scheduled

    function inWindow(d) {
        const toMin = s => {
            const p = String(s).split(":");
            return parseInt(p[0]) * 60 + parseInt(p[1] || 0);
        };
        const now = d.getHours() * 60 + d.getMinutes();
        const a = toMin(Config.nightFrom), b = toMin(Config.nightTo);
        return a <= b ? now >= a && now < b : now >= a || now < b;
    }

    function toggle() {
        manual = !manual;
    }

    function apply() {
        Quickshell.execDetached(["sh", "-c",
            "pgrep -x hyprsunset >/dev/null || (hyprsunset -i >/dev/null 2>&1 &) ; sleep 0.3; "
            + (active ? "hyprctl hyprsunset temperature " + Config.nightTemp : "hyprctl hyprsunset identity")]);
    }

    onActiveChanged: apply()
    Connections {
        target: Config
        function onNightTempChanged() {
            if (root.active)
                root.apply();
        }
    }
    Component.onCompleted: if (active) apply()

    IpcHandler {
        target: "nightlight"
        function toggle(): void {
            root.toggle();
        }
    }
}
