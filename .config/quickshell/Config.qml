pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// User settings, read from config.json next to this file and watched, so
// edits apply live. Missing keys keep the defaults below; see config.json
// for every option. Nothing here is overwritten by matugen.
Singleton {
    id: root

    // Bar
    property string barPosition: "top"      // "top" | "bottom"
    property int barHeight: 38
    property int barMarginTop: 8            // gap to the screen edge
    property int barMarginSide: 12
    property int islandSpacing: 8
    property real islandOpacity: 0.92
    property int islandBorder: 1
    property int islandRadius: 19           // 0 = square, barHeight/2 = pill
    property string look: "Default"        // last look applied, see looks
    property string barStyle: "Islands"     // last preset applied, see barStyles
    property string barBackground: "islands" // "islands" | "solid" (one bar) | "none"
    property int barRadius: 19              // corner radius of the solid bar
    property string barColor: "surfaceLow"  // Theme color name
    property string borderColor: "outlineVariant"

    // Bar layout: modules per zone, left to right. "|" starts a new island.
    // Modules: launcher workspaces title clock media tray status actions
    property var barLayout: ({
        left: ["launcher", "workspaces", "|", "title"],
        center: ["clock", "|", "media"],
        right: ["tray", "|", "status", "|", "actions"]
    })
    property string wsStyle: "pills"        // "pills" | "dots" | "numbers"

    // Panels (control center, calendar, wifi, theme menu, OSD, power menu, ...)
    property int panelRadius: 14
    property int itemRadius: 12             // cards and tiles inside panels
    property real panelOpacity: 1.0
    property int panelBorder: 1
    property string panelColor: "surfaceLow"
    property string panelBorderColor: "outlineVariant"
    property real animSpeed: 1.0            // 0 = no animations

    // Notification pop-ups
    property string notifPosition: "top-right"  // top-right | top-left | bottom-right | bottom-left
    property int notifWidth: 380
    property int notifMarginTop: 8
    property int notifMarginSide: 12

    // Volume / brightness pop-up
    property string osdPosition: "bottom"   // "bottom" | "top"
    property int osdMargin: 80
    property int osdWidth: 300

    // Power menu buttons
    property int powerButtonWidth: 150
    property int powerButtonHeight: 170

    // Lock screen
    property int lockBlur: 40               // 0..64, wallpaper blur
    property real lockDim: 0.45
    property int lockClockSize: 96
    property int lockFieldWidth: 320
    property string lockAlign: "center"     // "center" | "left"
    property bool lockWallpaper: true       // false = plain color
    property bool lockShowDate: true
    property bool lockShowGreeting: true
    property bool lockShowMedia: true
    property bool lockShowBattery: true

    // Screenshots
    property string shotMode: "area"        // "area" | "window" | "screen"
    property int shotDelay: 0               // seconds
    property string shotAction: "both"      // "copy" | "save" | "both"
    property bool shotPreview: true
    property int shotPreviewSeconds: 6
    property string shotPreviewPosition: "bottom-left"
    property int shotPreviewWidth: 280

    // Bar modules
    property bool showLauncher: true
    property bool showWorkspaces: true
    property bool showWindowTitle: true
    property bool showClock: true
    property bool showNowPlaying: true
    property bool showTray: true
    property bool showStatus: true
    property bool showActions: true

    // Control center
    property string ccSide: "right"         // "right" | "left"
    property int ccWidth: 400
    property int ccTopMargin: 54            // below the bar
    property int ccSideMargin: 12
    property int ccBottomMargin: 12
    property int ccPadding: 14
    property int ccSpacing: 12
    property int ccColumns: 4
    property bool ccSliders: true
    property bool ccMedia: true
    property bool ccNotifications: true
    // Quick toggles to show, in order. Available: wifi, sound, mic, silent,
    // game, awake, capture, theme, settings
    property var ccToggles: ["wifi", "sound", "mic", "silent", "game", "awake", "capture", "theme", "settings"]

    // Launcher
    property int launcherWidth: 560
    property real launcherTop: 0.18         // card position, fraction of screen height
    property real launcherDim: 0.35         // backdrop darkness, 0 = none
    property int launcherRows: 8            // visible results before scrolling
    property int launcherRowHeight: 50
    property int launcherIconSize: 30
    property int launcherSearchHeight: 46
    property int launcherRadius: 14
    property string launcherPlaceholder: "Search apps"
    property bool launcherCounter: true
    property bool launcherDescriptions: true

    // Clock
    property bool clock24h: false
    property bool clockSeconds: false

    // Typography
    property string font: "RobotoMono Nerd Font"
    property int fontSize: 14
    property int iconSize: 16

    // Shape / sizing of widgets inside islands
    property int pillRadius: 10
    property int innerRadius: 8
    property int pillHeight: 28

    // Per-color overrides applied on top of the matugen palette,
    // e.g. { "primary": "#89b4fa" }; keys are Theme color names
    property var colorOverrides: ({})

    // What config.json holds, and the built-in values it replaced
    property var raw: ({})
    property var defaults: ({})

    function apply(json) {
        let cfg;
        try {
            cfg = JSON.parse(json);
        } catch (e) {
            console.warn("Config: bad config.json:", e);
            return;
        }
        raw = cfg;
        for (const key in cfg)
            assign(key, cfg[key]);
    }

    function assign(key, value) {
        if (!(key in root) || typeof root[key] === "function")
            return;
        if (!(key in defaults))
            defaults[key] = root[key];
        root[key] = value;
    }

    // Change a setting from the GUI: applies now, saved to config.json shortly after
    function set(key, value) {
        assign(key, value);
        const next = Object.assign({}, raw);
        next[key] = value;
        raw = next;
        saveTimer.restart();
    }

    // Change several settings at once (used by style presets)
    function setMany(values) {
        const next = Object.assign({}, raw);
        for (const key in values) {
            assign(key, values[key]);
            next[key] = values[key];
        }
        raw = next;
        saveTimer.restart();
    }

    function applyStyle(name) {
        const st = barStyles.find(x => x.name === name);
        if (st)
            setMany(Object.assign({ barStyle: name }, baseStyle, st.values));
    }

    // Looks restyle everything: a bar style plus panel/notification/OSD settings
    function applyLook(name) {
        const look = looks.find(x => x.name === name);
        if (!look)
            return;
        const bar = barStyles.find(x => x.name === look.bar);
        setMany(Object.assign({ look: name, barStyle: look.bar }, baseStyle, panelBase,
                              bar ? bar.values : {}, look.values));
    }

    readonly property var panelBase: ({
        panelRadius: 14, itemRadius: 12, panelOpacity: 1.0, panelBorder: 1,
        panelColor: "surfaceLow", panelBorderColor: "outlineVariant",
        launcherRadius: 14, wsStyle: "pills", animSpeed: 1.0,
        notifPosition: "top-right", notifWidth: 380, osdPosition: "bottom"
    })
    readonly property var looks: [
        { name: "Default", bar: "Islands", values: {} },
        { name: "Sharp", bar: "Squares", values: { panelRadius: 2, itemRadius: 2, launcherRadius: 2, wsStyle: "numbers" } },
        { name: "Soft", bar: "Soft", values: { panelRadius: 26, itemRadius: 18, launcherRadius: 26, panelBorder: 0, panelColor: "surfaceMid" } },
        { name: "Glass", bar: "Glass", values: { panelOpacity: 0.72, panelBorderColor: "outline", launcherRadius: 20 } },
        { name: "Neon", bar: "Neon", values: { panelRadius: 10, itemRadius: 8, panelBorder: 2, panelBorderColor: "primary", launcherRadius: 10 } },
        { name: "Docked", bar: "Docked", values: { panelRadius: 6, itemRadius: 6, launcherRadius: 6, notifMarginTop: 44, wsStyle: "numbers" } },
        { name: "Minimal", bar: "Minimal", values: { panelRadius: 18, itemRadius: 14, panelBorder: 0, wsStyle: "dots", animSpeed: 1.3 } },
        { name: "Terminal", bar: "Terminal", values: { panelRadius: 0, itemRadius: 0, launcherRadius: 0, panelColor: "surfaceMid", wsStyle: "numbers", notifPosition: "bottom-right", osdPosition: "top", animSpeed: 0 } },
        { name: "Warm", bar: "Warm", values: { panelColor: "surfaceMid", panelBorderColor: "tertiary", panelRadius: 20, itemRadius: 14 } }
    ]

    // Style presets: the keys they don't mention fall back to baseStyle
    readonly property var baseStyle: ({
        barPosition: "top", barHeight: 38, barMarginTop: 8, barMarginSide: 12,
        islandSpacing: 8, islandOpacity: 0.92, islandBorder: 1, islandRadius: 19,
        barBackground: "islands", barRadius: 19, barColor: "surfaceLow",
        borderColor: "outlineVariant", fontSize: 14, pillHeight: 28,
        pillRadius: 10, innerRadius: 8
    })
    readonly property var barStyles: [
        { name: "Islands", values: {} },
        { name: "Floating bar", values: { barBackground: "solid", islandSpacing: 6, barRadius: 19 } },
        { name: "Docked", values: { barBackground: "solid", barMarginTop: 0, barMarginSide: 0, barRadius: 0, barHeight: 36, islandBorder: 0, islandRadius: 0, islandSpacing: 6, pillHeight: 28 } },
        { name: "Docked bottom", values: { barPosition: "bottom", barBackground: "solid", barMarginTop: 0, barMarginSide: 0, barRadius: 0, barHeight: 36, islandBorder: 0, islandRadius: 0, islandSpacing: 6 } },
        { name: "Bottom islands", values: { barPosition: "bottom" } },
        { name: "Minimal", values: { barBackground: "none", islandSpacing: 18, islandBorder: 0, barMarginTop: 4 } },
        { name: "Squares", values: { islandRadius: 4, barRadius: 4, pillRadius: 4, innerRadius: 3 } },
        { name: "Chunky", values: { barHeight: 46, islandRadius: 14, islandSpacing: 10, islandBorder: 2, borderColor: "primary", fontSize: 15, pillHeight: 34, barMarginTop: 10 } },
        { name: "Compact", values: { barHeight: 32, pillHeight: 24, fontSize: 12, islandSpacing: 4, barMarginTop: 4, barMarginSide: 6, islandRadius: 16 } },
        { name: "Glass", values: { islandOpacity: 0.5, borderColor: "outline" } },
        { name: "Accent", values: { barColor: "primaryContainer", borderColor: "primary", islandOpacity: 1, islandBorder: 2 } },
        { name: "Neon", values: { islandRadius: 8, islandOpacity: 1, islandBorder: 2, borderColor: "primary", barColor: "surfaceLow" } },
        { name: "Soft", values: { barColor: "surfaceHigh", islandOpacity: 1, islandBorder: 0 } },
        { name: "Warm", values: { barColor: "tertiaryContainer", islandOpacity: 0.95, borderColor: "tertiary" } },
        { name: "Terminal", values: { barBackground: "solid", barMarginTop: 0, barMarginSide: 0, barRadius: 0, barHeight: 28, islandBorder: 0, islandRadius: 0, islandSpacing: 4, fontSize: 12, pillHeight: 22, barColor: "surfaceMid", islandOpacity: 1 } },
        { name: "Wide pill", values: { barBackground: "solid", barMarginTop: 10, barMarginSide: 300, barRadius: 19, barHeight: 40 } }
    ]

    function reset() {
        for (const key in defaults)
            root[key] = defaults[key];
        raw = ({});
        saveTimer.restart();
    }

    Timer {
        id: saveTimer
        interval: 400
        onTriggered: file.setText(JSON.stringify(root.raw, null, 2) + "\n")
    }

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/quickshell/config.json"
        watchChanges: true
        // Our own writes echo back; don't let a stale read undo a drag in progress
        onFileChanged: if (!saveTimer.running) reload()
        onLoaded: root.apply(text())
    }
}
