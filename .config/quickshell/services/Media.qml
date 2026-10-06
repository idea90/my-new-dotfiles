pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Now playing via MPRIS: the playing player, else the first one
Singleton {
    id: root

    readonly property var player: {
        // playerctld is a proxy that is always present, even with nothing playing
        const players = Mpris.players.values.filter(p => !p.dbusName.includes("playerctld"));
        return players.find(p => p.isPlaying) ?? players[0] ?? null;
    }
    readonly property bool available: !!player && player.trackTitle !== ""
    readonly property string title: player ? player.trackTitle : ""
    readonly property string artist: player ? player.trackArtist : ""
    readonly property string app: player ? player.identity.toLowerCase() : ""
    readonly property bool playing: !!player && player.isPlaying
    readonly property string art: player ? player.trackArtUrl : ""
    // 0..1, refreshed every second while playing (position isn't reactive)
    readonly property real progress: player && player.lengthSupported && player.length > 0
        ? Math.min(1, player.position / player.length) : 0

    Timer {
        interval: 1000
        repeat: true
        running: !!root.player && root.player.isPlaying && root.player.positionSupported
        onTriggered: root.player.positionChanged()
    }

    function toggle() {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player && player.canGoNext)
            player.next();
    }

    function previous() {
        if (player && player.canGoPrevious)
            player.previous();
    }
}
