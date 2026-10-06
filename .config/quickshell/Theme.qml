pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Colors come from colors.json, which matugen writes on every wallpaper
// change (template: ~/.config/matugen/template/quickshell-colors.json).
// The file is watched, so the bar recolors live.
Singleton {
    id: root

    // Starter palette, used until colors.json loads
    property color primary: "#ffb4a9"
    property color primaryFg: "#561e18"
    property color primaryContainer: "#73342c"
    property color primaryContainerFg: "#ffdad5"
    property color tertiary: "#dfc38c"
    property color tertiaryContainer: "#574419"
    property color tertiaryContainerFg: "#fcdfa6"
    property color error: "#ffb4ab"
    property color errorFg: "#690005"
    property color errorContainer: "#93000a"
    property color errorContainerFg: "#ffdad6"
    property color surfaceLow: "#231918"
    property color surfaceMid: "#271d1c"
    property color surfaceHigh: "#322826"
    property color surfaceHighest: "#3d3231"
    property color text: "#f1dedc"
    property color textDim: "#d8c2be"
    property color outline: "#a08c89"
    property color outlineVariant: "#534341"

    readonly property string font: "RobotoMono Nerd Font"
    readonly property int fontSize: 14
    readonly property int iconSize: 16
    readonly property int radius: 14       // bar
    readonly property int pillRadius: 10   // groups
    readonly property int innerRadius: 8   // items inside a group
    readonly property int pillHeight: 28

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // Nerd Font glyph from a code point, e.g. Theme.icon(0xf0150)
    function icon(codePoint) {
        return String.fromCodePoint(codePoint);
    }

    function apply(json) {
        let colors;
        try {
            colors = JSON.parse(json);
        } catch (e) {
            console.warn("Theme: bad colors.json:", e);
            return;
        }
        for (const key in colors) {
            if (key in root)
                root[key] = colors[key];
        }
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.apply(text())
    }
}
