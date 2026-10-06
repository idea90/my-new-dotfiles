pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Volume / brightness pop-up (replaces swayosd). Media keys call these via
// `qs ipc call osd volumeUp` and so on.
Singleton {
    id: root

    property string kind: "volume"   // volume | mic | brightness
    property bool shown: false

    function show(what) {
        kind = what;
        shown = true;
        hide.restart();
    }

    Timer {
        id: hide
        interval: 1500
        onTriggered: root.shown = false
    }

    IpcHandler {
        target: "osd"

        function volumeUp(): void {
            Audio.change(0.05);
            root.show("volume");
        }
        function volumeDown(): void {
            Audio.change(-0.05);
            root.show("volume");
        }
        function volumeMute(): void {
            Audio.toggleMute();
            root.show("volume");
        }
        function micMute(): void {
            Audio.toggleMicMute();
            root.show("mic");
        }
        function brightnessUp(): void {
            Brightness.change(1);
            root.show("brightness");
        }
        function brightnessDown(): void {
            Brightness.change(-1);
            root.show("brightness");
        }
    }
}
