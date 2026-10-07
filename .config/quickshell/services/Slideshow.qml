pragma Singleton

import QtQuick
import Quickshell
import qs
import qs.services

// Changes the wallpaper (and so the colors) every few minutes, or by time of day
//   minutes: a random wallpaper every Config.slideMinutes
//   daytime: Config.slideMorning / slideDay / slideEvening / slideNight, by the hour
Singleton {
    id: root

    property string lastPart: ""
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/apply-wal"

    function partOfDay(d) {
        const h = d.getHours();
        return h >= 6 && h < 11 ? "morning" : h >= 11 && h < 17 ? "day" : h >= 17 && h < 21 ? "evening" : "night";
    }

    function next() {
        Quickshell.execDetached([script, "--random"]);
    }

    Timer {
        interval: Math.max(1, Config.slideMinutes) * 60 * 1000
        running: Config.slideshow && Config.slideMode === "minutes"
        repeat: true
        onTriggered: root.next()
    }

    // Time of day: check each minute, change when the part of the day changes
    Timer {
        interval: 60 * 1000
        running: Config.slideshow && Config.slideMode === "daytime"
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const part = root.partOfDay(new Date());
            if (part === root.lastPart)
                return;
            root.lastPart = part;
            const file = { morning: Config.slideMorning, day: Config.slideDay, evening: Config.slideEvening, night: Config.slideNight }[part];
            if (file !== "")
                Quickshell.execDetached([root.script, "--apply", file.startsWith("/") ? file : Quickshell.env("HOME") + "/wallpapers/" + file]);
            else
                root.next();
        }
    }
}
