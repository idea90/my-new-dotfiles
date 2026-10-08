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

    readonly property string font: Config.font
    readonly property int fontSize: Config.fontSize
    readonly property int iconSize: Config.iconSize
    readonly property int radius: Config.panelRadius
    readonly property int pillRadius: Config.pillRadius
    readonly property int innerRadius: Config.innerRadius
    readonly property int pillHeight: Config.pillHeight
    // Corner radius for buttons inside bar islands: follows the island corners
    // Height of buttons, rings and the clock inside bar islands: follows the bar
    // height so small and big bar styles stay in proportion (30 on the default bars)
    readonly property int islandHeight: Config.barBackground === "band" ? Config.barHeight - 12 : Config.barHeight
    readonly property int barItem: Math.max(20, Math.min(40, Config.barBackground === "band" ? islandHeight - 2 : islandHeight - 8))
    readonly property real barScale: barItem / 30
    // Screen space the bar (or the dynamic island) takes at the top / bottom
    readonly property bool islandMode: Config.barMode === "island"
    readonly property bool noBar: Config.barMode === "none"
    // Bar on the left or right edge: everything in it stacks top to bottom
    readonly property bool vertical: Config.barMode === "bar" && (Config.barPosition === "left" || Config.barPosition === "right")
    readonly property int barSpaceLeft: vertical && Config.barPosition === "left" ? Config.barMarginTop + Config.barHeight : 0
    readonly property int barSpaceRight: vertical && Config.barPosition === "right" ? Config.barMarginTop + Config.barHeight : 0
    readonly property int barSpaceTop: noBar || vertical ? 0 : islandMode ? Config.islandTop + Config.islandCompactHeight
        : Config.barPosition !== "bottom" ? Config.barMarginTop + Config.barHeight : 0
    readonly property int barSpaceBottom: noBar || islandMode || vertical || Config.barPosition !== "bottom" ? 0 : Config.barMarginTop + Config.barHeight
    // Bar at the bottom: flyouts (control center, calendar, mixer ...) open just above it
    readonly property bool isLight: (text.r * 0.299 + text.g * 0.587 + text.b * 0.114) < 0.5
    readonly property bool panelsBottom: Config.barMode === "bar" && Config.barPosition === "bottom"
    function panelY(h, parentH) {
        return panelsBottom ? parentH - h - barSpaceBottom - 10 : barSpaceTop + 8;
    }
    readonly property string barFont: Config.barFont !== "" ? Config.barFont : font
    readonly property int chipRadius: Math.max(4, Math.min(15, Config.islandRadius - 2))

    // Animation duration scaled by Config.animSpeed (0 = instant)
    function dur(ms) {
        return Config.lowEnd || Config.animSpeed <= 0 ? 0 : Math.round(ms / Config.animSpeed);
    }

    // Palette color by name (Theme[name] doesn't work from other files)
    function byName(name, fallback) {
        return root[name] ?? fallback;
    }

    // Panel surface color / border color by Theme color name
    readonly property color panelFill: alpha(root[Config.panelColor] ?? surfaceLow, Config.panelOpacity)
    readonly property color panelBorderFill: root[Config.panelBorderColor] ?? outlineVariant

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
        applyOverrides();
    }

    // User overrides from config.json win over the generated palette
    function applyOverrides() {
        const o = Config.colorOverrides;
        for (const key in o) {
            if (key in root)
                root[key] = o[key];
        }
    }

    Connections {
        target: Config
        function onColorOverridesChanged() {
            if (file.loaded)
                root.apply(file.text());
        }
    }

    FileView {
        id: file
        property bool loaded: false
        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            loaded = true;
            root.apply(text());
        }
    }
}
