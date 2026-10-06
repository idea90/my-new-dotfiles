import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs
import qs.modules
import qs.services

// GUI for config.json: every change applies live and is saved automatically.
// The sections below are data; to expose a new Config property, add a row.
Card {
    id: panel

    implicitWidth: Math.min(780, parent ? parent.width - 40 : 780)
    implicitHeight: Math.min(parent ? parent.height - 80 : 600, 620)

    property int tab: 0

    // type: bool | int | real | choice | string
    readonly property var sections: [
        { name: "Looks", icon: 0xf03d8, rows: [
            { type: "looks" },
            { type: "styles" }
        ]},
        { name: "Layout", icon: 0xf0570, rows: [
            { type: "layout" },
            { key: "wsStyle", label: "Workspace style", type: "choice", options: ["pills", "dots", "numbers"] }
        ]},
        { name: "Lock & capture", icon: 0xf033e, rows: [
            { type: "actions" },
            { key: "lockBlur", label: "Lock blur", type: "int", min: 0, max: 64, step: 4 },
            { key: "lockDim", label: "Lock dim", type: "real", min: 0, max: 1, step: 0.05 },
            { key: "lockClockSize", label: "Lock clock size", type: "int", min: 40, max: 200, step: 8 },
            { key: "lockFieldWidth", label: "Password field width", type: "int", min: 200, max: 600, step: 20 },
            { key: "lockAlign", label: "Lock layout", type: "choice", options: ["center", "left"] },
            { key: "lockWallpaper", label: "Wallpaper background", type: "bool" },
            { key: "lockShowDate", label: "Show date", type: "bool" },
            { key: "lockShowGreeting", label: "Show greeting", type: "bool" },
            { key: "lockShowMedia", label: "Show now playing", type: "bool" },
            { key: "lockShowBattery", label: "Show battery", type: "bool" },
            { key: "shotMode", label: "Screenshot mode", type: "choice", options: ["area", "window", "screen"] },
            { key: "shotDelay", label: "Screenshot delay (s)", type: "int", min: 0, max: 30, step: 1 },
            { key: "shotAction", label: "After capture", type: "choice", options: ["copy", "save", "both"] },
            { key: "shotPreview", label: "Show preview", type: "bool" },
            { key: "shotPreviewSeconds", label: "Preview time (s, 0 = stay)", type: "int", min: 0, max: 30, step: 1 },
            { key: "shotPreviewPosition", label: "Preview corner", type: "choice", options: ["bottom-left", "bottom-right", "top-left", "top-right"] },
            { key: "shotPreviewWidth", label: "Preview width", type: "int", min: 180, max: 480, step: 10 }
        ]},
        { name: "Panels", icon: 0xf0493, rows: [
            { key: "panelRadius", label: "Panel radius", type: "int", min: 0, max: 36, step: 1 },
            { key: "itemRadius", label: "Card / tile radius", type: "int", min: 0, max: 28, step: 1 },
            { key: "panelOpacity", label: "Panel opacity", type: "real", min: 0.3, max: 1, step: 0.05 },
            { key: "panelBorder", label: "Panel border", type: "int", min: 0, max: 4, step: 1 },
            { key: "panelColor", label: "Panel color", type: "choice", options: ["surfaceLow", "surfaceMid", "surfaceHigh", "primaryContainer", "tertiaryContainer"] },
            { key: "panelBorderColor", label: "Panel border color", type: "choice", options: ["outlineVariant", "outline", "primary", "tertiary"] },
            { key: "animSpeed", label: "Animation speed (0 = off)", type: "real", min: 0, max: 3, step: 0.25 },
            { key: "notifPosition", label: "Notifications at", type: "choice", options: ["top-right", "top-left", "bottom-right", "bottom-left"] },
            { key: "notifWidth", label: "Notification width", type: "int", min: 260, max: 600, step: 10 },
            { key: "notifMarginTop", label: "Notification edge gap", type: "int", min: 0, max: 120, step: 2 },
            { key: "notifMarginSide", label: "Notification side gap", type: "int", min: 0, max: 80, step: 2 },
            { key: "osdPosition", label: "Volume pop-up at", type: "choice", options: ["bottom", "top"] },
            { key: "osdMargin", label: "Volume pop-up gap", type: "int", min: 0, max: 300, step: 5 },
            { key: "osdWidth", label: "Volume pop-up width", type: "int", min: 200, max: 500, step: 10 },
            { key: "powerButtonWidth", label: "Power button width", type: "int", min: 90, max: 260, step: 5 },
            { key: "powerButtonHeight", label: "Power button height", type: "int", min: 90, max: 300, step: 5 }
        ]},
        { name: "Bar", icon: 0xf0e2c, rows: [
            { key: "barBackground", label: "Background", type: "choice", options: ["islands", "solid", "none"] },
            { key: "barColor", label: "Color", type: "choice", options: ["surfaceLow", "surfaceMid", "surfaceHigh", "primaryContainer", "tertiaryContainer"] },
            { key: "borderColor", label: "Border color", type: "choice", options: ["outlineVariant", "outline", "primary", "tertiary"] },
            { key: "barRadius", label: "Solid bar radius", type: "int", min: 0, max: 32, step: 1 },
            { key: "barPosition", label: "Position", type: "choice", options: ["top", "bottom"] },
            { key: "barHeight", label: "Height", type: "int", min: 24, max: 64, step: 1 },
            { key: "barMarginTop", label: "Edge gap", type: "int", min: 0, max: 40, step: 1 },
            { key: "barMarginSide", label: "Side gap", type: "int", min: 0, max: 60, step: 1 },
            { key: "islandSpacing", label: "Island spacing", type: "int", min: 0, max: 30, step: 1 },
            { key: "islandOpacity", label: "Island opacity", type: "real", min: 0, max: 1, step: 0.05 },
            { key: "islandBorder", label: "Island border", type: "int", min: 0, max: 4, step: 1 },
            { key: "islandRadius", label: "Island radius", type: "int", min: 0, max: 32, step: 1 }
        ]},
        { name: "Modules", icon: 0xf0570, rows: [
            { key: "showLauncher", label: "Launcher button", type: "bool" },
            { key: "showWorkspaces", label: "Workspaces", type: "bool" },
            { key: "showWindowTitle", label: "Window title", type: "bool" },
            { key: "showClock", label: "Clock", type: "bool" },
            { key: "showNowPlaying", label: "Now playing", type: "bool" },
            { key: "showTray", label: "Tray", type: "bool" },
            { key: "showStatus", label: "Status (cpu, wifi, ...)", type: "bool" },
            { key: "showActions", label: "Actions", type: "bool" },
            { key: "clock24h", label: "24-hour clock", type: "bool" },
            { key: "clockSeconds", label: "Clock seconds", type: "bool" }
        ]},
        { name: "Control center", icon: 0xf0493, rows: [
            { key: "ccSide", label: "Side", type: "choice", options: ["right", "left"] },
            { key: "ccWidth", label: "Width", type: "int", min: 300, max: 700, step: 10 },
            { key: "ccColumns", label: "Toggle columns", type: "int", min: 2, max: 6, step: 1 },
            { key: "ccTopMargin", label: "Top gap", type: "int", min: 0, max: 120, step: 1 },
            { key: "ccSideMargin", label: "Side gap", type: "int", min: 0, max: 60, step: 1 },
            { key: "ccBottomMargin", label: "Bottom gap", type: "int", min: 0, max: 60, step: 1 },
            { key: "ccPadding", label: "Padding", type: "int", min: 4, max: 30, step: 1 },
            { key: "ccSpacing", label: "Spacing", type: "int", min: 0, max: 30, step: 1 },
            { key: "ccSliders", label: "Sliders", type: "bool" },
            { key: "ccMedia", label: "Now playing", type: "bool" },
            { key: "ccNotifications", label: "Notifications", type: "bool" },
            { type: "toggles" }
        ]},
        { name: "Launcher", icon: 0xf0349, rows: [
            { key: "launcherWidth", label: "Width", type: "int", min: 360, max: 900, step: 10 },
            { key: "launcherTop", label: "Vertical position", type: "real", min: 0, max: 0.6, step: 0.02 },
            { key: "launcherDim", label: "Backdrop dim", type: "real", min: 0, max: 1, step: 0.05 },
            { key: "launcherRows", label: "Visible rows", type: "int", min: 3, max: 14, step: 1 },
            { key: "launcherRowHeight", label: "Row height", type: "int", min: 32, max: 80, step: 1 },
            { key: "launcherIconSize", label: "Icon size", type: "int", min: 16, max: 56, step: 1 },
            { key: "launcherSearchHeight", label: "Search height", type: "int", min: 32, max: 70, step: 1 },
            { key: "launcherRadius", label: "Corner radius", type: "int", min: 0, max: 36, step: 1 },
            { key: "launcherPlaceholder", label: "Placeholder", type: "string" },
            { key: "launcherCounter", label: "Result counter", type: "bool" },
            { key: "launcherDescriptions", label: "Descriptions", type: "bool" }
        ]},
        { name: "Style", icon: 0xf03d8, rows: [
            { key: "font", label: "Font family", type: "string" },
            { key: "fontSize", label: "Font size", type: "int", min: 9, max: 24, step: 1 },
            { key: "iconSize", label: "Icon size", type: "int", min: 10, max: 30, step: 1 },
            { key: "pillHeight", label: "Item height", type: "int", min: 20, max: 40, step: 1 },
            { key: "pillRadius", label: "Group radius", type: "int", min: 0, max: 24, step: 1 },
            { key: "innerRadius", label: "Item radius", type: "int", min: 0, max: 20, step: 1 },
            { type: "colors" }
        ]}
    ]

    readonly property var allToggles: ["wifi", "sound", "mic", "silent", "game", "awake", "capture", "theme", "settings"]
    readonly property var colorKeys: ["primary", "primaryContainer", "tertiary", "tertiaryContainer", "error", "surfaceLow", "surfaceHigh", "text", "textDim", "outline"]

    ColumnLayout {
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            BarText {
                Layout.fillWidth: true
                text: "Settings"
                font.bold: true
                font.pixelSize: 17
            }
            Chip {
                icon: Theme.icon(0xf0450)
                label: "Reset all"
                bg: Theme.surfaceHigh
                hoverBg: Theme.error
                hoverFg: Theme.errorFg
                onLeftClicked: Config.reset()
            }
        }

        // Tabs
        Flow {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: panel.sections
                delegate: Chip {
                    required property var modelData
                    required property int index
                    icon: Theme.icon(modelData.icon)
                    label: modelData.name
                    bg: panel.tab === index ? Theme.primaryContainer : "transparent"
                    fg: panel.tab === index ? Theme.primaryContainerFg : Theme.text
                    onLeftClicked: panel.tab = index
                }
            }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: panel.sections[panel.tab].rows
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}

            delegate: Loader {
                required property var modelData
                width: list.width - 10
                sourceComponent: modelData.type === "actions" ? actionsEditor
                    : modelData.type === "looks" ? looksEditor
                    : modelData.type === "layout" ? layoutEditor
                    : modelData.type === "styles" ? stylesEditor
                    : modelData.type === "toggles" ? togglesEditor
                    : modelData.type === "colors" ? colorsEditor : rowEditor
                onLoaded: if (item && "row" in item) item.row = modelData
            }
        }

        BarText {
            text: "Saved to ~/.config/quickshell/config.json"
            color: Theme.textDim
            font.pixelSize: 11
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

            implicitHeight: 40
            radius: Theme.innerRadius
            color: Theme.surfaceMid

            BarText {
                anchors {
                    left: parent.left
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                text: setting.cfg.label
            }

            Loader {
                anchors {
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                sourceComponent: setting.cfg.type === "bool" ? switchCtl
                    : setting.cfg.type === "choice" ? choiceCtl
                    : setting.cfg.type === "string" ? stringCtl : stepperCtl
            }

            Component {
                id: switchCtl
                Rectangle {
                    width: 44
                    height: 24
                    radius: 12
                    color: setting.value ? Theme.primary : Theme.surfaceHighest

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
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
                            label: modelData
                            bg: setting.value === modelData ? Theme.primary : Theme.surfaceHigh
                            fg: setting.value === modelData ? Theme.primaryFg : Theme.text
                            hoverBg: setting.value === modelData ? Theme.primary : Theme.surfaceHighest
                            onLeftClicked: Config.set(setting.cfg.key, modelData)
                        }
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

    // Whole-desktop looks
    Component {
        id: looksEditor

        Rectangle {
            implicitHeight: lcol.implicitHeight + 20
            radius: Theme.innerRadius
            color: Theme.surfaceMid

            Column {
                id: lcol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
                spacing: 6

                BarText {
                    text: "Looks (restyle bar, panels, notifications and pop-ups together)"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 6
                    Repeater {
                        model: Config.looks
                        delegate: Chip {
                            required property var modelData
                            label: modelData.name
                            bg: Config.look === modelData.name ? Theme.primary : Theme.surfaceHigh
                            fg: Config.look === modelData.name ? Theme.primaryFg : Theme.text
                            hoverBg: Config.look === modelData.name ? Theme.primary : Theme.surfaceHighest
                            onLeftClicked: Config.applyLook(modelData.name)
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

    // Bar style presets
    Component {
        id: stylesEditor

        Rectangle {
            implicitHeight: scol.implicitHeight + 20
            radius: Theme.innerRadius
            color: Theme.surfaceMid

            Column {
                id: scol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
                spacing: 6

                BarText {
                    text: "Bar styles (pick one, then fine-tune below)"
                    font.bold: true
                }
                Flow {
                    width: parent.width
                    spacing: 6
                    Repeater {
                        model: Config.barStyles
                        delegate: Chip {
                            required property var modelData
                            label: modelData.name
                            bg: Config.barStyle === modelData.name ? Theme.primary : Theme.surfaceHigh
                            fg: Config.barStyle === modelData.name ? Theme.primaryFg : Theme.text
                            hoverBg: Config.barStyle === modelData.name ? Theme.primary : Theme.surfaceHighest
                            onLeftClicked: Config.applyStyle(modelData.name)
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
