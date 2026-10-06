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
    property string bandColor: "primaryContainer"  // strip behind the islands ("band" background)
    property real bandOpacity: 0.85
    property bool launcherPlain: false      // launcher button without a filled background
    property bool clockCompact: false       // "6:11 • Tue 6 Oct" (no AM/PM)
    // Icon buttons for the "shortcuts" bar module: { icon: code point, cmd: shell command }
    property var barShortcuts: [
        { icon: 0xf0214, cmd: "thunar" },
        { icon: 0xf015f, cmd: "firefox" },
        { icon: 0xf0361, cmd: "qs ipc call controlcenter toggle" }
    ]
    property string borderColor: "outlineVariant"

    // Bar layout: modules per zone, left to right. "|" starts a new island.
    // Modules: launcher workspaces title clock media tray status wifi actions
    property var barLayout: ({
        left: ["launcher", "|", "workspaces", "|", "tray", "|", "title"],
        center: ["clock", "|", "media"],
        right: ["status", "|", "wifi", "|", "actions"]
    })
    property string wsStyle: "pills"        // "pills" | "dots" | "numbers"

    // Panels (control center, calendar, wifi, theme menu, OSD, power menu, ...)
    property int panelRadius: 14
    property int itemRadius: 12             // cards and tiles inside panels
    property real panelOpacity: 0.55
    property int panelBorder: 1
    property string panelColor: "surfaceLow"
    property string panelBorderColor: "outlineVariant"
    property real animSpeed: 1.0            // 0 = no animations

    property bool shadows: true             // drop shadows under panels

    // Dock
    property bool dockEnabled: true
    property string dockPosition: "bottom"  // "bottom" | "left" | "right"
    property int dockSize: 48
    property bool dockAutoHide: true
    property bool dockMagnify: true
    property int dockMargin: 10
    property var dockApps: ["Alacritty", "firefox", "thunar", "spotify"]   // desktop entry ids or names

    // Notification pop-ups
    property string notifPosition: "top-right"  // top-right | top-left | bottom-right | bottom-left
    property real notifOpacity: 0.55        // pop-up fill; the blur shows through
    property int notifWidth: 380
    property int notifMarginTop: 8
    property int notifMarginSide: 12

    // Volume / brightness pop-up
    property string osdPosition: "bottom"   // "bottom" | "top"
    property int osdMargin: 80
    property int osdWidth: 300

    // Goodbye screen shown before log out / suspend / hibernate / reboot / shut down
    property bool goodbyeEnabled: true
    property real goodbyeSeconds: 1.8        // how long it shows; click or Esc cancels
    property bool goodbyeBlur: false         // reserved
    // One is picked at random per action; {user} becomes your user name
    property var goodbyeMessages: ({
        logout: ["See you soon, {user}", "Logging out. Take care!", "Until next time, {user}"],
        suspend: ["Sleep well, {user}", "Back in a moment…", "Shh, going to sleep"],
        hibernate: ["See you on the other side", "Hibernating. Sweet dreams, {user}"],
        reboot: ["Be right back, {user}", "Restarting… one moment", "A quick refresh and we're back"],
        poweroff: ["Goodbye, {user}. Sleep well!", "Shutting down. See you tomorrow", "Good night, {user}"]
    })

    property bool powerBlur: true            // blur the whole screen behind the power menu and goodbye screen

    // Power menu buttons
    property string powerStyle: "Classic"   // last power menu preset applied
    property string powerLayout: "row"      // "row" | "grid" | "column"
    property string powerShape: "card"      // "card" | "circle" | "pill"
    property bool powerHeader: false        // clock and goodbye line above the buttons
    property bool powerLabels: true
    property bool powerKeys: true           // key hint letters
    property int powerIconSize: 48
    property int powerSpacing: 12
    property real powerOpacity: 0.85
    property int powerButtonWidth: 150
    property int powerButtonHeight: 170

    // Lock screen
    property int lockBlur: 14               // 0..64, wallpaper blur
    property real lockDim: 0.3
    property real lockCardOpacity: 0.8
    property bool lockShowStatus: true      // Wi-Fi / battery pills
    property int lockClockSize: 96
    property int lockFieldWidth: 340
    property string lockStyle: "Card"       // last lock screen preset applied
    property string lockAlign: "center"     // "center" | "left" | "corner"
    property string lockLayout: "stack"     // "stack" (clock above card) | "split" (side by side)
    property string lockClockStyle: "big"   // "big" | "stacked" | "small"
    property bool lockCard: true            // glass card behind the password field
    property string lockClockFont: ""       // empty = the shell font
    property int lockClockWeight: 700       // 100 thin ... 900 black
    property real lockClockSpacing: 0       // letter spacing
    property bool lockClockAccent: false    // clock in the theme accent instead of white
    property bool lockAvatar: true
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
    property bool showWifi: true
    property bool showSettingsButton: true  // gear in the bar (also Super+I)
    property bool showShortcuts: true
    property bool showResources: true
    property bool showControls: true
    property bool showActions: true

    // Control center
    property string ccSide: "right"         // "right" | "left"
    property int ccWidth: 400
    property int ccTopMargin: 54            // below the bar
    property int ccSideMargin: 12
    property int ccBottomMargin: 12
    property int ccPadding: 14
    property int ccSpacing: 12
    property string ccStyle: "Classic"      // last control center preset applied
    property string ccToggleStyle: "mixed"  // "mixed" (wide + pills) | "tiles" | "icons"
    property bool ccHeader: true
    property bool ccFit: false              // panel only as tall as its content
    property int ccColumns: 4
    property bool ccSliders: true
    property bool ccMedia: true
    property bool ccNotifications: true
    // Quick toggles to show, in order. Available: wifi, sound, mic, silent,
    // game, awake, capture, theme, settings
    property var ccToggles: ["wifi", "sound", "mic", "silent", "game", "awake", "capture", "theme"]

    // Launcher
    property int launcherWidth: 560
    property real launcherTop: 0.18         // card position, fraction of screen height
    property real launcherDim: 0.2          // backdrop darkness, 0 = none
    property int launcherRows: 8            // visible results before scrolling
    property int launcherRowHeight: 50
    property int launcherIconSize: 30
    property int launcherSearchHeight: 46
    property int launcherRadius: 14
    property real launcherOpacity: 0.58     // card fill; lower = more see-through blur
    property bool launcherBlurBackdrop: false // blur the whole screen behind the launcher
    property string launcherStyle: "Classic" // last launcher preset applied
    property string launcherLayout: "list"  // "list" | "grid"
    property int launcherColumns: 5         // grid only
    property int launcherCellHeight: 96     // grid only
    property bool launcherFullscreen: false // macOS Launchpad-style full-screen grid
    property int launcherFsColumns: 7
    property int launcherFsRows: 4
    property int launcherFsIcon: 64
    property bool launcherFsNames: true
    property string launcherFsBackground: "blur"   // "blur" (live screen) | "wallpaper"
    property real launcherFsDim: 0.35
    property bool launcherSideImage: true   // wallpaper beside the list
    property string launcherImageSide: "left"
    property int launcherImageWidth: 210
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

    function applyLockStyle(name) {
        const st = lockStyles.find(x => x.name === name);
        if (st)
            setMany(Object.assign({ lockStyle: name }, lockBase, st.values));
    }

    readonly property var lockBase: ({
        lockAlign: "center", lockLayout: "stack", lockClockStyle: "big", lockCard: true, lockAvatar: true,
        lockClockFont: "", lockClockWeight: 700, lockClockSpacing: 0, lockClockAccent: false,
        lockBlur: 14, lockDim: 0.3, lockClockSize: 96, lockFieldWidth: 340, lockCardOpacity: 0.8,
        lockWallpaper: true, lockShowDate: true, lockShowGreeting: true, lockShowMedia: true, lockShowStatus: true
    })
    readonly property var lockStyles: [
        { name: "Card", values: {} },
        { name: "Minimal", values: { lockClockFont: "Outfit", lockClockWeight: 100, lockClockSpacing: -2, lockCard: false, lockAvatar: false, lockShowGreeting: false, lockShowStatus: false,
            lockShowMedia: false, lockFieldWidth: 300, lockClockSize: 110 } },
        { name: "Split", values: { lockClockFont: "Unbounded", lockClockWeight: 800, lockClockSpacing: -2, lockLayout: "split", lockClockStyle: "stacked", lockClockSize: 130 } },
        { name: "Stacked", values: { lockClockFont: "Bebas Neue", lockClockWeight: 400, lockClockSpacing: 2, lockClockAccent: true, lockClockStyle: "stacked", lockClockSize: 140, lockAvatar: false, lockCard: false } },
        { name: "Left", values: { lockClockFont: "Playfair Display", lockClockWeight: 500, lockAlign: "left", lockClockSize: 110 } },
        { name: "Corner", values: { lockClockFont: "Space Grotesk", lockClockWeight: 300, lockAlign: "corner", lockClockStyle: "small", lockAvatar: false, lockFieldWidth: 300 } },
        { name: "Glass", values: { lockClockFont: "Poppins", lockClockWeight: 100, lockClockSpacing: 2, lockCardOpacity: 0.35, lockBlur: 40, lockDim: 0.15 } },
        { name: "Dark", values: { lockClockFont: "Sora", lockClockWeight: 200, lockClockSpacing: 6, lockClockAccent: true, lockDim: 0.7, lockBlur: 60, lockCard: false } },
        { name: "Sharp wallpaper", values: { lockClockFont: "Poppins", lockClockWeight: 900, lockBlur: 0, lockDim: 0.2, lockCardOpacity: 0.85 } },
        { name: "Poster", values: { lockClockFont: "Bebas Neue", lockClockWeight: 400, lockClockSize: 200, lockClockSpacing: 4,
            lockAvatar: false, lockCard: false, lockShowGreeting: false } },
        { name: "Bold", values: { lockClockFont: "Unbounded", lockClockWeight: 900, lockClockSize: 120, lockClockAccent: true,
            lockAlign: "left" } },
        { name: "Plain", values: { lockClockFont: "Playfair Display", lockClockWeight: 400, lockClockAccent: true, lockWallpaper: false, lockCard: false, lockAvatar: true } }
    ]

    function applyPowerStyle(name) {
        const st = powerStyles.find(x => x.name === name);
        if (st)
            setMany(Object.assign({ powerStyle: name }, powerBase, st.values));
    }

    readonly property var powerBase: ({
        powerLayout: "row", powerShape: "card", powerHeader: false, powerLabels: true, powerKeys: true,
        powerIconSize: 48, powerSpacing: 12, powerOpacity: 0.85, powerButtonWidth: 150, powerButtonHeight: 170,
        powerBlur: true
    })
    readonly property var powerStyles: [
        { name: "Classic", values: {} },
        { name: "Glass", values: { powerOpacity: 0.35, powerHeader: true } },
        { name: "Circles", values: { powerShape: "circle", powerButtonWidth: 140, powerSpacing: 22, powerKeys: false } },
        { name: "Circle grid", values: { powerShape: "circle", powerLayout: "grid", powerButtonWidth: 150, powerSpacing: 28, powerHeader: true } },
        { name: "Grid", values: { powerLayout: "grid", powerButtonWidth: 170, powerButtonHeight: 140, powerHeader: true } },
        { name: "List", values: { powerShape: "pill", powerLayout: "column", powerButtonWidth: 180, powerSpacing: 10, powerHeader: true } },
        { name: "Pills", values: { powerShape: "pill", powerLayout: "grid", powerButtonWidth: 140, powerSpacing: 12 } },
        { name: "Icons", values: { powerShape: "circle", powerLabels: false, powerKeys: false, powerButtonWidth: 110, powerSpacing: 18 } },
        { name: "Compact", values: { powerButtonWidth: 110, powerButtonHeight: 120, powerIconSize: 34, powerKeys: false, powerSpacing: 8 } },
        { name: "Big", values: { powerButtonWidth: 190, powerButtonHeight: 220, powerIconSize: 64, powerHeader: true } }
    ]

    function applyCcStyle(name) {
        const st = ccStyles.find(x => x.name === name);
        if (st)
            setMany(Object.assign({ ccStyle: name }, ccBase, st.values));
    }

    readonly property var ccBase: ({
        ccToggleStyle: "mixed", ccHeader: true, ccFit: false, ccSide: "right", ccWidth: 400, ccColumns: 4,
        ccTopMargin: 54, ccSideMargin: 12, ccBottomMargin: 12, ccPadding: 14, ccSpacing: 12,
        ccSliders: true, ccMedia: true, ccNotifications: true
    })
    readonly property var ccStyles: [
        { name: "Classic", values: {} },
        { name: "Tiles", values: { ccToggleStyle: "tiles", ccColumns: 4 } },
        { name: "Icons", values: { ccToggleStyle: "icons", ccWidth: 360, ccFit: true } },
        { name: "Compact", values: { ccToggleStyle: "icons", ccWidth: 330, ccFit: true, ccHeader: false, ccMedia: false,
            ccNotifications: false, ccPadding: 12, ccSpacing: 10 } },
        { name: "Left", values: { ccSide: "left" } },
        { name: "Flush", values: { ccTopMargin: 0, ccSideMargin: 0, ccBottomMargin: 0, ccWidth: 380, ccToggleStyle: "tiles", ccColumns: 3 } },
        { name: "Wide tiles", values: { ccToggleStyle: "tiles", ccColumns: 5, ccWidth: 520 } },
        { name: "Floating", values: { ccFit: true, ccTopMargin: 58, ccToggleStyle: "mixed" } },
        { name: "Minimal", values: { ccToggleStyle: "icons", ccWidth: 300, ccFit: true, ccHeader: false, ccMedia: false,
            ccNotifications: false, ccSliders: true, ccPadding: 14 } },
        { name: "Dashboard", values: { ccToggleStyle: "tiles", ccColumns: 4, ccWidth: 460, ccTopMargin: 54, ccFit: false } }
    ]

    function applyLauncherStyle(name) {
        const st = launcherStyles.find(x => x.name === name);
        if (st)
            setMany(Object.assign({ launcherStyle: name }, launcherBase, st.values));
    }

    // Launcher presets: keys they leave out fall back to launcherBase
    readonly property var launcherBase: ({
        launcherLayout: "list", launcherColumns: 5, launcherCellHeight: 96,
        launcherWidth: 560, launcherTop: 0.18, launcherDim: 0.2, launcherRows: 8,
        launcherRowHeight: 50, launcherIconSize: 30, launcherSearchHeight: 46, launcherRadius: 14,
        launcherCounter: true, launcherDescriptions: true, launcherSideImage: true,
        launcherImageSide: "left", launcherImageWidth: 210, launcherOpacity: 0.58,
        launcherBlurBackdrop: false, launcherFullscreen: false, launcherFsColumns: 7, launcherFsRows: 4,
        launcherFsIcon: 64, launcherFsNames: true, launcherFsBackground: "blur", launcherFsDim: 0.35
    })
    readonly property var launcherStyles: [
        { name: "Classic", values: {} },
        { name: "Spotlight", values: { launcherSideImage: false, launcherWidth: 660, launcherTop: 0.28, launcherRadius: 26,
            launcherSearchHeight: 58, launcherRows: 6, launcherDescriptions: false, launcherCounter: false, launcherOpacity: 0.62 } },
        { name: "Grid", values: { launcherLayout: "grid", launcherSideImage: false, launcherWidth: 720, launcherRadius: 22,
            launcherRows: 4, launcherColumns: 6, launcherIconSize: 36, launcherTop: 0.14 } },
        { name: "Showcase", values: { launcherLayout: "grid", launcherImageSide: "right", launcherImageWidth: 250, launcherWidth: 600,
            launcherColumns: 4, launcherRows: 4, launcherRadius: 22, launcherIconSize: 34 } },
        { name: "Compact", values: { launcherSideImage: false, launcherWidth: 420, launcherRows: 6, launcherRowHeight: 40,
            launcherIconSize: 24, launcherSearchHeight: 40, launcherRadius: 10, launcherDescriptions: false, launcherCounter: false } },
        { name: "Wide image", values: { launcherImageWidth: 320, launcherWidth: 600, launcherRadius: 20, launcherRows: 7 } },
        { name: "Sharp", values: { launcherSideImage: false, launcherRadius: 2, launcherOpacity: 0.95, launcherDim: 0.4, launcherRowHeight: 44 } },
        { name: "Glass", values: { launcherSideImage: false, launcherOpacity: 0.4, launcherRadius: 24, launcherBlurBackdrop: true, launcherDim: 0.3 } },
        // Full-screen, macOS Launchpad style
        { name: "Launchpad", values: { launcherFullscreen: true } },
        { name: "Launchpad XL", values: { launcherFullscreen: true, launcherFsColumns: 5, launcherFsRows: 3, launcherFsIcon: 92 } },
        { name: "Launchpad Dense", values: { launcherFullscreen: true, launcherFsColumns: 9, launcherFsRows: 5, launcherFsIcon: 50 } },
        { name: "Launchpad Wallpaper", values: { launcherFullscreen: true, launcherFsBackground: "wallpaper", launcherFsDim: 0.3 } },
        { name: "Icons only", values: { launcherFullscreen: true, launcherFsNames: false, launcherFsColumns: 8, launcherFsRows: 4, launcherFsIcon: 72 } },
        { name: "Dock row", values: { launcherFullscreen: true, launcherFsColumns: 6, launcherFsRows: 1, launcherFsIcon: 84, launcherFsDim: 0.5 } },
        { name: "Minimal", values: { launcherSideImage: false, launcherWidth: 520, launcherDescriptions: false, launcherCounter: false,
            launcherRows: 5, launcherOpacity: 0.7, launcherDim: 0.5, launcherRadius: 18 } }
    ]

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
        panelRadius: 14, itemRadius: 12, panelOpacity: 0.55, panelBorder: 1,
        panelColor: "surfaceLow", panelBorderColor: "outlineVariant",
        launcherRadius: 14, wsStyle: "pills", animSpeed: 1.0,
        notifPosition: "top-right", notifWidth: 380, osdPosition: "bottom"
    })
    readonly property var looks: [
        { name: "Default", bar: "Islands", values: {} },
        { name: "Sharp", bar: "Docked", values: { panelRadius: 2, itemRadius: 2, launcherRadius: 2, wsStyle: "numbers" } },
        { name: "Soft", bar: "Pill", values: { panelRadius: 26, itemRadius: 18, launcherRadius: 26, panelBorder: 0, panelColor: "surfaceMid" } },
        { name: "Glass", bar: "Glass", values: { panelOpacity: 0.4, panelBorderColor: "outline", launcherRadius: 20 } },
        { name: "Neon", bar: "Outline", values: { panelRadius: 10, itemRadius: 8, panelBorder: 2, panelBorderColor: "primary", launcherRadius: 10 } },
        { name: "Docked", bar: "Docked", values: { panelRadius: 6, itemRadius: 6, launcherRadius: 6, notifMarginTop: 44, wsStyle: "numbers" } },
        { name: "Minimal", bar: "Minimal", values: { panelRadius: 18, itemRadius: 14, panelBorder: 0, wsStyle: "dots", animSpeed: 1.3 } },
        { name: "Terminal", bar: "Terminal", values: { panelRadius: 0, itemRadius: 0, launcherRadius: 0, panelColor: "surfaceMid", wsStyle: "numbers", notifPosition: "bottom-right", osdPosition: "top", animSpeed: 0 } },
        { name: "Warm", bar: "Accent", values: { panelColor: "surfaceMid", panelBorderColor: "tertiary", panelRadius: 20, itemRadius: 14 } }
    ]

    // Style presets: the keys they don't mention fall back to baseStyle
    readonly property var baseStyle: ({
        barPosition: "top", barHeight: 38, barMarginTop: 8, barMarginSide: 12,
        islandSpacing: 8, islandOpacity: 0.92, islandBorder: 1, islandRadius: 19,
        barBackground: "islands", barRadius: 19, barColor: "surfaceLow", bandColor: "primaryContainer", bandOpacity: 0.85,
        launcherPlain: false, clockCompact: false, wsStyle: "pills",
        borderColor: "outlineVariant", fontSize: 14, pillHeight: 28,
        pillRadius: 10, innerRadius: 8
    })
    readonly property var barStyles: [
        { name: "Islands", values: { barLayout: {
            left: ["launcher", "|", "workspaces", "|", "tray", "|", "title"],
            center: ["clock", "|", "media"],
            right: ["status", "|", "wifi", "|", "actions"] } } },
        // Blurred translucent strip behind the whole bar, islands sit on it
        { name: "Frosted", values: { barBackground: "band", barHeight: 44, barMarginTop: 6, barMarginSide: 8,
            barRadius: 12, islandRadius: 8, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 8,
            bandColor: "surfaceLow", bandOpacity: 0.45, wsStyle: "dots" } },
        // Frosted, pinned to the bottom of the screen
        { name: "Frosted bottom", values: { barPosition: "bottom", barBackground: "band", barHeight: 44, barMarginTop: 6,
            barMarginSide: 8, barRadius: 12, islandRadius: 8, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 8,
            bandColor: "surfaceLow", bandOpacity: 0.45, wsStyle: "dots" } },
        // Smaller, tighter frosted bar
        { name: "Compact", values: { barBackground: "band", barHeight: 36, barMarginTop: 4, barMarginSide: 6,
            barRadius: 10, islandRadius: 6, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 6,
            bandColor: "surfaceLow", bandOpacity: 0.45, wsStyle: "dots", fontSize: 12, pillHeight: 24 } },
        // Bigger, roomier frosted bar
        { name: "Chunky", values: { barBackground: "band", barHeight: 54, barMarginTop: 8, barMarginSide: 10,
            barRadius: 16, islandRadius: 12, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 10,
            bandColor: "surfaceLow", bandOpacity: 0.45, wsStyle: "dots", fontSize: 15, pillHeight: 34 } },
        // Dark islands on a strip tinted with the wallpaper's accent
        { name: "Accent", values: { barBackground: "band", barHeight: 44, barMarginTop: 6, barMarginSide: 8,
            barRadius: 12, islandRadius: 8, islandBorder: 0, islandOpacity: 0.92, islandSpacing: 8,
            bandColor: "primaryContainer", bandOpacity: 0.55, wsStyle: "dots" } },
        // Separate see-through islands with a thin light edge
        { name: "Glass", values: { islandRadius: 10, islandOpacity: 0.45, islandBorder: 1, borderColor: "outline",
            islandSpacing: 8, barMarginTop: 8, barMarginSide: 10, wsStyle: "dots" } },
        // Glass islands outlined in the accent color
        { name: "Outline", values: { islandRadius: 10, islandOpacity: 0.35, islandBorder: 1, borderColor: "primary",
            islandSpacing: 8, barMarginTop: 8, barMarginSide: 10, wsStyle: "dots" } },
        // Fully rounded solid pills
        { name: "Pill", values: { islandRadius: 19, islandOpacity: 0.92, islandBorder: 0, islandSpacing: 8, wsStyle: "pills" } },
        // One continuous floating bar
        { name: "Floating bar", values: { barBackground: "solid", barHeight: 40, barMarginTop: 8, barMarginSide: 10,
            barRadius: 14, islandOpacity: 0.72, islandBorder: 1, borderColor: "outlineVariant", islandRadius: 8,
            wsStyle: "dots" } },
        // A faint glass bar, barely there
        { name: "Minimal", values: { barBackground: "solid", barHeight: 34, barMarginTop: 6, barMarginSide: 8,
            barRadius: 10, islandOpacity: 0.32, islandBorder: 0, islandRadius: 8, wsStyle: "dots", fontSize: 13,
            pillHeight: 26 } },
        // Edge to edge along the top
        { name: "Docked", values: { barBackground: "solid", barMarginTop: 0, barMarginSide: 0, barRadius: 0,
            barHeight: 36, islandBorder: 0, islandRadius: 6, islandOpacity: 0.78, islandSpacing: 6, wsStyle: "dots" } },
        // Edge to edge along the bottom
        { name: "Docked bottom", values: { barPosition: "bottom", barBackground: "solid", barMarginTop: 0,
            barMarginSide: 0, barRadius: 0, barHeight: 36, islandBorder: 0, islandRadius: 6, islandOpacity: 0.78,
            islandSpacing: 6, wsStyle: "dots" } },
        // Flat, square and small, with workspace numbers
        { name: "Terminal", values: { barBackground: "solid", barMarginTop: 0, barMarginSide: 0, barRadius: 0,
            barHeight: 28, islandBorder: 0, islandRadius: 0, islandSpacing: 4, fontSize: 12, pillHeight: 22,
            barColor: "surfaceMid", islandOpacity: 0.92, wsStyle: "numbers", pillRadius: 0, innerRadius: 0 } }
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

    // qs ipc call config look Glass | qs ipc call config style Neon
    IpcHandler {
        target: "config"
        function look(name: string): void {
            root.applyLook(name);
        }
        function lock(name: string): void {
            root.applyLockStyle(name);
        }
        function power(name: string): void {
            root.applyPowerStyle(name);
        }
        function cc(name: string): void {
            root.applyCcStyle(name);
        }
        function launcher(name: string): void {
            root.applyLauncherStyle(name);
        }
        function style(name: string): void {
            root.applyStyle(name);
        }
    }
}
