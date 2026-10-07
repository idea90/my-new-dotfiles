import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules
import qs.services

// GUI for config.json: every change applies live and is saved automatically.
// The sections below are data; to expose a new Config property, add a row.
Card {
    id: panel

    implicitWidth: Math.min(960, parent ? parent.width - 60 : 960)
    implicitHeight: Math.min(parent ? parent.height - 70 : 660, 680)

    property int tab: 0
    property string query: ""

    Connections {
        target: Panels
        function onSettingsTabChanged() {
            const i = panel.sections.findIndex(sec => sec.name.toLowerCase() === Panels.settingsTab.toLowerCase());
            if (i >= 0) {
                panel.tab = i;
                searchField.text = "";
            }
        }
    }

    // Rows shown on the right: the open section, or matches from every section when searching
    readonly property var shownRows: {
        const q = query.trim().toLowerCase();
        if (q === "")
            return sections[tab].rows;
        const out = [];
        for (const sec of sections)
            for (const r of sec.rows)
                if (r.key && r.label && (r.label.toLowerCase().includes(q) || sec.name.toLowerCase().includes(q)))
                    out.push(Object.assign({ section: sec.name }, r));
        return out;
    }

    // type: bool | int | real | choice | string
    // Sections in the sidebar, grouped. Each row: a heading, a special editor, or
    // a setting (type: bool | int | real | choice | string).
    readonly property var sections: [
        { group: "Appearance", name: "Looks", icon: 0xf03d8, rows: [
            { type: "looks" },
            { type: "header", label: "Text" },
            { key: "font", label: "Font family", type: "string" },
            { key: "fontSize", label: "Font size", type: "int", min: 9, max: 24, step: 1 },
            { key: "iconSize", label: "Icon size", type: "int", min: 10, max: 30, step: 1 },
            { type: "header", label: "Shapes" },
            { key: "pillHeight", label: "Item height", type: "int", min: 20, max: 40, step: 1 },
            { key: "pillRadius", label: "Group radius", type: "int", min: 0, max: 24, step: 1 },
            { key: "innerRadius", label: "Item radius", type: "int", min: 0, max: 20, step: 1 },
            { type: "header", label: "Colors" },
            { type: "colors" }
        ]},
        { group: "Appearance", name: "Panels", icon: 0xf0493, rows: [
            { type: "header", label: "Look" },
            { key: "panelColor", label: "Color", type: "choice", options: ["surfaceLow", "surfaceMid", "surfaceHigh", "primaryContainer", "tertiaryContainer"] },
            { key: "panelOpacity", label: "Opacity", type: "real", min: 0.3, max: 1, step: 0.05 },
            { key: "panelRadius", label: "Corner radius", type: "int", min: 0, max: 36, step: 1 },
            { key: "itemRadius", label: "Inner corner radius", type: "int", min: 0, max: 28, step: 1 },
            { key: "panelBorder", label: "Border", type: "int", min: 0, max: 4, step: 1 },
            { key: "panelBorderColor", label: "Border color", type: "choice", options: ["outlineVariant", "outline", "primary", "tertiary"] },
            { key: "shadows", label: "Shadows under panels", type: "bool" },
            { type: "header", label: "Motion" },
            { key: "animSpeed", label: "Animation speed (0 = off)", type: "real", min: 0, max: 3, step: 0.25 }
        ]},
        { group: "Bar", name: "Bar", icon: 0xf0e2c, rows: [
            { type: "header", label: "Mode" },
            { key: "barMode", label: "Show a bar, the dynamic island, or nothing", type: "choice", options: ["bar", "island", "none"] },
            { type: "header", label: "Style" },
            { type: "styles" },
            { type: "header", label: "Position and size" },
            { key: "barPosition", label: "Position", type: "choice", options: ["top", "bottom", "left", "right"] },
            { key: "barHeight", label: "Height", type: "int", min: 24, max: 64, step: 1 },
            { key: "barMarginTop", label: "Gap to the screen edge", type: "int", min: 0, max: 40, step: 1 },
            { key: "barMarginSide", label: "Gap at the ends", type: "int", min: 0, max: 60, step: 1 },
            { type: "header", label: "Background" },
            { key: "barBackground", label: "Background", type: "choice", options: ["islands", "band", "solid", "none"] },
            { key: "barColor", label: "Color", type: "choice", options: ["surfaceLow", "surfaceMid", "surfaceHigh", "primaryContainer", "tertiaryContainer"] },
            { key: "bandColor", label: "Strip color (band)", type: "choice", options: ["surfaceLow", "primaryContainer", "tertiaryContainer", "surfaceMid", "surfaceHigh", "primary"] },
            { key: "bandOpacity", label: "Strip opacity", type: "real", min: 0.2, max: 1, step: 0.05 },
            { key: "barRadius", label: "Solid bar radius", type: "int", min: 0, max: 32, step: 1 },
            { key: "borderColor", label: "Border color", type: "choice", options: ["outlineVariant", "outline", "primary", "tertiary"] },
            { type: "header", label: "Islands" },
            { key: "islandOpacity", label: "Opacity", type: "real", min: 0, max: 1, step: 0.05 },
            { key: "islandRadius", label: "Corner radius", type: "int", min: 0, max: 32, step: 1 },
            { key: "islandBorder", label: "Border", type: "int", min: 0, max: 4, step: 1 },
            { key: "islandSpacing", label: "Spacing", type: "int", min: 0, max: 30, step: 1 },
            { key: "islandShadow", label: "Shadow", type: "bool" },
            { type: "header", label: "Text" },
            { key: "barFont", label: "Bar font", type: "choice", options: ["", "Outfit", "Poppins", "Space Grotesk", "Sora", "Bebas Neue", "Roboto"] }
        ]},
        { group: "Bar", name: "Bar contents", icon: 0xf0570, rows: [
            { type: "layout" },
            { type: "header", label: "Show in the bar" },
            { key: "showLauncher", label: "Launcher button", type: "bool" },
            { key: "showWorkspaces", label: "Workspaces", type: "bool" },
            { key: "showWindowTitle", label: "Window title", type: "bool" },
            { key: "showClock", label: "Clock", type: "bool" },
            { key: "showNowPlaying", label: "Now playing", type: "bool" },
            { key: "showTray", label: "Tray", type: "bool" },
            { key: "showStatus", label: "Status (cpu, wifi, ...)", type: "bool" },
            { key: "showWifi", label: "Wi-Fi", type: "bool" },
            { key: "showWeather", label: "Weather in the bar", type: "bool" },
            { key: "showShortcuts", label: "Shortcut icons", type: "bool" },
            { key: "showResources", label: "CPU / MEM bars", type: "bool" },
            { key: "showControls", label: "Volume / brightness sliders", type: "bool" },
            { key: "showActions", label: "Actions (bell, power)", type: "bool" },
            { key: "showSettingsButton", label: "Settings gear in the bar", type: "bool" },
            { type: "header", label: "Workspaces" },
            { key: "wsStyle", label: "Workspace style", type: "choice", options: ["pills", "dots", "lines", "numbers"] },
            { type: "header", label: "Status (cpu, volume, ...)" },
            { key: "statusStyle", label: "Status (cpu, volume...)", type: "choice", options: ["rings", "bars", "sliders", "pills", "meter", "text", "labels", "icons"] },
            { type: "header", label: "Clock" },
            { key: "barClockFormat", label: "Clock shows", type: "choice", options: ["full", "time", "date"] },
            { key: "clock24h", label: "24-hour clock", type: "bool" },
            { key: "clockSeconds", label: "Clock seconds", type: "bool" },
            { key: "clockCompact", label: "Compact clock", type: "bool" },
            { type: "header", label: "Launcher button" },
            { key: "launcherPlain", label: "Plain launcher button", type: "bool" }
        ]},
        { group: "Bar", name: "Dynamic island", icon: 0xf0e2c, rows: [
            { type: "islandStyles" },
            { key: "barMode", label: "Show a bar, the dynamic island, or nothing", type: "choice", options: ["bar", "island", "none"] },
            { type: "header", label: "Look" },
            { key: "islandColor", label: "Color", type: "choice", options: ["black", "theme"] },
            { key: "islandPillOpacity", label: "Opacity", type: "real", min: 0.3, max: 1, step: 0.05 },
            { key: "islandCompactHeight", label: "Height", type: "int", min: 26, max: 46, step: 1 },
            { key: "islandTop", label: "Gap from the top", type: "int", min: 0, max: 20, step: 1 },
            { type: "header", label: "When idle it shows" },
            { key: "islandWorkspaces", label: "Workspace dots", type: "bool" },
            { key: "islandClock", label: "Time", type: "bool" },
            { key: "islandDate", label: "Date", type: "bool" },
            { key: "islandBattery", label: "Battery", type: "bool" },
            { type: "header", label: "It takes over" },
            { key: "islandMedia", label: "Music (song and equalizer)", type: "bool" },
            { key: "islandOsd", label: "Volume and brightness pop-up", type: "bool" },
            { key: "islandNotifs", label: "Notification pop-ups", type: "bool" },
            { key: "islandHover", label: "Grow into a panel on hover", type: "bool" },
            { key: "islandHoverWidth", label: "Hover panel width", type: "int", min: 560, max: 800, step: 10 },
            { type: "header", label: "Clicks" },
            { key: "islandClick", label: "Click opens", type: "choice", options: ["controlcenter", "launcher", "calendar", "none"] },
            { key: "islandRightClick", label: "Right-click opens", type: "choice", options: ["launcher", "controlcenter", "calendar", "none"] }
        ]},
        { group: "Panels", name: "Launcher", icon: 0xf0349, rows: [
            { type: "launcherStyles" },
            { type: "header", label: "Layout" },
            { key: "launcherLayout", label: "Layout", type: "choice", options: ["list", "grid"] },
            { key: "launcherColumns", label: "Grid columns", type: "int", min: 3, max: 8, step: 1 },
            { key: "launcherCellHeight", label: "Grid cell height", type: "int", min: 70, max: 150, step: 4 },
            { type: "header", label: "Card" },
            { key: "launcherWidth", label: "Width", type: "int", min: 360, max: 900, step: 10 },
            { key: "launcherTop", label: "Vertical position", type: "real", min: 0, max: 0.6, step: 0.02 },
            { key: "launcherRows", label: "Visible rows", type: "int", min: 3, max: 14, step: 1 },
            { key: "launcherRowHeight", label: "Row height", type: "int", min: 32, max: 80, step: 1 },
            { key: "launcherIconSize", label: "Icon size", type: "int", min: 16, max: 56, step: 1 },
            { key: "launcherRadius", label: "Corner radius", type: "int", min: 0, max: 36, step: 1 },
            { key: "launcherOpacity", label: "Card opacity", type: "real", min: 0.3, max: 1, step: 0.05 },
            { key: "launcherDim", label: "Backdrop dim", type: "real", min: 0, max: 1, step: 0.05 },
            { key: "launcherBlurBackdrop", label: "Blur screen behind", type: "bool" },
            { type: "header", label: "Wallpaper on the side" },
            { key: "launcherSideImage", label: "Show the wallpaper", type: "bool" },
            { key: "launcherImageMode", label: "How", type: "choice", options: ["side", "bleed", "banner", "background", "avatar"] },
            { key: "launcherBannerHeight", label: "Banner height", type: "int", min: 60, max: 220, step: 10 },
            { key: "launcherImageBlur", label: "Background blur", type: "real", min: 0, max: 1, step: 0.1 },
            { key: "launcherImageDim", label: "Background darkness", type: "real", min: 0, max: 0.9, step: 0.05 },
            { key: "launcherImageSide", label: "Image side", type: "choice", options: ["left", "right"] },
            { key: "launcherImageWidth", label: "Image width", type: "int", min: 120, max: 400, step: 10 },
            { type: "header", label: "Search" },
            { key: "launcherSearchHeight", label: "Search height", type: "int", min: 32, max: 70, step: 1 },
            { key: "launcherPlaceholder", label: "Placeholder", type: "string" },
            { key: "launcherCounter", label: "Result counter", type: "bool" },
            { key: "launcherDescriptions", label: "Descriptions", type: "bool" },
            { type: "header", label: "Full-screen (Launchpad)" },
            { key: "launcherFullscreen", label: "Full-screen (Launchpad)", type: "bool" },
            { key: "launcherFsColumns", label: "Full-screen columns", type: "int", min: 3, max: 12, step: 1 },
            { key: "launcherFsRows", label: "Full-screen rows", type: "int", min: 1, max: 7, step: 1 },
            { key: "launcherFsIcon", label: "Full-screen icon size", type: "int", min: 32, max: 128, step: 4 },
            { key: "launcherFsNames", label: "Full-screen app names", type: "bool" },
            { key: "launcherFsBackground", label: "Full-screen background", type: "choice", options: ["blur", "wallpaper"] },
            { key: "launcherFsDim", label: "Full-screen dim", type: "real", min: 0, max: 0.9, step: 0.05 }
        ]},
        { group: "Panels", name: "Control center", icon: 0xf009a, rows: [
            { type: "ccStyles" },
            { type: "header", label: "Layout" },
            { key: "ccToggleStyle", label: "Toggle style", type: "choice", options: ["mixed", "tiles", "icons"] },
            { key: "ccHeader", label: "Header", type: "bool" },
            { key: "ccHeaderStyle", label: "Header style", type: "choice", options: ["profile", "clock"] },
            { key: "ccSliderStyle", label: "Sliders", type: "choice", options: ["card", "inline", "big"] },
            { key: "ccFit", label: "Fit height to content", type: "bool" },
            { type: "header", label: "Sections" },
            { key: "ccSliders", label: "Sliders", type: "bool" },
            { key: "ccMedia", label: "Now playing", type: "bool" },
            { key: "ccNotifications", label: "Notifications", type: "bool" },
            { type: "header", label: "Quick toggles" },
            { type: "toggles" },
            { key: "ccColumns", label: "Tile columns (tiles style)", type: "int", min: 2, max: 6, step: 1 },
            { type: "header", label: "Placement" },
            { key: "ccSide", label: "Side", type: "choice", options: ["right", "left", "center"] },
            { key: "ccWidth", label: "Width", type: "int", min: 300, max: 700, step: 10 },
            { key: "ccTopMargin", label: "Gap under the bar", type: "int", min: 0, max: 80, step: 1 },
            { key: "ccSideMargin", label: "Gap at the ends", type: "int", min: 0, max: 60, step: 1 },
            { key: "ccBottomMargin", label: "Bottom gap", type: "int", min: 0, max: 60, step: 1 },
            { key: "ccPadding", label: "Padding", type: "int", min: 4, max: 30, step: 1 },
            { key: "ccSpacing", label: "Spacing", type: "int", min: 0, max: 30, step: 1 }
        ]},
        { group: "Panels", name: "Notifications", icon: 0xf009c, rows: [
            { type: "header", label: "Pop-ups" },
            { key: "notifPosition", label: "Corner", type: "choice", options: ["top-right", "top-left", "bottom-right", "bottom-left"] },
            { key: "notifWidth", label: "Width", type: "int", min: 260, max: 600, step: 10 },
            { key: "notifOpacity", label: "Opacity", type: "real", min: 0.3, max: 1, step: 0.05 },
            { key: "notifMarginTop", label: "Gap to the edge", type: "int", min: 0, max: 120, step: 2 },
            { key: "notifMarginSide", label: "Gap to the side", type: "int", min: 0, max: 80, step: 2 },
            { type: "header", label: "List" },
            { key: "notifGroup", label: "Group by app in the control center", type: "bool" },
            { type: "header", label: "Silent mode" },
            { key: "dndAuto", label: "Turn on by itself", type: "bool" },
            { key: "dndFrom", label: "From", type: "string" },
            { key: "dndTo", label: "Until", type: "string" },
            { type: "header", label: "Volume / brightness pop-up" },
            { key: "osdPosition", label: "Where", type: "choice", options: ["bottom", "top"] },
            { key: "osdMargin", label: "Gap to the edge", type: "int", min: 0, max: 300, step: 5 },
            { key: "osdWidth", label: "Width", type: "int", min: 200, max: 500, step: 10 }
        ]},
        { group: "Panels", name: "Lock screen", icon: 0xf033e, rows: [
            { type: "actions" },
            { type: "lockStyles" },
            { type: "header", label: "Layout" },
            { key: "lockLayout", label: "Layout", type: "choice", options: ["stack", "split"] },
            { key: "lockAlign", label: "Position", type: "choice", options: ["center", "left", "corner"] },
            { key: "lockFieldStyle", label: "Password field", type: "choice", options: ["box", "pill", "line", "dots"] },
            { key: "lockFieldBottom", label: "Password at the bottom", type: "bool" },
            { key: "lockCard", label: "Card behind password", type: "bool" },
            { key: "lockAvatar", label: "Avatar and name", type: "bool" },
            { key: "lockFieldWidth", label: "Password field width", type: "int", min: 200, max: 600, step: 20 },
            { key: "lockCardOpacity", label: "Card opacity", type: "real", min: 0.2, max: 1, step: 0.05 },
            { type: "header", label: "Clock" },
            { key: "lockClockStyle", label: "Style", type: "choice", options: ["big", "stacked", "small", "pixel"] },
            { key: "lockClockSize", label: "Size", type: "int", min: 40, max: 200, step: 8 },
            { key: "lockClockWeight", label: "Weight", type: "int", min: 100, max: 900, step: 100 },
            { key: "lockClockSpacing", label: "Letter spacing", type: "int", min: -8, max: 12, step: 1 },
            { key: "lockClockAccent", label: "Accent color", type: "bool" },
            { key: "lockClockFont", label: "Font", type: "choice", options: ["", "Outfit", "Poppins", "Bebas Neue", "Unbounded", "Space Grotesk", "Sora", "Playfair Display", "Roboto", "Roboto Condensed", "Noto Serif Display"] },
            { type: "header", label: "Background" },
            { key: "lockBackground", label: "Background", type: "choice", options: ["wallpaper", "gradient", "plain"] },
            { key: "lockWallpaper", label: "Use the wallpaper", type: "bool" },
            { key: "lockBlur", label: "Blur", type: "int", min: 0, max: 64, step: 4 },
            { key: "lockDim", label: "Darken", type: "real", min: 0, max: 1, step: 0.05 },
            { type: "header", label: "Show" },
            { key: "lockShowDate", label: "Show date", type: "bool" },
            { key: "lockShowGreeting", label: "Show greeting", type: "bool" },
            { key: "lockShowMedia", label: "Show now playing", type: "bool" },
            { key: "lockShowBattery", label: "Show battery", type: "bool" }
        ]},
        { group: "Panels", name: "Power menu", icon: 0xf0425, rows: [
            { type: "powerStyles" },
            { type: "header", label: "Layout" },
            { key: "powerLayout", label: "Arrangement", type: "choice", options: ["row", "grid", "column"] },
            { key: "powerShape", label: "Button shape", type: "choice", options: ["card", "circle", "pill"] },
            { key: "powerPosition", label: "Position", type: "choice", options: ["center", "bottom", "left", "right", "corner"] },
            { key: "powerHighlight", label: "Selection", type: "choice", options: ["fill", "outline"] },
            { key: "powerSpacing", label: "Spacing", type: "int", min: 0, max: 40, step: 2 },
            { key: "powerButtonWidth", label: "Button width", type: "int", min: 90, max: 260, step: 5 },
            { key: "powerButtonHeight", label: "Button height", type: "int", min: 90, max: 300, step: 5 },
            { key: "powerIconSize", label: "Icon size", type: "int", min: 24, max: 80, step: 2 },
            { type: "header", label: "Show" },
            { key: "powerHeader", label: "Header (goodbye line)", type: "bool" },
            { key: "powerAvatar", label: "Avatar in header", type: "bool" },
            { key: "powerClock", label: "Clock in header", type: "bool" },
            { key: "powerLabels", label: "Button labels", type: "bool" },
            { key: "powerKeys", label: "Key hints", type: "bool" },
            { key: "powerBorder", label: "Button borders", type: "bool" },
            { key: "powerOpacity", label: "Button opacity", type: "real", min: 0.2, max: 1, step: 0.05 },
            { key: "powerBlur", label: "Blur behind power menu", type: "bool" },
            { type: "header", label: "Goodbye screen" },
            { key: "goodbyeEnabled", label: "Show a goodbye message", type: "bool" },
            { key: "goodbyeSeconds", label: "How long (seconds)", type: "real", min: 0.5, max: 6, step: 0.25 }
        ]},
        { group: "Desktop", name: "Wallpaper and widgets", icon: 0xf0e09, rows: [
            { type: "header", label: "Get wallpapers from Wallhaven" },
            { type: "wallhaven" },
            { type: "header", label: "Desktop widgets" },
            { key: "widgetsEnabled", label: "Widgets on the wallpaper", type: "bool" },
            { key: "widgetsStyle", label: "Look", type: "choice", options: ["cards", "plain"] },
            { key: "widgetsPosition", label: "Where", type: "choice", options: ["top-left", "top-right", "bottom-left", "bottom-right", "center"] },
            { key: "widgetClock", label: "Clock", type: "bool" },
            { key: "widgetWeather", label: "Weather", type: "bool" },
            { key: "widgetMusic", label: "Music", type: "bool" },
            { key: "widgetSystem", label: "CPU / memory / battery", type: "bool" },
            { type: "header", label: "Wallpaper slideshow" },
            { key: "slideshow", label: "Change the wallpaper by itself", type: "bool" },
            { type: "slideshow" },
            { key: "slideSource", label: "From", type: "choice", options: ["local", "wallhaven"] },
            { key: "slideTopics", label: "Wallhaven topics (comma separated)", type: "string" },
            { key: "slideMode", label: "How often", type: "choice", options: ["hours", "minutes", "daytime"] },
            { key: "slideHours", label: "Every (hours)", type: "int", min: 1, max: 168, step: 1 },
            { key: "slideMinutes", label: "Every (minutes)", type: "int", min: 1, max: 240, step: 1 },
            { key: "slideMorning", label: "Morning wallpaper (6-11, empty = random)", type: "string" },
            { key: "slideDay", label: "Day wallpaper (11-17)", type: "string" },
            { key: "slideEvening", label: "Evening wallpaper (17-21)", type: "string" },
            { key: "slideNight", label: "Night wallpaper (21-6)", type: "string" }
        ]},
        { group: "Desktop", name: "Dock", icon: 0xf0d5b, rows: [
            { key: "dockEnabled", label: "Show the dock", type: "bool" },
            { key: "dockPosition", label: "Where", type: "choice", options: ["bottom", "left", "right"] },
            { key: "dockSize", label: "Icon size", type: "int", min: 32, max: 72, step: 2 },
            { key: "dockAutoHide", label: "Hide until you point at the edge", type: "bool" },
            { key: "dockMagnify", label: "Grow icons on hover", type: "bool" }
        ]},
        { group: "Desktop", name: "Tools", icon: 0xf1064, rows: [
            { type: "header", label: "Screenshots" },
            { key: "shotMode", label: "Default mode", type: "choice", options: ["area", "window", "screen"] },
            { key: "shotDelay", label: "Delay (seconds)", type: "int", min: 0, max: 30, step: 1 },
            { key: "shotAction", label: "After capture", type: "choice", options: ["copy", "save", "both"] },
            { key: "shotPreview", label: "Show preview", type: "bool" },
            { key: "shotPreviewSeconds", label: "Preview stays (seconds, 0 = until closed)", type: "int", min: 0, max: 30, step: 1 },
            { key: "shotPreviewPosition", label: "Preview corner", type: "choice", options: ["bottom-left", "bottom-right", "top-left", "top-right"] },
            { key: "shotPreviewWidth", label: "Preview width", type: "int", min: 180, max: 480, step: 10 },
            { type: "header", label: "Window switcher (Alt+Tab)" },
            { key: "switcherStyle", label: "Look", type: "choice", options: ["cards", "list", "icons"] },
            { type: "header", label: "Night light" },
            { key: "nightTemp", label: "Warmth (K, lower = warmer)", type: "int", min: 2500, max: 6000, step: 100 },
            { key: "nightAuto", label: "Turn on by itself at night", type: "bool" },
            { key: "nightFrom", label: "From", type: "string" },
            { key: "nightTo", label: "Until", type: "string" },
            { type: "header", label: "Weather" },
            { key: "weatherEnabled", label: "Get weather (wttr.in)", type: "bool" },
            { key: "weatherLocation", label: "City (empty = automatic)", type: "string" },
            { key: "weatherUnit", label: "Unit", type: "choice", options: ["c", "f"] }
        ]},
        { group: "System", name: "Backup", icon: 0xf0293, rows: [
            { type: "backup" }
        ]}
    ]

    readonly property var allToggles: ["wifi", "sound", "bluetooth", "night", "power", "mic", "silent", "game", "awake", "capture", "theme", "settings"]
    readonly property var colorKeys: ["primary", "primaryContainer", "tertiary", "tertiaryContainer", "error", "surfaceLow", "surfaceHigh", "text", "textDim", "outline"]

    RowLayout {
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 12

        // ---- sidebar ----------------------------------------------------
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 210
            radius: Math.max(6, Config.panelRadius - 4)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 12
                }
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 4
                    spacing: 10
                    BarText {
                        text: Theme.icon(0xf0493)
                        color: Theme.primary
                        font.pixelSize: 22
                    }
                    BarText {
                        text: "Kaleido"
                        font.bold: true
                        font.pixelSize: 19
                    }
                }

                // Search
                Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    radius: height / 2
                    color: Theme.surfaceHigh
                    border.width: 1
                    border.color: searchField.activeFocus ? Theme.primary : "transparent"

                    BarText {
                        id: searchIcon
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        text: Theme.icon(0xf0349)
                        color: Theme.textDim
                        font.pixelSize: 14
                    }
                    TextField {
                        id: searchField
                        anchors {
                            left: searchIcon.right
                            right: parent.right
                            leftMargin: 6
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        background: null
                        color: Theme.text
                        placeholderText: "Search settings"
                        placeholderTextColor: Theme.alpha(Theme.text, 0.4)
                        font.family: Theme.font
                        font.pixelSize: 13
                        selectionColor: Theme.primary
                        selectedTextColor: Theme.primaryFg
                        onTextChanged: panel.query = text
                    }
                }

                // Sections, under group headings; scrolls if the window is short
                ListView {
                    id: nav
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: panel.sections
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Column {
                        id: navEntry
                        required property var modelData
                        required property int index
                        readonly property bool firstOfGroup: index === 0 || panel.sections[index - 1].group !== modelData.group
                        width: nav.width

                        BarText {
                            visible: navEntry.firstOfGroup
                            leftPadding: 10
                            topPadding: navEntry.index === 0 ? 2 : 12
                            bottomPadding: 4
                            text: navEntry.modelData.group.toUpperCase()
                            color: Theme.alpha(Theme.textDim, 0.8)
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1.2
                        }

                        Rectangle {
                            id: navItem
                            readonly property var modelData: navEntry.modelData
                            readonly property int index: navEntry.index
                            readonly property bool active: panel.query === "" && panel.tab === index

                            width: parent.width
                            height: 34
                            radius: Math.max(6, Config.itemRadius)
                            color: active ? Theme.primaryContainer : navMouse.containsMouse ? Theme.alpha(Theme.text, 0.07) : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: Theme.dur(120) }
                            }

                            Rectangle {
                                visible: navItem.active
                                width: 3
                                height: 16
                                radius: 2
                                color: Theme.primary
                                anchors {
                                    left: parent.left
                                    leftMargin: 6
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                            Row {
                                anchors {
                                    left: parent.left
                                    leftMargin: 18
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: 12
                                BarText {
                                    width: 20
                                    text: Theme.icon(navItem.modelData.icon)
                                    font.pixelSize: 15
                                    color: navItem.active ? Theme.primaryContainerFg : Theme.textDim
                                }
                                BarText {
                                    text: navItem.modelData.name
                                    font.bold: navItem.active
                                    color: navItem.active ? Theme.primaryContainerFg : Theme.text
                                }
                            }
                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    searchField.text = "";
                                    panel.tab = navItem.index;
                                }
                            }
                        }
                    }
                }


                Chip {
                    Layout.fillWidth: true
                    icon: Theme.icon(0xf0450)
                    label: "Reset everything"
                    bg: Theme.surfaceHigh
                    hoverBg: Theme.error
                    hoverFg: Theme.errorFg
                    onLeftClicked: Config.reset()
                }
                BarText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "Saved automatically"
                    color: Theme.alpha(Theme.textDim, 0.8)
                    font.pixelSize: 11
                }
            }
        }

        // ---- content ----------------------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 6
                spacing: 12
                BarText {
                    text: panel.query === "" ? Theme.icon(panel.sections[panel.tab].icon) : Theme.icon(0xf0349)
                    color: Theme.primary
                    font.pixelSize: 24
                }
                BarText {
                    Layout.fillWidth: true
                    text: panel.query === "" ? panel.sections[panel.tab].name : "Results for \"" + panel.query + "\""
                    font.bold: true
                    font.pixelSize: 22
                }
                BarText {
                    visible: panel.query !== ""
                    text: panel.shownRows.length + " found"
                    color: Theme.textDim
                    font.pixelSize: 13
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: panel.shownRows
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {}

                delegate: Loader {
                    required property var modelData
                    required property int index
                    width: list.width - 12
                    PopIn {
                        order: index
                        trigger: panel.tab >= 0 && panel.shownRows !== null
                        fromScale: 0.98
                        rise: 12
                        stepMs: 18
                    }
                    sourceComponent: modelData.type === "header" ? headerRow
                    : modelData.type === "wallhaven" ? wallhavenEditor
                    : modelData.type === "slideshow" ? slideshowStatus
                    : modelData.type === "backup" ? backupEditor
                    : modelData.type === "islandStyles" ? islandStylesEditor
                    : modelData.type === "ccStyles" ? ccStylesEditor
                    : modelData.type === "powerStyles" ? powerStylesEditor
                    : modelData.type === "lockStyles" ? lockStylesEditor
                        : modelData.type === "launcherStyles" ? launcherStylesEditor
                        : modelData.type === "actions" ? actionsEditor
                        : modelData.type === "looks" ? looksEditor
                        : modelData.type === "layout" ? layoutEditor
                        : modelData.type === "styles" ? stylesEditor
                        : modelData.type === "toggles" ? togglesEditor
                        : modelData.type === "colors" ? colorsEditor : rowEditor
                    onLoaded: if (item && "row" in item) item.row = modelData
                }

                BarText {
                    anchors.centerIn: parent
                    visible: panel.shownRows.length === 0
                    text: "No settings match"
                    color: Theme.textDim
                }
            }
        }
    }

    // Browse wallhaven.cc: search, filters, click a picture to download and use it
    Component {
        id: wallhavenEditor

        Rectangle {
            id: wh
            implicitHeight: whCol.implicitHeight + 24
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Component.onCompleted: {
                if (Wallpapers.onlineItems.length === 0 && !Wallpapers.searching)
                    Wallpapers.search("", 1);
            }

            Column {
                id: whCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                // Search
                Rectangle {
                    width: parent.width
                    height: 36
                    radius: Theme.innerRadius + 2
                    color: Theme.surfaceHigh
                    border.width: whSearch.activeFocus ? 1 : 0
                    border.color: Theme.primary

                    BarText {
                        id: whIcon
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        text: Theme.icon(0xf0349)
                        color: Theme.primary
                    }
                    TextInput {
                        id: whSearch
                        anchors {
                            left: whIcon.right
                            right: whStatus.left
                            leftMargin: 10
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        text: Wallpapers.query
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 14
                        clip: true
                        onAccepted: Wallpapers.search(text, 1)
                        Text {
                            visible: whSearch.text === "" && !whSearch.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Search wallhaven, then Enter (empty = top picks)"
                            color: Theme.alpha(Theme.text, 0.45)
                            font: whSearch.font
                        }
                    }
                    BarText {
                        id: whStatus
                        anchors {
                            right: parent.right
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        text: Wallpapers.downloading ? "downloading…" : Wallpapers.searching ? "searching…"
                            : Wallpapers.error ? "wallhaven unreachable" : Wallpapers.onlineItems.length + " results"
                        color: Wallpapers.error ? Theme.error : Theme.textDim
                        font.pixelSize: 11
                    }
                }

                // Filters: click a chip to step through its options, right-click to go back
                Flow {
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: [{ label: "General", i: 0 }, { label: "Anime", i: 1 }, { label: "People", i: 2 }]
                        Chip {
                            required property var modelData
                            readonly property bool on: Wallpapers.categories[modelData.i] === "1"
                            implicitHeight: 26
                            label: modelData.label
                            fg: on ? Theme.primaryFg : Theme.textDim
                            bg: on ? Theme.primary : Theme.surfaceHigh
                            hoverBg: on ? Theme.primary : Theme.surfaceHighest
                            onLeftClicked: Wallpapers.toggleCategory(modelData.i)
                        }
                    }
                    Repeater {
                        model: [
                            { prop: "sort", list: Wallpapers.sorts, name: "sort" },
                            { prop: "range", list: Wallpapers.ranges, name: "top" },
                            { prop: "resolution", list: Wallpapers.resolutions, name: "min" },
                            { prop: "ratio", list: Wallpapers.ratioList, name: "ratio" },
                            { prop: "color", list: Wallpapers.colorList, name: "color" }
                        ]
                        Chip {
                            required property var modelData
                            readonly property string value: Wallpapers[modelData.prop]
                            visible: modelData.prop !== "range" || Wallpapers.sort === "toplist"
                            implicitHeight: 26
                            label: modelData.name + ": " + (value === "any" ? "any" : modelData.prop === "color" ? "     " : value.replace("_", " "))
                            bg: Theme.surfaceHigh
                            function step(d) {
                                const l = modelData.list;
                                Wallpapers.set(modelData.prop, l[(l.indexOf(value) + d + l.length) % l.length]);
                            }
                            onLeftClicked: step(1)
                            onRightClicked: step(-1)
                            Rectangle {
                                visible: modelData.prop === "color" && value !== "any"
                                anchors {
                                    right: parent.right
                                    rightMargin: 8
                                    verticalCenter: parent.verticalCenter
                                }
                                width: 14
                                height: 14
                                radius: 7
                                color: "#" + value
                                border.width: 1
                                border.color: Theme.outline
                            }
                        }
                    }
                    Chip {
                        implicitHeight: 26
                        label: "NSFW"
                        fg: Wallpapers.nsfw ? Theme.errorFg : Theme.textDim
                        bg: Wallpapers.nsfw ? Theme.error : Theme.surfaceHigh
                        hoverBg: Wallpapers.nsfw ? Theme.error : Theme.surfaceHighest
                        onLeftClicked: Wallpapers.set("nsfw", !Wallpapers.nsfw)
                    }
                }

                // Results
                Grid {
                    id: whGrid
                    width: parent.width
                    columns: 3
                    spacing: 8
                    readonly property real cell: (width - 16) / 3

                    Repeater {
                        model: Wallpapers.onlineItems
                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: whGrid.cell
                            height: whGrid.cell * 0.62 + 18

                            Rectangle {
                                id: shotFrame
                                width: parent.width
                                height: whGrid.cell * 0.62
                                radius: Theme.innerRadius + 2
                                clip: true
                                color: Theme.surfaceHigh
                                border.width: whMouse.containsMouse ? 2 : 0
                                border.color: Theme.primary

                                Image {
                                    anchors.fill: parent
                                    source: modelData.thumb
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize.width: 360
                                }
                                Rectangle {
                                    visible: whMouse.containsMouse
                                    anchors.fill: parent
                                    color: Qt.rgba(0, 0, 0, 0.45)
                                    BarText {
                                        anchors.centerIn: parent
                                        text: Theme.icon(0xf01da) + "  Use this"
                                        color: "#ffffff"
                                        font.bold: true
                                    }
                                }
                            }
                            BarText {
                                anchors.top: shotFrame.bottom
                                anchors.topMargin: 2
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData.name.split("  ")[1] || ""
                                color: Theme.textDim
                                font.pixelSize: 10
                            }
                            MouseArea {
                                id: whMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Wallpapers.download(modelData.path)
                            }
                        }
                    }
                }

                Row {
                    spacing: 8
                    Chip {
                        visible: Wallpapers.onlineItems.length > 0
                        icon: Theme.icon(0xf0140)
                        label: Wallpapers.searching ? "Loading…" : "Load more"
                        bg: Theme.surfaceHigh
                        onLeftClicked: if (!Wallpapers.searching) Wallpapers.search(Wallpapers.query, Wallpapers.page + 1)
                    }
                    Chip {
                        icon: Theme.icon(0xf049d)
                        label: "Surprise me"
                        bg: Theme.surfaceHigh
                        onLeftClicked: Quickshell.execDetached([Wallpapers.havenScript, "random", Wallpapers.query])
                    }
                    BarText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Downloads go to ~/wallpapers"
                        color: Theme.alpha(Theme.textDim, 0.8)
                        font.pixelSize: 11
                    }
                }
            }
        }
    }

    // Slideshow status: next change, last topic, change-now button
    Component {
        id: slideshowStatus

        Rectangle {
            implicitHeight: 50
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                anchors {
                    left: parent.left
                    leftMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                BarText {
                    text: !Config.slideshow ? "Off"
                        : Config.slideMode === "daytime" ? "Changes with the time of day"
                        : Slideshow.nextChange > 0 ? "Next change " + Qt.formatDateTime(new Date(Slideshow.nextChange), "ddd h:mm AP")
                        : "Starts counting now"
                }
                BarText {
                    visible: Slideshow.lastTopic !== "" && Config.slideSource === "wallhaven"
                    text: "Last topic: " + Slideshow.lastTopic
                    color: Theme.textDim
                    font.pixelSize: 11
                }
            }
            Chip {
                anchors {
                    right: parent.right
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                icon: Theme.icon(0xf049d)
                label: Slideshow.busy ? "Downloading…" : "Change now"
                bg: Theme.surfaceHigh
                onLeftClicked: Slideshow.next()
            }
        }
    }

    // Export / import the whole setup
    Component {
        id: backupEditor

        Rectangle {
            implicitHeight: bcol.implicitHeight + 24
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)
            Component.onCompleted: Config.listBackups()

            Column {
                id: bcol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                BarText {
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: "Save every Kaleido setting (styles, layout, panels...) to one file in ~/Kaleido-backups, or bring one back. Handy before experimenting, or to copy your setup to another computer."
                    color: Theme.textDim
                    font.pixelSize: 12
                }
                Row {
                    spacing: 8
                    Chip {
                        icon: Theme.icon(0xf0193)
                        label: "Save a backup now"
                        bg: Theme.primary
                        fg: Theme.primaryFg
                        hoverBg: Theme.alpha(Theme.primary, 0.85)
                        onLeftClicked: Config.exportBackup()
                    }
                    Chip {
                        icon: Theme.icon(0xf0770)
                        label: "Open folder"
                        bg: Theme.surfaceHigh
                        onLeftClicked: Quickshell.execDetached(["xdg-open", Config.backupDir])
                    }
                }
                BarText {
                    visible: Config.backupNote !== ""
                    text: Config.backupNote
                    color: Theme.primary
                    font.pixelSize: 12
                }
                BarText {
                    text: Config.backups.length ? "RESTORE ONE" : "No backups yet"
                    color: Config.backups.length ? Theme.primary : Theme.textDim
                    font.pixelSize: 11
                    font.bold: true
                }
                Repeater {
                    model: Config.backups
                    delegate: Rectangle {
                        required property string modelData
                        width: bcol.width
                        height: 36
                        radius: Theme.innerRadius
                        color: bm.containsMouse ? Theme.surfaceHigh : "transparent"
                        BarText {
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            text: modelData.replace("kaleido-", "").replace(".json", "").replace("_", "  ")
                        }
                        BarText {
                            anchors {
                                right: parent.right
                                rightMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            text: "Restore"
                            color: Theme.primary
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: bm
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Config.importBackup(modelData)
                        }
                    }
                }
                Chip {
                    icon: Theme.icon(0xf02d7)
                    label: "Show the welcome tour again"
                    bg: Theme.surfaceHigh
                    onLeftClicked: {
                        Panels.close();
                        Quickshell.execDetached(["qs", "ipc", "call", "welcome", "start"]);
                    }
                }
            }
        }
    }

    // Group heading inside a section
    Component {
        id: headerRow

        BarText {
            property var row: ({ label: "" })
            topPadding: 10
            text: row.label.toUpperCase()
            color: Theme.primary
            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 1.2
        }
    }

    // One labelled setting
    Component {
        id: rowEditor

        Rectangle {
            id: setting
            property var row: ({ key: "", label: "", type: "" })
            readonly property var cfg: row
            readonly property var value: cfg.key ? Config[cfg.key] : undefined

            // Choice rows with many options put the chips under the label
            readonly property bool wide: cfg.type === "choice" && (cfg.options ?? []).length > 4

            implicitHeight: wide ? labelBox.implicitHeight + ctl.implicitHeight + 42 : 50
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                id: labelBox
                anchors {
                    left: parent.left
                    leftMargin: 14
                    top: setting.wide ? parent.top : undefined
                    topMargin: 10
                    verticalCenter: setting.wide ? undefined : parent.verticalCenter
                }
                BarText {
                    text: setting.cfg.label
                }
                BarText {
                    visible: !!setting.cfg.section
                    text: setting.cfg.section ?? ""
                    color: Theme.alpha(Theme.textDim, 0.8)
                    font.pixelSize: 11
                }
            }

            Loader {
                id: ctl
                anchors {
                    right: setting.wide ? undefined : parent.right
                    rightMargin: 12
                    verticalCenter: setting.wide ? undefined : parent.verticalCenter
                    left: setting.wide ? parent.left : undefined
                    leftMargin: 14
                    top: setting.wide ? labelBox.bottom : undefined
                    topMargin: 8
                }
                sourceComponent: setting.cfg.type === "bool" ? switchCtl
                    : setting.cfg.type === "choice" ? (setting.wide ? choiceFlow : choiceCtl)
                    : setting.cfg.type === "string" ? stringCtl : sliderCtl
            }

            Component {
                id: switchCtl
                Rectangle {
                    width: 48
                    height: 26
                    radius: 13
                    color: setting.value ? Theme.primary : Theme.surfaceHighest

                    Behavior on color {
                        ColorAnimation { duration: Theme.dur(150) }
                    }

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        y: 3
                        x: setting.value ? parent.width - width - 3 : 3
                        color: setting.value ? Theme.primaryFg : Theme.textDim
                        Behavior on x {
                            NumberAnimation { duration: Theme.dur(150) }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.set(setting.cfg.key, !setting.value)
                    }
                }
            }

            Component {
                id: choiceCtl
                Row {
                    spacing: 4
                    Repeater {
                        model: setting.cfg?.options ?? []
                        delegate: Chip {
                            required property string modelData
                            label: modelData === "" ? "default" : modelData
                            bg: setting.value === modelData ? Theme.primary : Theme.surfaceHigh
                            fg: setting.value === modelData ? Theme.primaryFg : Theme.text
                            hoverBg: setting.value === modelData ? Theme.primary : Theme.surfaceHighest
                            onLeftClicked: Config.set(setting.cfg.key, modelData)
                        }
                    }
                }
            }

            Component {
                id: choiceFlow
                Flow {
                    width: setting.width - 28
                    spacing: 6
                    Repeater {
                        model: setting.cfg?.options ?? []
                        delegate: Chip {
                            required property string modelData
                            label: modelData === "" ? "default" : modelData
                            bg: setting.value === modelData ? Theme.primary : Theme.surfaceHigh
                            fg: setting.value === modelData ? Theme.primaryFg : Theme.text
                            hoverBg: setting.value === modelData ? Theme.primary : Theme.surfaceHighest
                            onLeftClicked: Config.set(setting.cfg.key, modelData)
                        }
                    }
                }
            }

            // Slider with the value next to it; click or drag, snaps to the step
            Component {
                id: sliderCtl
                Row {
                    spacing: 12

                    Item {
                        id: sl
                        width: 210
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        readonly property real min: setting.cfg?.min ?? 0
                        readonly property real max: setting.cfg?.max ?? 1
                        readonly property real frac: setting.value === undefined || max === min ? 0
                            : Math.max(0, Math.min(1, (setting.value - min) / (max - min)))

                        function setFrom(x) {
                            const f = Math.max(0, Math.min(1, x / width));
                            const c = setting.cfg;
                            let v = min + f * (max - min);
                            v = Math.round(v / c.step) * c.step;
                            v = Math.max(min, Math.min(max, v));
                            Config.set(c.key, c.type === "real" ? Math.round(v * 100) / 100 : Math.round(v));
                        }

                        Rectangle {
                            id: slTrack
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 6
                            radius: 3
                            color: Theme.surfaceHighest

                            Rectangle {
                                width: Math.max(6, slTrack.width * sl.frac)
                                height: parent.height
                                radius: 3
                                color: Theme.primary
                            }
                        }
                        Rectangle {
                            x: slTrack.width * sl.frac - width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            width: slMouse.pressed ? 20 : 16
                            height: width
                            radius: width / 2
                            color: Theme.primaryContainerFg
                            border.width: 3
                            border.color: Theme.primary
                            Behavior on width {
                                NumberAnimation { duration: Theme.dur(100) }
                            }
                        }
                        MouseArea {
                            id: slMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: event => sl.setFrom(event.x)
                            onPositionChanged: event => {
                                if (pressed)
                                    sl.setFrom(event.x);
                            }
                            onWheel: event => {
                                const c = setting.cfg;
                                const v = Math.max(sl.min, Math.min(sl.max, setting.value + (event.angleDelta.y > 0 ? c.step : -c.step)));
                                Config.set(c.key, c.type === "real" ? Math.round(v * 100) / 100 : Math.round(v));
                            }
                        }
                    }
                    BarText {
                        width: 56
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        text: setting.value === undefined ? "" : setting.cfg.type === "real" ? Number(setting.value).toFixed(2) : String(setting.value)
                        font.bold: true
                        color: Theme.primary
                    }
                }
            }

            Component {
                id: stepperCtl
                Row {
                    spacing: 4
                    Chip {
                        icon: Theme.icon(0xf0374)
                        bg: Theme.surfaceHigh
                        onLeftClicked: stepper.nudge(-1)
                    }
                    BarText {
                        id: stepper
                        width: 52
                        horizontalAlignment: Text.AlignHCenter
                        height: Theme.pillHeight
                        text: setting.value === undefined ? "" : setting.cfg.type === "real" ? Number(setting.value).toFixed(2) : String(setting.value)
                        function nudge(dir) {
                            const c = setting.cfg;
                            const v = Math.max(c.min, Math.min(c.max, setting.value + dir * c.step));
                            Config.set(c.key, c.type === "real" ? Math.round(v * 100) / 100 : Math.round(v));
                        }
                    }
                    Chip {
                        icon: Theme.icon(0xf0415)
                        bg: Theme.surfaceHigh
                        onLeftClicked: stepper.nudge(1)
                    }
                }
            }

            Component {
                id: stringCtl
                Rectangle {
                    width: 220
                    height: 28
                    radius: Theme.innerRadius
                    color: Theme.surfaceHigh

                    TextField {
                        anchors {
                            fill: parent
                            leftMargin: 8
                            rightMargin: 8
                        }
                        background: null
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 13
                        selectionColor: Theme.primary
                        selectedTextColor: Theme.primaryFg
                        text: setting.value
                        onEditingFinished: Config.set(setting.cfg.key, text)
                    }
                }
            }
        }
    }

    // Dynamic island style presets
    Component {
        id: islandStylesEditor

        Rectangle {
            implicitHeight: iscol.implicitHeight + 22
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                id: iscol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                BarText {
                    text: "Island styles: pick one, then fine-tune below"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 10
                    Repeater {
                        model: Config.islandStyles
                        delegate: PresetCard {
                            required property var modelData
                            kind: "island"
                            name: modelData.name
                            selected: Config.barMode === "island" && Config.islandStyle === modelData.name
                            vals: Object.assign({}, Config.islandBase, modelData.values)
                            onPicked: Config.applyIslandStyle(modelData.name)
                        }
                    }
                }
            }
        }
    }

    // Control center style presets
    Component {
        id: ccStylesEditor

        Rectangle {
            implicitHeight: ccol2.implicitHeight + 22
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                id: ccol2
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                BarText {
                    text: "Control center styles: pick one, then fine-tune below"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 10
                    Repeater {
                        model: Config.ccStyles
                        delegate: PresetCard {
                            required property var modelData
                            kind: "cc"
                            name: modelData.name
                            selected: Config.ccStyle === modelData.name
                            vals: Object.assign({}, Config.ccBase, modelData.values)
                            onPicked: Config.applyCcStyle(modelData.name)
                        }
                    }
                }
            }
        }
    }

    // Power menu style presets
    Component {
        id: powerStylesEditor

        Rectangle {
            implicitHeight: pwcol.implicitHeight + 22
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                id: pwcol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                BarText {
                    text: "Power menu styles: pick one, then fine-tune below"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 10
                    Repeater {
                        model: Config.powerStyles
                        delegate: PresetCard {
                            required property var modelData
                            kind: "power"
                            name: modelData.name
                            selected: Config.powerStyle === modelData.name
                            vals: Object.assign({}, Config.powerBase, modelData.values)
                            onPicked: Config.applyPowerStyle(modelData.name)
                        }
                    }
                }
            }
        }
    }

    // Lock screen style presets
    Component {
        id: lockStylesEditor

        Rectangle {
            implicitHeight: lkcol.implicitHeight + 22
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                id: lkcol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                BarText {
                    text: "Lock screen styles: pick one, then fine-tune below"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 10
                    Repeater {
                        model: Config.lockStyles
                        delegate: PresetCard {
                            required property var modelData
                            kind: "lock"
                            name: modelData.name
                            selected: Config.lockStyle === modelData.name
                            vals: Object.assign({}, Config.lockBase, modelData.values)
                            onPicked: Config.applyLockStyle(modelData.name)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: launcherStylesEditor

        Rectangle {
            implicitHeight: pcol.implicitHeight + 22
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                id: pcol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                BarText {
                    text: "Launcher styles: pick one, then fine-tune below"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 10
                    Repeater {
                        model: Config.launcherStyles
                        delegate: PresetCard {
                            required property var modelData
                            kind: "launcher"
                            name: modelData.name
                            selected: Config.launcherStyle === modelData.name
                            vals: Object.assign({}, Config.launcherBase, modelData.values)
                            onPicked: Config.applyLauncherStyle(modelData.name)
                        }
                    }
                }
            }
        }
    }

    // Try-it buttons
    Component {
        id: actionsEditor

        Rectangle {
            implicitHeight: arow.implicitHeight + 20
            radius: Theme.innerRadius
            color: Theme.surfaceMid

            Row {
                id: arow
                anchors {
                    left: parent.left
                    top: parent.top
                    margins: 10
                }
                spacing: 6
                Chip {
                    icon: Theme.icon(0xf033e)
                    label: "Preview lock screen"
                    bg: Theme.surfaceHigh
                    onLeftClicked: {
                        Panels.close();
                        Lock.preview = true;
                    }
                }
                Chip {
                    icon: Theme.icon(0xf0100)
                    label: "Take screenshot"
                    bg: Theme.surfaceHigh
                    onLeftClicked: Shot.capture()
                }
            }
        }
    }

    Component {
        id: looksEditor

        Rectangle {
            implicitHeight: pcol.implicitHeight + 22
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                id: pcol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                BarText {
                    text: "Looks: restyle the bar, panels, notifications and pop-ups together"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 10
                    Repeater {
                        model: Config.looks
                        delegate: PresetCard {
                            required property var modelData
                            kind: "look"
                            name: modelData.name
                            selected: Config.look === modelData.name
                            vals: {
                                const bar = Config.barStyles.find(x => x.name === modelData.bar);
                                return Object.assign({}, Config.baseStyle, Config.panelBase, bar ? bar.values : {}, modelData.values);
                            }
                            onPicked: Config.applyLook(modelData.name)
                        }
                    }
                }
            }
        }
    }

    // Bar layout: which modules sit in which zone, and where islands break
    Component {
        id: layoutEditor

        Rectangle {
            id: lay
            readonly property var layout: Config.barLayout
            readonly property var zones: ["left", "center", "right"]
            readonly property var used: zones.reduce((a, z) => a.concat(layout[z] ?? []), [])
            readonly property var unused: BarModules.ids.filter(id => used.indexOf(id) < 0)

            implicitHeight: lycol.implicitHeight + 20
            radius: Theme.innerRadius
            color: Theme.surfaceMid

            // Apply fn to a copy of one zone's list
            function edit(zone, fn) {
                const next = Object.assign({}, layout);
                const list = (layout[zone] ?? []).slice();
                fn(list);
                next[zone] = list;
                Config.set("barLayout", next);
            }
            function move(zone, i, d) {
                edit(zone, a => {
                    const j = i + d;
                    if (j >= 0 && j < a.length)
                        [a[i], a[j]] = [a[j], a[i]];
                });
            }
            function send(zone, i, to) {
                const id = (layout[zone] ?? [])[i];
                edit(zone, a => a.splice(i, 1));
                edit(to, a => a.push(id));
            }

            Column {
                id: lycol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
                spacing: 8

                BarText {
                    text: "Bar layout (a break starts a new island)"
                    font.bold: true
                }
                Repeater {
                    model: lay.zones
                    delegate: Column {
                        id: zoneCol
                        required property string modelData
                        readonly property string zone: modelData
                        width: lycol.width
                        spacing: 3

                        BarText {
                            text: zone.toUpperCase()
                            color: Theme.primary
                            font.pixelSize: 12
                        }
                        Repeater {
                            model: lay.layout[zone] ?? []
                            delegate: Row {
                                required property string modelData
                                required property int index
                                spacing: 3
                                BarText {
                                    width: 120
                                    height: Theme.pillHeight
                                    text: modelData === "|" ? "— break —" : modelData
                                    color: modelData === "|" ? Theme.textDim : Theme.text
                                }
                                Chip {
                                    icon: Theme.icon(0xf0143)
                                    bg: Theme.surfaceHigh
                                    onLeftClicked: lay.move(zoneCol.zone, index, -1)
                                }
                                Chip {
                                    icon: Theme.icon(0xf0140)
                                    bg: Theme.surfaceHigh
                                    onLeftClicked: lay.move(zoneCol.zone, index, 1)
                                }
                                Repeater {
                                    model: modelData === "|" ? [] : lay.zones.filter(z => z !== zoneCol.zone)
                                    delegate: Chip {
                                        required property string modelData
                                        label: "→ " + modelData
                                        bg: Theme.surfaceHigh
                                        onLeftClicked: lay.send(zoneCol.zone, index, modelData)
                                    }
                                }
                                Chip {
                                    icon: Theme.icon(0xf0156)
                                    bg: Theme.surfaceHigh
                                    hoverBg: Theme.error
                                    hoverFg: Theme.errorFg
                                    onLeftClicked: lay.edit(zoneCol.zone, a => a.splice(index, 1))
                                }
                            }
                        }
                        Chip {
                            icon: Theme.icon(0xf0415)
                            label: "island break"
                            bg: Theme.surfaceHigh
                            onLeftClicked: lay.edit(zoneCol.zone, a => a.push("|"))
                        }
                    }
                }
                Flow {
                    width: parent.width
                    spacing: 4
                    visible: lay.unused.length > 0
                    BarText {
                        height: Theme.pillHeight
                        text: "Add to left:"
                        color: Theme.textDim
                    }
                    Repeater {
                        model: lay.unused
                        delegate: Chip {
                            required property string modelData
                            icon: Theme.icon(0xf0415)
                            label: modelData
                            bg: Theme.surfaceHigh
                            onLeftClicked: lay.edit("left", a => a.push(modelData))
                        }
                    }
                }
            }
        }
    }

    Component {
        id: stylesEditor

        Rectangle {
            implicitHeight: pcol.implicitHeight + 22
            radius: Math.max(6, Config.itemRadius)
            color: Theme.alpha(Theme.surfaceMid, 0.9)

            Column {
                id: pcol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 10

                BarText {
                    text: "Bar styles: pick one, then fine-tune below"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 10
                    Repeater {
                        model: Config.barStyles
                        delegate: PresetCard {
                            required property var modelData
                            kind: "bar"
                            name: modelData.name
                            selected: Config.barStyle === modelData.name
                            vals: Object.assign({}, Config.baseStyle, modelData.values)
                            onPicked: Config.applyStyle(modelData.name)
                        }
                    }
                }
            }
        }
    }

    // Control-center toggle order: enable/disable and move up/down
    Component {
        id: togglesEditor

        Rectangle {
            readonly property var order: Config.ccToggles
            readonly property var hidden: panel.allToggles.filter(id => order.indexOf(id) < 0)

            implicitHeight: col.implicitHeight + 20
            radius: Theme.innerRadius
            color: Theme.surfaceMid

            function move(i, d) {
                const a = order.slice();
                const j = i + d;
                if (j < 0 || j >= a.length)
                    return;
                [a[i], a[j]] = [a[j], a[i]];
                Config.set("ccToggles", a);
            }

            Column {
                id: col
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
                spacing: 4

                BarText {
                    text: "Quick toggles (order)"
                    font.bold: true
                }
                Repeater {
                    model: order
                    delegate: Row {
                        required property string modelData
                        required property int index
                        spacing: 4
                        BarText {
                            width: 130
                            height: Theme.pillHeight
                            text: modelData
                        }
                        Chip {
                            icon: Theme.icon(0xf0143)
                            bg: Theme.surfaceHigh
                            onLeftClicked: move(index, -1)
                        }
                        Chip {
                            icon: Theme.icon(0xf0140)
                            bg: Theme.surfaceHigh
                            onLeftClicked: move(index, 1)
                        }
                        Chip {
                            icon: Theme.icon(0xf0156)
                            bg: Theme.surfaceHigh
                            hoverBg: Theme.error
                            hoverFg: Theme.errorFg
                            onLeftClicked: Config.set("ccToggles", order.filter(id => id !== modelData))
                        }
                    }
                }
                Flow {
                    width: parent.width
                    spacing: 4
                    visible: hidden.length > 0
                    BarText {
                        height: Theme.pillHeight
                        text: "Add:"
                        color: Theme.textDim
                    }
                    Repeater {
                        model: hidden
                        delegate: Chip {
                            required property string modelData
                            icon: Theme.icon(0xf0415)
                            label: modelData
                            bg: Theme.surfaceHigh
                            onLeftClicked: Config.set("ccToggles", order.concat([modelData]))
                        }
                    }
                }
            }
        }
    }

    // Per-color overrides on top of the matugen palette
    Component {
        id: colorsEditor

        Rectangle {
            implicitHeight: ccol.implicitHeight + 20
            radius: Theme.innerRadius
            color: Theme.surfaceMid

            function setColor(key, hex) {
                const o = Object.assign({}, Config.colorOverrides);
                if (/^#[0-9a-fA-F]{6}$/.test(hex))
                    o[key] = hex;
                else
                    delete o[key];
                Config.set("colorOverrides", o);
            }

            Column {
                id: ccol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
                spacing: 4

                BarText {
                    text: "Color overrides (#rrggbb, empty = follow wallpaper)"
                    font.bold: true
                }
                Repeater {
                    model: panel.colorKeys
                    delegate: Row {
                        required property string modelData
                        spacing: 8
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 8
                            color: Theme.byName(modelData, "transparent")
                            border.width: 1
                            border.color: Theme.outline
                        }
                        BarText {
                            width: 150
                            height: 28
                            text: modelData
                        }
                        Rectangle {
                            width: 120
                            height: 28
                            radius: Theme.innerRadius
                            color: Theme.surfaceHigh
                            TextField {
                                anchors {
                                    fill: parent
                                    leftMargin: 8
                                    rightMargin: 8
                                }
                                background: null
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: 13
                                maximumLength: 7
                                placeholderText: "auto"
                                placeholderTextColor: Theme.alpha(Theme.text, 0.4)
                                text: Config.colorOverrides[modelData] ?? ""
                                onEditingFinished: setColor(modelData, text)
                            }
                        }
                    }
                }
            }
        }
    }
}
