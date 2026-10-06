pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Now playing via MPRIS: the playing player, else the first one
Singleton {
    readonly property var player: {
        const players = Mpris.players.values;
        return players.find(p => p.isPlaying) ?? players[0] ?? null;
    }
    readonly property bool available: !!player && player.trackTitle !== ""
    readonly property string title: player ? player.trackTitle : ""
    readonly property string artist: player ? player.trackArtist : ""
    readonly property string app: player ? player.identity.toLowerCase() : ""
    readonly property bool playing: !!player && player.isPlaying

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
