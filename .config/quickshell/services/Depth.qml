pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

// "Clock behind the subject": a cut-out of the wallpaper's main subject, made by
// hypr/scripts/depth-cutout, that the lock screen and desktop clock draw on top of the clock.
// Turns itself on when Config.clockDepth is set; the first time it also runs setup-depth.sh.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string py: home + "/.local/share/kaleido/depth/venv/bin/python"
    readonly property string scripts: home + "/.config/hypr/scripts"
    // the wallpaper in use, and its own cut-out (made once per wallpaper)
    property string current: ""
    readonly property string stem: current.split("/").pop().replace(/\.[^.]*$/, "")
    readonly property string file: home + "/.cache/wallpaper-cutouts/" + stem + ".png"
    property int rev: 0
    property bool busy: false
    property bool failed: false
    property string started: ""
    readonly property bool wanted: Config.clockDepth

    function refresh() {
        if (!wanted || busy || current === "")
            return;
        busy = true;
        failed = false;
        started = current;
        run.command = ["sh", "-c",
            '[ -x "$1" ] && [ "$(stat -c%s "$HOME/.local/share/kaleido/depth/depth_q.onnx" 2>/dev/null || echo 0)" -gt 20000000 ] || "$2/setup-depth.sh" || exit 1; "$1" "$2/depth-cutout" "$3"',
            "sh", py, scripts, current];
        run.running = true;
    }

    Process {
        id: run
        onExited: code => {
            root.busy = false;
            root.failed = code !== 0;
            if (code === 0)
                root.rev += 1;
            if (root.started !== root.current)
                root.refresh();   // the wallpaper changed while this one ran
        }
    }

    onWantedChanged: if (wanted) refresh()
    FileView {
        path: root.home + "/.cache/current_wallpaper"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.current = text().trim();
            settle.restart();
        }
    }
    Timer {
        id: settle
        interval: 1500
        onTriggered: root.refresh()
    }
}
