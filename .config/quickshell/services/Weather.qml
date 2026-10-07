pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

// Current weather from wttr.in (no account). Refreshes every 30 minutes while
// Config.weatherEnabled is on; Config.weatherLocation empty = guess from IP.
Singleton {
    id: root

    property bool ready: false
    property int temp: 0
    property int feels: 0
    property string desc: ""
    property string place: ""
    property int code: 113
    property var forecast: []      // [{ day, max, min, code }]

    readonly property string unit: Config.weatherUnit === "f" ? "°F" : "°C"
    readonly property string glyph: icon(code, Time.now.getHours() >= 6 && Time.now.getHours() < 19)
    readonly property string line: ready ? glyph + " " + temp + unit : ""

    // wttr.in / WWO condition codes -> Nerd Font weather icons
    function icon(c, day) {
        if (c === 113)
            return String.fromCodePoint(day ? 0xf0599 : 0xf0594);
        if (c === 116)
            return String.fromCodePoint(day ? 0xf0595 : 0xf0f31);
        if (c === 119 || c === 122)
            return String.fromCodePoint(0xf0590);
        if ([143, 248, 260].includes(c))
            return String.fromCodePoint(0xf0591);
        if ([200, 386, 389, 392, 395].includes(c))
            return String.fromCodePoint(0xf0593);
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(c))
            return String.fromCodePoint(0xf0598);
        return String.fromCodePoint(0xf0597);   // rain
    }

    function refresh() {
        if (Config.weatherEnabled)
            proc.running = true;
    }

    Process {
        id: proc
        command: ["curl", "-s", "-m", "12", "https://wttr.in/" + encodeURIComponent(Config.weatherLocation) + "?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    const c = d.current_condition[0];
                    const f = Config.weatherUnit === "f";
                    root.temp = parseInt(f ? c.temp_F : c.temp_C);
                    root.feels = parseInt(f ? c.FeelsLikeF : c.FeelsLikeC);
                    root.desc = c.weatherDesc[0].value;
                    root.code = parseInt(c.weatherCode);
                    root.place = d.nearest_area[0].areaName[0].value;
                    root.forecast = d.weather.slice(0, 3).map(w => ({
                        day: Qt.formatDate(new Date(w.date), "ddd"),
                        max: parseInt(f ? w.maxtempF : w.maxtempC),
                        min: parseInt(f ? w.mintempF : w.mintempC),
                        code: parseInt(w.hourly[4].weatherCode)
                    }));
                    root.ready = true;
                } catch (e) {
                    console.warn("Weather: no data", e);
                }
            }
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        running: Config.weatherEnabled
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
    Connections {
        target: Config
        function onWeatherLocationChanged() {
            root.refresh();
        }
        function onWeatherUnitChanged() {
            root.refresh();
        }
    }
}
