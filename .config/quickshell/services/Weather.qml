pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Current weather from wttr.in (location from your IP, no key needed).
// Refreshed every 30 minutes; `available` stays false when offline.
Singleton {
    id: root

    property bool available: false
    property int temperature: 0     // °C
    property int feelsLike: 0
    property string condition: ""
    property string place: ""
    property int humidity: 0
    property int code: 0            // WWO weather code

    // Nerd Font icon for a WWO weather code
    readonly property int icon: {
        if (code === 113) return 0xf0599;                                   // sunny
        if (code === 116) return 0xf0595;                                   // partly cloudy
        if (code === 119 || code === 122) return 0xf0590;                   // cloudy
        if ([143, 248, 260].includes(code)) return 0xf0591;                 // fog
        if ([200, 386, 389, 392, 395].includes(code)) return 0xf0593;       // thunder
        if (code >= 179 && code <= 377 && ![263, 266, 281, 284, 293, 296, 299, 302, 305, 308, 311, 314, 353, 356, 359].includes(code))
            return 0xf0598;                                                  // snow / sleet
        return 0xf0597;                                                      // rain
    }

    Process {
        id: fetch
        command: ["curl", "-sf", "--max-time", "15", "https://wttr.in/?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    const now = data.current_condition[0];
                    root.temperature = parseInt(now.temp_C);
                    root.feelsLike = parseInt(now.FeelsLikeC);
                    root.humidity = parseInt(now.humidity);
                    root.condition = now.weatherDesc[0].value.trim();
                    root.code = parseInt(now.weatherCode);
                    root.place = data.nearest_area?.[0]?.areaName?.[0]?.value ?? "";
                    root.available = true;
                } catch (e) {
                    root.available = false;
                }
            }
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetch.running = true
    }
}
