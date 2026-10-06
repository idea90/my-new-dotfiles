pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default output volume via Pipewire
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: !!sink && !!sink.audio
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false

    // volume/muted are only valid on bound nodes
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function change(step) {
        if (ready)
            sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + step));
    }

    function toggleMute() {
        if (ready)
            sink.audio.muted = !sink.audio.muted;
    }
}
