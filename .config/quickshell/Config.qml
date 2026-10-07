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
    property string barFont: ""             // font for bar text (clock, title, workspaces); empty = shell font
    property string barClockFormat: "full"  // "full" (time · day date) | "time" | "date"
    property string statusStyle: "rings"    // bar status: rings | bars | sliders | pills | meter | text | labels | icons
    property bool islandShadow: false       // soft drop shadow under bar islands
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

    // "bar" = the normal bar; "island" = one dynamic-island pill at the top center;
    // "none" = no bar at all (Super+B toggles it back)
    property string barMode: "bar"
    property int islandCompactHeight: 34
    property int islandTop: 6
    property string islandColor: "black"    // "black" (like a phone) | "theme"
    property real islandPillOpacity: 1.0
    property string islandStyle: "Phone"    // last island preset applied
    // What the resting island shows
    property bool islandWorkspaces: true
    property bool islandClock: true
    property bool islandBattery: true
    property bool islandDate: false
    // What takes over the island
    property bool islandMedia: true         // song and equalizer while music plays
    property bool islandOsd: true           // volume / brightness (otherwise the normal pop-up)
    property bool islandNotifs: true        // notifications (otherwise the normal pop-ups)
    property bool islandHover: true         // grow into a panel on hover
    property int islandHoverWidth: 720
    property string islandClick: "controlcenter"   // controlcenter | launcher | calendar | none
    property string islandRightClick: "launcher"   // same choices

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

    property string switcherStyle: "cards"  // Alt+Tab look: "cards" | "list" | "icons"

    // Power menu buttons
    property string powerStyle: "Classic"   // last power menu preset applied
    property string powerLayout: "row"      // "row" | "grid" | "column"
    property string powerShape: "card"      // "card" | "circle" | "pill"
    property bool powerHeader: false        // clock and goodbye line above the buttons
    property bool powerAvatar: false        // avatar in the header
    property bool powerClock: true          // clock in the header
    property string powerPosition: "center" // "center" | "bottom" | "left" | "right" | "corner"
    property string powerHighlight: "fill"  // "fill" | "outline"
    property bool powerBorder: true
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
    property string lockFieldStyle: "box"   // "box" | "pill" | "line" (underline) | "dots" (no field, dots appear)
    property bool lockFieldBottom: false    // clock at the top, password at the bottom
    property string lockBackground: "wallpaper" // "wallpaper" | "gradient" | "plain"
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
    property int ccTopMargin: 8             // gap under the bar
    property int ccSideMargin: 12
    property int ccBottomMargin: 12
    property int ccPadding: 14
    property int ccSpacing: 12
    property string ccStyle: "Classic"      // last control center preset applied
    property string ccToggleStyle: "mixed"  // "mixed" (wide + pills) | "tiles" | "icons"
    property bool ccHeader: true
    property string ccHeaderStyle: "profile" // "profile" (avatar, name) | "clock" (big time)
    property string ccSliderStyle: "card"   // "card" | "inline" | "big" (thick filled bars)
    property int ccRadius: -1               // panel corner radius, -1 = panel default
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
    property string launcherFont: ""        // empty = shell font
    property string launcherSearchStyle: "field"   // "field" (box) | "line" (underline) | "big" (large bare text)
    property string launcherHighlight: "fill"      // "fill" | "bar" (accent bar) | "outline"
    property bool launcherHeader: false     // greeting and date above the search
    property string launcherCardColor: ""   // Theme color name; empty = panel color
    property bool launcherBorder: true
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
        lockFieldStyle: "box", lockFieldBottom: false, lockBackground: "wallpaper",
        lockBlur: 14, lockDim: 0.3, lockClockSize: 96, lockFieldWidth: 340, lockCardOpacity: 0.8,
        lockWallpaper: true, lockShowDate: true, lockShowGreeting: true, lockShowMedia: true, lockShowStatus: true
    })
    readonly property var lockStyles: [
        // Clock above a glass card with avatar and password
        { name: "Card", values: {} },
        // Thin clock and an underline to type on, nothing else
        { name: "Minimal", values: { lockCard: false, lockAvatar: false, lockShowGreeting: false, lockShowStatus: false,
            lockShowMedia: false, lockFieldWidth: 300, lockClockSize: 110, lockClockWeight: 100, lockFieldStyle: "line" } },
        // Stacked heavy clock on the left, card on the right
        { name: "Split", values: { lockLayout: "split", lockClockStyle: "stacked", lockClockSize: 130, lockClockWeight: 900 } },
        // Phone style: big stacked clock up top, pill password at the bottom
        { name: "Phone", values: { lockClockStyle: "stacked", lockClockSize: 150, lockClockWeight: 300, lockCard: false,
            lockAvatar: false, lockFieldBottom: true, lockFieldStyle: "pill", lockShowGreeting: false } },
        // Everything on the left, accent clock
        { name: "Left", values: { lockAlign: "left", lockClockSize: 110, lockClockAccent: true, lockFieldStyle: "pill" } },
        // Small clock and password in the bottom-left corner
        { name: "Corner", values: { lockAlign: "corner", lockClockStyle: "small", lockAvatar: false, lockFieldWidth: 300,
            lockCard: false, lockFieldStyle: "line", lockClockWeight: 300 } },
        // See-through card over a heavy blur
        { name: "Glass", values: { lockCardOpacity: 0.3, lockBlur: 48, lockDim: 0.1, lockClockWeight: 200, lockClockSpacing: 4,
            lockFieldStyle: "pill" } },
        // No visible field: just type, dots appear
        { name: "Dots", values: { lockCard: false, lockAvatar: true, lockFieldStyle: "dots", lockDim: 0.5, lockBlur: 30,
            lockClockWeight: 300, lockShowGreeting: false } },
        // Huge clock, password at the bottom, nothing else
        { name: "Poster", values: { lockClockWeight: 900, lockClockSize: 220, lockClockSpacing: -6, lockAvatar: false,
            lockCard: false, lockShowGreeting: false, lockFieldBottom: true, lockFieldStyle: "line", lockShowStatus: false } },
        // Wallpaper colors as a gradient instead of the picture
        { name: "Gradient", values: { lockBackground: "gradient", lockCard: false, lockClockWeight: 200, lockClockSize: 120,
            lockFieldStyle: "pill", lockDim: 0 } },
        // Sharp wallpaper, no blur, dark card at the bottom
        { name: "Photo", values: { lockBlur: 0, lockDim: 0.15, lockCardOpacity: 0.88, lockFieldBottom: true, lockAlign: "left",
            lockClockWeight: 800 } },
        // Solid background, accent clock, plain and calm
        { name: "Plain", values: { lockBackground: "plain", lockCard: false, lockClockAccent: true, lockClockWeight: 400,
            lockFieldStyle: "box" } }
    ]

    function applyIslandStyle(name) {
        const st = islandStyles.find(x => x.name === name);
        if (st)
            setMany(Object.assign({ islandStyle: name, barMode: "island" }, islandBase, st.values));
    }

    readonly property var islandBase: ({
        islandColor: "black", islandPillOpacity: 1.0, islandCompactHeight: 34, islandTop: 6,
        islandWorkspaces: true, islandClock: true, islandBattery: true, islandDate: false,
        islandMedia: true, islandOsd: true, islandNotifs: true, islandHover: true, islandHoverWidth: 720
    })
    readonly property var islandStyles: [
        // Black pill like a phone: workspaces, time, battery
        { name: "Phone", values: {} },
        // Same, in the wallpaper's colors
        { name: "Theme", values: { islandColor: "theme" } },
        // See-through glass pill
        { name: "Glass", values: { islandColor: "theme", islandPillOpacity: 0.55 } },
        // Just the time, nothing else
        { name: "Clock", values: { islandWorkspaces: false, islandBattery: false, islandCompactHeight: 32 } },
        // Taller pill with the date next to the time
        { name: "Big", values: { islandCompactHeight: 42, islandDate: true, islandTop: 8, islandHoverWidth: 780 } },
        // Tiny pill, no hover panel; only reacts to events
        { name: "Tiny", values: { islandCompactHeight: 28, islandBattery: false, islandHover: false, islandTop: 4 } },
        // Only the time; volume and notifications keep their normal pop-ups
        { name: "Quiet", values: { islandWorkspaces: false, islandBattery: false, islandOsd: false, islandNotifs: false } }
    ]

    function applyPowerStyle(name) {
        const st = powerStyles.find(x => x.name === name);
        if (st)
            setMany(Object.assign({ powerStyle: name }, powerBase, st.values));
    }

    readonly property var powerBase: ({
        powerLayout: "row", powerShape: "card", powerHeader: false, powerLabels: true, powerKeys: true,
        powerIconSize: 48, powerSpacing: 12, powerOpacity: 0.85, powerButtonWidth: 150, powerButtonHeight: 170,
        powerBlur: true, powerAvatar: false, powerClock: true, powerPosition: "center", powerHighlight: "fill", powerBorder: true
    })
    readonly property var powerStyles: [
        // Row of cards in the middle
        { name: "Classic", values: {} },
        // See-through cards outlined on hover, clock above
        { name: "Glass", values: { powerOpacity: 0.3, powerHeader: true, powerHighlight: "outline" } },
        // Round buttons along the bottom of the screen, like a dock
        { name: "Dock", values: { powerShape: "circle", powerButtonWidth: 120, powerSpacing: 18, powerKeys: false,
            powerPosition: "bottom", powerHeader: true } },
        // Avatar and clock over a 3x2 grid of circles
        { name: "Profile", values: { powerShape: "circle", powerLayout: "grid", powerButtonWidth: 140, powerSpacing: 26,
            powerHeader: true, powerAvatar: true, powerClock: false, powerHighlight: "outline" } },
        // 3x2 grid of cards under the clock
        { name: "Grid", values: { powerLayout: "grid", powerButtonWidth: 170, powerButtonHeight: 130, powerHeader: true } },
        // Full-height panel on the right with a list
        { name: "Sidebar", values: { powerShape: "pill", powerLayout: "column", powerButtonWidth: 170, powerSpacing: 10,
            powerHeader: true, powerAvatar: true, powerPosition: "right", powerBorder: false } },
        // Small dropdown under the bar, top-right
        { name: "Dropdown", values: { powerShape: "pill", powerLayout: "column", powerButtonWidth: 140, powerSpacing: 6,
            powerPosition: "corner", powerKeys: false, powerBorder: false, powerBlur: false } },
        // Just icons in a row, outlined selection
        { name: "Icons", values: { powerShape: "circle", powerLabels: false, powerKeys: false, powerButtonWidth: 110,
            powerSpacing: 18, powerHighlight: "outline", powerOpacity: 0.5 } },
        // Panel down the left side with circles in a column
        { name: "Left rail", values: { powerShape: "circle", powerLayout: "column", powerButtonWidth: 90, powerSpacing: 8,
            powerLabels: false, powerKeys: false, powerPosition: "left", powerHeader: false } },
        // Huge cards with avatar, clock and goodbye line
        { name: "Big", values: { powerButtonWidth: 190, powerButtonHeight: 220, powerIconSize: 64, powerHeader: true,
            powerAvatar: true } }
    ]

    function applyCcStyle(name) {
        const st = ccStyles.find(x => x.name === name);
        if (st)
            setMany(Object.assign({ ccStyle: name }, ccBase, st.values));
    }

    readonly property var ccBase: ({
        ccToggleStyle: "mixed", ccHeader: true, ccHeaderStyle: "profile", ccSliderStyle: "card", ccRadius: -1, ccFit: false, ccSide: "right", ccWidth: 400, ccColumns: 4,
        ccTopMargin: 8, ccSideMargin: 12, ccBottomMargin: 12, ccPadding: 14, ccSpacing: 12,
        ccSliders: true, ccMedia: true, ccNotifications: true
    })
    readonly property var ccStyles: [
        // Profile header, wide Wi-Fi / Sound tiles, pills, sliders card
        { name: "Classic", values: {} },
        // Square tiles and thick filled sliders, iOS-like
        { name: "Tiles", values: { ccToggleStyle: "tiles", ccColumns: 4, ccSliderStyle: "big", ccWidth: 420 } },
        // Big clock header, round icon buttons, only as tall as needed
        { name: "Clock", values: { ccToggleStyle: "icons", ccHeaderStyle: "clock", ccWidth: 360, ccFit: true,
            ccSliderStyle: "inline", ccNotifications: false } },
        // Just icons and sliders in a small box
        { name: "Compact", values: { ccToggleStyle: "icons", ccWidth: 320, ccFit: true, ccHeader: false, ccMedia: false,
            ccNotifications: false, ccPadding: 12, ccSpacing: 10, ccSliderStyle: "inline" } },
        // Classic on the left side of the screen with the clock header
        { name: "Left", values: { ccSide: "left", ccHeaderStyle: "clock" } },
        // Attached to the right edge, full height, tiles and thick sliders
        { name: "Flush", values: { ccTopMargin: 6, ccSideMargin: 0, ccBottomMargin: 0, ccWidth: 380, ccToggleStyle: "tiles",
            ccColumns: 3, ccSliderStyle: "big" } },
        // Wide centered hub under the bar: clock, five-across tiles, thick sliders
        { name: "Hub", values: { ccSide: "center", ccFit: true, ccWidth: 560, ccToggleStyle: "tiles", ccColumns: 5,
            ccHeaderStyle: "clock", ccSliderStyle: "big", ccNotifications: false, ccTopMargin: 10 } },
        // Very round floating bubble that fits its content
        { name: "Bubble", values: { ccFit: true, ccRadius: 32, ccPadding: 20, ccTopMargin: 12, ccSliderStyle: "big",
            ccNotifications: false } },
        // A slim strip of icons, nothing else
        { name: "Minimal", values: { ccToggleStyle: "icons", ccWidth: 300, ccFit: true, ccHeader: false, ccMedia: false,
            ccNotifications: false, ccSliders: false, ccPadding: 14 } },
        // Notification centre first: clock header, small icons, long notification list
        { name: "Inbox", values: { ccToggleStyle: "icons", ccHeaderStyle: "clock", ccWidth: 420, ccSliderStyle: "inline",
            ccMedia: true } }
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
        launcherBlurBackdrop: false, launcherFont: "", launcherSearchStyle: "field", launcherHighlight: "fill",
        launcherHeader: false, launcherCardColor: "", launcherBorder: true, launcherPlaceholder: "Search apps", launcherFullscreen: false, launcherFsColumns: 7, launcherFsRows: 4,
        launcherFsIcon: 64, launcherFsNames: true, launcherFsBackground: "blur", launcherFsDim: 0.35
    })
    readonly property var launcherStyles: [
        // List with the wallpaper on the side
        { name: "Classic", values: {} },
        // macOS Spotlight: wide, big bare search text, no frills
        { name: "Spotlight", values: { launcherSideImage: false, launcherWidth: 680, launcherTop: 0.26, launcherRadius: 24,
            launcherSearchStyle: "big", launcherRows: 6, launcherRowHeight: 46, launcherDescriptions: false,
            launcherCounter: false, launcherOpacity: 0.62, launcherHighlight: "fill" } },
        // App grid under an underlined search, outlined selection
        { name: "Grid", values: { launcherLayout: "grid", launcherSideImage: false, launcherWidth: 720, launcherRadius: 20,
            launcherRows: 4, launcherColumns: 6, launcherIconSize: 36, launcherTop: 0.14, launcherSearchStyle: "line",
            launcherHighlight: "outline", launcherCounter: false } },
        // Greeting, grid and a big wallpaper on the right
        { name: "Showcase", values: { launcherLayout: "grid", launcherImageSide: "right", launcherImageWidth: 260,
            launcherWidth: 600, launcherColumns: 4, launcherRows: 3, launcherRadius: 22, launcherIconSize: 34,
            launcherHeader: true, launcherCounter: false } },
        // Small and quick, accent bar on the selected row
        { name: "Compact", values: { launcherSideImage: false, launcherWidth: 380, launcherRows: 7, launcherRowHeight: 36,
            launcherIconSize: 22, launcherSearchHeight: 38, launcherRadius: 10, launcherDescriptions: false,
            launcherCounter: false, launcherHighlight: "bar", launcherTop: 0.22 } },
        // Greeting at the top, list with descriptions and a wide wallpaper
        { name: "Welcome", values: { launcherImageWidth: 300, launcherWidth: 580, launcherRadius: 20, launcherRows: 6,
            launcherHeader: true, launcherSearchStyle: "line", launcherHighlight: "bar" } },
        // Square, solid and techy, monospaced names
        { name: "Terminal", values: { launcherSideImage: false, launcherRadius: 0, launcherOpacity: 0.97,
            launcherDim: 0.35, launcherRowHeight: 30, launcherIconSize: 18, launcherSearchHeight: 34, launcherRows: 12,
            launcherDescriptions: false, launcherHighlight: "bar", launcherSearchStyle: "line", launcherWidth: 520, launcherCardColor: "surfaceMid", launcherPlaceholder: "run…" } },
        // Very see-through card over a blurred screen, outlined selection
        { name: "Glass", values: { launcherSideImage: false, launcherOpacity: 0.32, launcherRadius: 26, launcherBlurBackdrop: true,
            launcherDim: 0.25, launcherHighlight: "outline", launcherSearchStyle: "big",
            launcherDescriptions: false, launcherCounter: false, launcherWidth: 600 } },
        // Card tinted with the wallpaper's accent color
        { name: "Accent", values: { launcherSideImage: false, launcherCardColor: "primaryContainer", launcherOpacity: 0.9,
            launcherRadius: 22, launcherHighlight: "outline", launcherBorder: false,
            launcherCounter: false } },
        // Full-screen, macOS Launchpad style
        { name: "Launchpad", values: { launcherFullscreen: true } },
        { name: "Launchpad XL", values: { launcherFullscreen: true, launcherFsColumns: 5, launcherFsRows: 3, launcherFsIcon: 92 } },
        { name: "Launchpad Dense", values: { launcherFullscreen: true, launcherFsColumns: 9, launcherFsRows: 5, launcherFsIcon: 50 } },
        { name: "Launchpad Wallpaper", values: { launcherFullscreen: true, launcherFsBackground: "wallpaper", launcherFsDim: 0.3 } },
        { name: "Icons only", values: { launcherFullscreen: true, launcherFsNames: false, launcherFsColumns: 8, launcherFsRows: 4, launcherFsIcon: 72 } },
        { name: "Dock row", values: { launcherFullscreen: true, launcherFsColumns: 6, launcherFsRows: 1, launcherFsIcon: 84, launcherFsDim: 0.5 } },
        // No card at all: search and names float over a dark screen
        { name: "Minimal", values: { launcherSideImage: false, launcherWidth: 520, launcherDescriptions: false,
            launcherCounter: false, launcherRows: 6, launcherOpacity: 0, launcherBorder: false, launcherDim: 0.6,
            launcherSearchStyle: "big", launcherHighlight: "bar", launcherTop: 0.25 } }
    ]

    // A bar on the left / right edge stays there when you switch styles; the
    // style only decides how the bar looks
    function applyStyle(name) {
        const st = barStyles.find(x => x.name === name);
        if (!st)
            return;
        const side = barPosition === "left" || barPosition === "right";
        const vals = Object.assign({ barStyle: name }, baseStyle, st.values);
        if (side && vals.barPosition !== "left" && vals.barPosition !== "right")
            vals.barPosition = barPosition;
        setMany(vals);
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
        { name: "Soft", bar: "Chunky", values: { panelRadius: 26, itemRadius: 18, launcherRadius: 26, panelBorder: 0, panelColor: "surfaceMid" } },
        { name: "Glass", bar: "Glass", values: { panelOpacity: 0.4, panelBorderColor: "outline", launcherRadius: 20 } },
        { name: "Neon", bar: "Neon", values: { panelRadius: 10, itemRadius: 8, panelBorder: 2, panelBorderColor: "primary", launcherRadius: 10 } },
        { name: "Docked", bar: "Docked", values: { panelRadius: 6, itemRadius: 6, launcherRadius: 6, notifMarginTop: 44, wsStyle: "numbers" } },
        { name: "Minimal", bar: "Minimal", values: { panelRadius: 18, itemRadius: 14, panelBorder: 0, wsStyle: "dots", animSpeed: 1.3 } },
        { name: "Terminal", bar: "Terminal", values: { panelRadius: 0, itemRadius: 0, launcherRadius: 0, panelColor: "surfaceMid", wsStyle: "numbers", notifPosition: "bottom-right", osdPosition: "top", animSpeed: 0 } },
        { name: "Warm", bar: "Accent", values: { panelColor: "surfaceMid", panelBorderColor: "tertiary", panelRadius: 20, itemRadius: 14 } }
    ]

    // Style presets: the keys they don't mention fall back to baseStyle
    // Bar style presets fill in only what makes them different; everything else
    // comes from here, so switching styles never leaves leftovers behind
    readonly property var stdLayout: ({
        left: ["launcher", "|", "workspaces", "|", "tray", "|", "title"],
        center: ["clock", "|", "media"],
        right: ["status", "|", "wifi", "|", "actions"]
    })
    readonly property var baseStyle: ({
        barPosition: "top", barHeight: 38, barMarginTop: 8, barMarginSide: 12,
        islandSpacing: 8, islandOpacity: 0.92, islandBorder: 1, islandRadius: 19,
        barBackground: "islands", barRadius: 19, barColor: "surfaceLow", bandColor: "primaryContainer", bandOpacity: 0.85,
        launcherPlain: false, clockCompact: false, wsStyle: "pills",
        borderColor: "outlineVariant", fontSize: 14, pillHeight: 28,
        pillRadius: 10, innerRadius: 8,
        barFont: "", barClockFormat: "full", islandShadow: false, statusStyle: "rings", barLayout: stdLayout
    })
    readonly property var barStyles: [
        // Blurred translucent strip behind the whole bar, islands sit on it
        { name: "Frosted", values: { barBackground: "band", barHeight: 44, barMarginTop: 6, barMarginSide: 8,
            barRadius: 12, islandRadius: 8, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 8,
            bandColor: "surfaceLow", bandOpacity: 0.45, wsStyle: "dots" } },
        // The original: separate rounded pills, workspaces with app icons
        { name: "Islands", values: {} },
        // Floating see-through islands with a soft shadow and a light edge; airy sans font
        { name: "Glass", values: { statusStyle: "bars", islandRadius: 14, islandOpacity: 0.42, islandBorder: 1, borderColor: "outline",
            islandShadow: true, islandSpacing: 10, barMarginTop: 10, barMarginSide: 14, wsStyle: "lines", fontSize: 14 } },
        // Dark islands outlined in the accent color, techy font, numbered workspaces
        { name: "Neon", values: { statusStyle: "text", islandRadius: 6, islandOpacity: 0.85, islandBorder: 2, borderColor: "primary",
            islandSpacing: 10, barMarginTop: 8, wsStyle: "numbers", launcherPlain: true } },
        // One small rounded capsule in the middle of the screen: just the essentials
        { name: "Capsule", values: { barBackground: "solid", barHeight: 38, barMarginTop: 8, barMarginSide: 330,
            barRadius: 19, islandOpacity: 0.9, islandBorder: 1, borderColor: "outlineVariant", islandRadius: 15,
            wsStyle: "dots", barClockFormat: "time", launcherPlain: true,
            barLayout: { left: ["launcher", "workspaces"], center: ["clock"], right: ["wifi", "actions"] } } },
        // No background at all: text floats over the wallpaper
        { name: "Minimal", values: { statusStyle: "icons", barBackground: "none", barHeight: 34, barMarginTop: 6, islandSpacing: 22,
            wsStyle: "lines", barClockFormat: "time", launcherPlain: true,
            barLayout: { left: ["workspaces", "title"], center: ["clock"], right: ["status", "wifi", "actions"] } } },
        // Strip tinted with the wallpaper's main color
        { name: "Accent", values: { statusStyle: "bars", barBackground: "band", barHeight: 44, barMarginTop: 6, barMarginSide: 8,
            barRadius: 12, islandRadius: 8, islandBorder: 0, islandOpacity: 0.92, islandSpacing: 8,
            bandColor: "primary", bandOpacity: 0.32, wsStyle: "dots", } },
        // Big, soft and friendly: large rounded pills with app icons on workspaces
        { name: "Chunky", values: { barBackground: "band", barHeight: 56, barMarginTop: 8, barMarginSide: 10,
            barRadius: 20, islandRadius: 16, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 10,
            bandColor: "surfaceLow", bandOpacity: 0.4, wsStyle: "pills", fontSize: 15, pillHeight: 34, } },
        // Thin and tight, date only in the center
        { name: "Compact", values: { statusStyle: "icons", barBackground: "band", barHeight: 34, barMarginTop: 4, barMarginSide: 6,
            barRadius: 8, islandRadius: 5, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 6,
            bandColor: "surfaceLow", bandOpacity: 0.5, wsStyle: "lines", fontSize: 12, pillHeight: 24 } },
        // Edge to edge strip with dark islands on it, like a classic desktop panel
        { name: "Docked", values: { statusStyle: "text", barBackground: "band", barMarginTop: 0, barMarginSide: 0, barRadius: 0,
            barHeight: 40, bandColor: "surfaceMid", bandOpacity: 0.95, islandBorder: 0, islandRadius: 6,
            islandOpacity: 0.95, islandSpacing: 6, wsStyle: "numbers", barColor: "surfaceLow", } },
        // Taskbar at the bottom of the screen
        { name: "Taskbar", values: { statusStyle: "icons", barPosition: "bottom", barBackground: "solid", barMarginTop: 0, barMarginSide: 0,
            barRadius: 0, barHeight: 44, islandBorder: 0, islandRadius: 8, islandOpacity: 0.92, islandSpacing: 8,
            wsStyle: "pills",
            barLayout: { left: ["launcher", "|", "workspaces"], center: ["title"], right: ["tray", "|", "status", "|", "wifi", "|", "clock", "|", "actions"] } } },
        // Frosted strip down the left edge of the screen
        { name: "Side left", values: { barPosition: "left", barBackground: "band", barHeight: 48, barMarginTop: 6,
            barMarginSide: 8, barRadius: 14, islandRadius: 10, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 8,
            bandColor: "surfaceLow", bandOpacity: 0.45, wsStyle: "dots", statusStyle: "icons" } },
        // Separate islands down the right edge
        { name: "Side right", values: { barPosition: "right", barHeight: 46, barMarginTop: 8, barMarginSide: 6,
            islandRadius: 14, islandOpacity: 0.9, islandBorder: 1, islandSpacing: 6, wsStyle: "dots", statusStyle: "icons" } },
        // Frosted at the bottom
        { name: "Frosted bottom", values: { barPosition: "bottom", barBackground: "band", barHeight: 44, barMarginTop: 6,
            barMarginSide: 8, barRadius: 12, islandRadius: 8, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 8,
            bandColor: "surfaceLow", bandOpacity: 0.45, wsStyle: "dots" } },
        // Flat, square, monospace and tiny, like a terminal status line
        { name: "Terminal", values: { statusStyle: "text", barBackground: "solid", barMarginTop: 0, barMarginSide: 0, barRadius: 0,
            barHeight: 26, islandBorder: 0, islandRadius: 0, islandSpacing: 2, fontSize: 12, pillHeight: 22,
            barColor: "surfaceMid", islandOpacity: 0.95, wsStyle: "numbers", pillRadius: 0, innerRadius: 0, launcherPlain: true } },
        // Poster: tall condensed clock, everything else small
        { name: "Poster", values: { statusStyle: "bars", barBackground: "band", barHeight: 46, barMarginTop: 6, barMarginSide: 8,
            barRadius: 4, islandRadius: 2, islandBorder: 0, islandOpacity: 0.9, islandSpacing: 6,
            bandColor: "surfaceLow", bandOpacity: 0.5, wsStyle: "lines", fontSize: 16 } }
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
    property string lastBarMode: "bar"
    IpcHandler {
        target: "config"
        // qs ipc call config bar none|bar|island, or "toggle" (hide / bring back)
        function bar(mode: string): void {
            if (mode === "toggle") {
                if (root.barMode === "none") {
                    root.set("barMode", root.lastBarMode === "none" ? "bar" : root.lastBarMode);
                } else {
                    root.lastBarMode = root.barMode;
                    root.set("barMode", "none");
                }
            } else if (["bar", "island", "none"].includes(mode)) {
                root.set("barMode", mode);
            }
        }
        function look(name: string): void {
            root.applyLook(name);
        }
        function lock(name: string): void {
            root.applyLockStyle(name);
        }
        function island(name: string): void {
            root.applyIslandStyle(name);
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
