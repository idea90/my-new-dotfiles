import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules

// Floating dock: pinned apps first, then other running windows. Click launches or
// focuses; the dot marks running apps. Auto-hides (hover the screen edge to show it).
PanelWindow {
    id: win

    readonly property bool vertical: Config.dockPosition !== "bottom"
    readonly property bool shown: !Config.dockAutoHide || hover.hovered || mouseHold
    property bool mouseHold: false

    visible: Config.dockEnabled
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-dock"

    anchors {
        bottom: Config.dockPosition === "bottom"
        left: Config.dockPosition === "left"
        right: Config.dockPosition === "right"
    }
    margins {
        bottom: 0
        left: 0
        right: 0
    }
    implicitWidth: vertical ? Config.dockSize + 60 : bar.implicitWidth + 80
    implicitHeight: vertical ? bar.implicitHeight + 80 : Config.dockSize + 60

    // Only the dock itself takes input; the rest of the window is click-through
    mask: Region { item: bar }

    // Apps: pinned first, then running windows that aren't pinned
    readonly property var entries: {
        const out = [];
        const used = new Set();
        const toplevels = ToplevelManager.toplevels.values;
        function match(top, entry) {
            const id = (top.appId ?? "").toLowerCase();
            return id !== "" && (id === entry.id.toLowerCase() || id === (entry.startupClass ?? "").toLowerCase()
                                 || entry.name.toLowerCase() === id);
        }
        for (const key of Config.dockApps) {
            const entry = DesktopEntries.heuristicLookup(key);
            if (!entry)
                continue;
            const wins = toplevels.filter(t => match(t, entry));
            wins.forEach(t => used.add(t));
            out.push({ entry: entry, windows: wins, pinned: true, name: entry.name, icon: entry.icon });
        }
        for (const top of toplevels) {
            if (used.has(top))
                continue;
            const entry = DesktopEntries.heuristicLookup(top.appId ?? "");
            out.push({ entry: entry, windows: [top], pinned: false,
                       name: entry ? entry.name : top.title, icon: entry ? entry.icon : (top.appId ?? "") });
        }
        return out;
    }

    HoverHandler {
        id: hover
    }

    Rectangle {
        id: bar

        implicitWidth: (vertical ? Config.dockSize : list.implicitWidth) + 20
        implicitHeight: (vertical ? list.implicitHeight : Config.dockSize) + 20
        width: implicitWidth
        height: implicitHeight
        radius: Config.panelRadius + 4
        color: Theme.panelFill
        border.width: Config.panelBorder
        border.color: Theme.panelBorderFill

        // Slides out of view when idle, leaving a sliver on the edge to hover
        property real hidden: win.shown ? 0 : (vertical ? width : height) - 6
        x: vertical ? (Config.dockPosition === "left" ? Config.dockMargin - hidden : parent.width - width - Config.dockMargin + hidden)
                    : (parent.width - width) / 2
        y: vertical ? (parent.height - height) / 2 : parent.height - height - Config.dockMargin + hidden

        Behavior on hidden {
            NumberAnimation { duration: Theme.dur(220); easing.type: Easing.OutCubic }
        }
        Behavior on implicitWidth {
            NumberAnimation { duration: Theme.dur(180); easing.type: Easing.OutCubic }
        }
        Behavior on implicitHeight {
            NumberAnimation { duration: Theme.dur(180); easing.type: Easing.OutCubic }
        }


        Flow {
            id: list
            anchors.centerIn: parent
            flow: vertical ? Flow.TopToBottom : Flow.LeftToRight
            spacing: 8

            readonly property real implicitWidth: childrenRect.width
            readonly property real implicitHeight: childrenRect.height

            Repeater {
                model: win.entries

                delegate: Item {
                    id: app

                    required property var modelData
                    readonly property bool running: modelData.windows.length > 0
                    readonly property bool focused: modelData.windows.some(t => t.activated)

                    width: Config.dockSize
                    height: Config.dockSize

                    Rectangle {
                        id: tile
                        anchors.fill: parent
                        radius: Config.itemRadius
                        color: mouse.containsMouse ? Theme.alpha(Theme.text, 0.14) : app.focused ? Theme.alpha(Theme.primary, 0.22) : "transparent"
                        scale: mouse.containsMouse && Config.dockMagnify ? 1.28 : 1
                        transformOrigin: Item.Bottom

                        Behavior on scale {
                            NumberAnimation { duration: Theme.dur(140); easing.type: Easing.OutBack }
                        }
                        Behavior on color {
                            ColorAnimation { duration: Theme.dur(120) }
                        }

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: Config.dockSize - 14
                            source: Quickshell.iconPath(app.modelData.icon, "application-x-executable")
                            mipmap: true
                        }
                    }

                    // Running indicator
                    Rectangle {
                        visible: app.running
                        width: app.focused ? 14 : 5
                        height: 5
                        radius: 3
                        color: app.focused ? Theme.primary : Theme.alpha(Theme.text, 0.7)
                        x: (parent.width - width) / 2
                        y: vertical ? parent.height / 2 : parent.height + 2
                        anchors.bottomMargin: 0
                        Behavior on width {
                            NumberAnimation { duration: Theme.dur(160) }
                        }
                    }

                    // Name tooltip
                    Rectangle {
                        visible: mouse.containsMouse
                        z: 10
                        width: label.implicitWidth + 20
                        height: 28
                        radius: 14
                        color: Theme.surfaceLow
                        border.width: 1
                        border.color: Theme.outlineVariant
                        x: vertical ? (Config.dockPosition === "left" ? parent.width + 18 : -width - 18) : (parent.width - width) / 2
                        y: vertical ? (parent.height - height) / 2 : -height - 14
                        BarText {
                            id: label
                            anchors.centerIn: parent
                            text: app.modelData.name
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        onPressedChanged: win.mouseHold = pressed
                        onClicked: event => {
                            if (event.button === Qt.RightButton && app.running) {
                                app.modelData.windows[0].close();
                            } else if (event.button === Qt.MiddleButton || !app.running) {
                                if (app.modelData.entry)
                                    app.modelData.entry.execute();
                            } else {
                                const wins = app.modelData.windows;
                                // Cycle through the app's windows
                                const at = wins.findIndex(t => t.activated);
                                wins[(at + 1) % wins.length].activate();
                            }
                        }
                    }
                }
            }
        }
    }
}
