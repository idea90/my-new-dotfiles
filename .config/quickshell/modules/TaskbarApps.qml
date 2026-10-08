import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.services

// Windows-style taskbar: pinned apps (Config.dockApps) then every other running
// window, icon only. A small bar under the icon marks running apps, longer and in
// the accent color for the focused one. Click: open / focus; middle: new window;
// right: close.
Grid {
    id: tb

    columns: Theme.vertical ? 1 : 100
    spacing: 4
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter

    readonly property var entries: {
        const out = [];
        const used = new Set();
        const tops = ToplevelManager.toplevels.values;
        const match = (top, entry) => {
            const id = (top.appId ?? "").toLowerCase();
            return id !== "" && (id === entry.id.toLowerCase() || id === (entry.startupClass ?? "").toLowerCase()
                                 || entry.name.toLowerCase() === id);
        };
        for (const key of Config.dockApps) {
            const entry = DesktopEntries.heuristicLookup(key);
            if (!entry)
                continue;
            const wins = tops.filter(t => match(t, entry));
            wins.forEach(t => used.add(t));
            out.push({ entry: entry, windows: wins, name: entry.name, icon: entry.icon });
        }
        for (const top of tops) {
            if (used.has(top))
                continue;
            const entry = DesktopEntries.heuristicLookup(top.appId ?? "");
            out.push({ entry: entry, windows: [top], name: entry ? entry.name : top.title, icon: entry ? entry.icon : (top.appId ?? "") });
        }
        return out;
    }

    Repeater {
        model: tb.entries

        delegate: Rectangle {
            id: app

            required property var modelData
            readonly property bool running: modelData.windows.length > 0
            readonly property bool focused: modelData.windows.some(t => t.activated)

            width: Theme.barItem + 8
            height: Theme.barItem
            radius: Theme.chipRadius
            color: mouse.pressed ? Theme.alpha(Theme.text, 0.12) : mouse.containsMouse ? Theme.alpha(Theme.text, 0.08) : focused ? Theme.alpha(Theme.text, 0.05) : "transparent"

            Behavior on color {
                ColorAnimation { duration: Theme.dur(120) }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: Math.round(Theme.barItem * 0.62)
                source: Quickshell.iconPath(app.modelData.icon, "application-x-executable")
                mipmap: true
                scale: mouse.pressed ? 0.86 : 1
                Behavior on scale {
                    NumberAnimation { duration: Theme.dur(100) }
                }
            }
            Rectangle {
                visible: app.running
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
                width: app.focused ? 16 : 6
                height: 3
                radius: 1.5
                color: app.focused ? Theme.primary : Theme.alpha(Theme.text, 0.55)
                Behavior on width {
                    NumberAnimation { duration: Theme.dur(160); easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: event => {
                    if (event.button === Qt.RightButton && app.running) {
                        app.modelData.windows[0].close();
                    } else if (event.button === Qt.MiddleButton || !app.running) {
                        if (app.modelData.entry)
                            app.modelData.entry.execute();
                    } else {
                        const wins = app.modelData.windows;
                        const at = wins.findIndex(t => t.activated);
                        wins[(at + 1) % wins.length].activate();
                    }
                }
            }
        }
    }
}
