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

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool micReady: !!source && !!source.audio
    readonly property bool micMuted: micReady ? source.audio.muted : false

    // volume/muted are only valid on bound nodes
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    function setVolume(value) {
        if (ready)
            sink.audio.volume = Math.max(0, Math.min(1.5, value));
    }

    function toggleMicMute() {
        if (micReady)
            source.audio.muted = !source.audio.muted;
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
