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
    readonly property string source: home + "/.cache/lockscreen.png"
    readonly property string file: home + "/.cache/wallpaper-cutout.png"
    property int rev: 0
    property bool busy: false
    property bool failed: false
    readonly property bool wanted: Config.clockDepth

    function refresh() {
        if (!wanted || busy)
            return;
        busy = true;
        failed = false;
        run.command = ["sh", "-c",
            '[ -x "$1" ] && [ "$(stat -c%s "$HOME/.local/share/kaleido/depth/depth_q.onnx" 2>/dev/null || echo 0)" -gt 20000000 ] || "$2/setup-depth.sh" || exit 1; "$1" "$2/depth-cutout" "$3"',
            "sh", py, scripts, source];
        run.running = true;
    }

    Process {
        id: run
        onExited: code => {
            root.busy = false;
            root.failed = code !== 0;
            if (code === 0)
                root.rev += 1;
        }
    }

    onWantedChanged: if (wanted) refresh()
    Connections {
        target: Wallpapers
        function onImageRevChanged() {
            if (root.wanted)
                settle.restart();
        }
    }
    // the lock image is written a moment after the wallpaper changes
    Timer {
        id: settle
        interval: 2500
        onTriggered: root.refresh()
    }
    Component.onCompleted: if (wanted) startup.start()
    Timer {
        id: startup
        interval: 4000
        onTriggered: root.refresh()
    }
}
