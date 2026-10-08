import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs
import qs.modules
import qs.services

// Windows 11 style Start menu (Config.launcherLayout "start"):
// search box, a grid of pinned apps, "Recommended" (your most used apps),
// and a footer with your name and a power button. Typing switches to search
// results; "All" shows every app. Enter opens the first / selected result.
Rectangle {
    id: start

    required property var entries
    property bool allApps: false
    property string query: ""
    property int sel: 0
    readonly property bool searching: query.trim() !== ""

    readonly property var usable: entries.filter(e => !e.noDisplay)
    readonly property var results: AppMenu.search(entries, query)

    // Pinned: Config.dockApps first, then fill the grid with the most used apps
    readonly property var pinned: {
        const out = [];
        const seen = new Set();
        for (const k of Config.startPinned.length ? Config.startPinned : Config.dockApps) {
            const e = DesktopEntries.heuristicLookup(k);
            if (e && !seen.has(e.id)) {
                seen.add(e.id);
                out.push(e);
            }
        }
        const rest = usable.filter(e => !seen.has(e.id)).sort((a, b) => (AppMenu.usage[b.id] ?? 0) - (AppMenu.usage[a.id] ?? 0)
            || a.name.localeCompare(b.name));
        return out.concat(rest).slice(0, 18);
    }
    readonly property var recommended: usable.filter(e => (AppMenu.usage[e.id] ?? 0) > 0)
        .sort((a, b) => (AppMenu.usage[b.id] ?? 0) - (AppMenu.usage[a.id] ?? 0)).slice(0, 6)
    readonly property var allSorted: usable.slice().sort((a, b) => a.name.localeCompare(b.name))

    width: 640
    height: Math.min(parent.height - Theme.barSpaceTop - Theme.barSpaceBottom - 28, 660)
    x: (parent.width - width) / 2
    y: Theme.panelsBottom ? parent.height - height - Theme.barSpaceBottom - 12 : Theme.barSpaceTop + 12
    radius: Config.panelRadius
    color: Theme.panelFill
    border.width: Config.panelBorder
    border.color: Theme.panelBorderFill

    function reset() {
        query = "";
        search.text = "";
        allApps = false;
        sel = 0;
        search.forceActiveFocus();
    }
    function open(e) {
        AppMenu.launch(e);
    }

    MouseArea {
        anchors.fill: parent
    }

    component AppTile: Item {
        id: tile
        required property var entry
        signal activated
        width: 96
        height: 84

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: Config.itemRadius + 2
            color: tileMouse.containsMouse ? Theme.alpha(Theme.text, 0.07) : "transparent"
        }
        Column {
            anchors.centerIn: parent
            spacing: 6
            IconImage {
                anchors.horizontalCenter: parent.horizontalCenter
                implicitSize: 34
                source: Quickshell.iconPath(tile.entry.icon, "application-x-executable")
                mipmap: true
            }
            BarText {
                width: tile.width - 12
                horizontalAlignment: Text.AlignHCenter
                text: tile.entry.name
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: tile.activated()
        }
    }

    component Header: Item {
        property string title: ""
        property string action: ""
        signal clicked
        width: parent ? parent.width : 0
        height: 34
        BarText {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            text: parent.title
            font.bold: true
            font.pixelSize: 14
        }
        Rectangle {
            visible: parent.action !== ""
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            width: actionText.implicitWidth + 22
            height: 28
            radius: Config.itemRadius
            color: hm.containsMouse ? Theme.alpha(Theme.text, 0.08) : Theme.alpha(Theme.text, 0.05)
            border.width: 1
            border.color: Theme.alpha(Theme.text, 0.1)
            BarText {
                id: actionText
                anchors.centerIn: parent
                text: parent.parent.action
                font.pixelSize: 12
            }
            MouseArea {
                id: hm
                anchors.fill: parent
                hoverEnabled: true
                onClicked: parent.parent.clicked()
            }
        }
    }

    Column {
        anchors {
            fill: parent
            margins: 26
            bottomMargin: 0
        }
        spacing: 8

        // Search box
        Rectangle {
            width: parent.width
            height: 40
            radius: 20
            color: Theme.alpha(Theme.text, 0.07)
            border.width: 1
            border.color: search.activeFocus ? Theme.primary : Theme.alpha(Theme.text, 0.12)

            BarText {
                id: lens
                anchors {
                    left: parent.left
                    leftMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                text: Theme.icon(0xf0349)
                color: Theme.textDim
            }
            TextField {
                id: search
                anchors {
                    left: lens.right
                    right: parent.right
                    leftMargin: 8
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                background: null
                color: Theme.text
                placeholderText: "Search for apps, settings, and documents"
                placeholderTextColor: Theme.alpha(Theme.text, 0.55)
                font.family: Theme.font
                font.pixelSize: 14
                selectionColor: Theme.primary
                selectedTextColor: Theme.primaryFg
                onTextChanged: {
                    start.query = text;
                    start.sel = 0;
                }
                Keys.onPressed: event => {
                    const k = event.key;
                    if (k === Qt.Key_Escape) {
                        AppMenu.open = false;
                    } else if (k === Qt.Key_Return || k === Qt.Key_Enter) {
                        const list = start.searching ? start.results : start.pinned;
                        if (list.length > 0)
                            start.open(list[Math.min(start.sel, list.length - 1)]);
                    } else if (k === Qt.Key_Down && start.searching) {
                        start.sel = Math.min(start.results.length - 1, start.sel + 1);
                    } else if (k === Qt.Key_Up && start.searching) {
                        start.sel = Math.max(0, start.sel - 1);
                    } else
                        return;
                    event.accepted = true;
                }
            }
        }

        // ---- search results ----
        Column {
            visible: start.searching
            width: parent.width
            spacing: 2
            Header { title: start.results.length ? "Best match" : "No results" }
            Repeater {
                model: start.searching ? start.results.slice(0, 8) : []
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: parent.width
                    height: index === 0 ? 76 : 48
                    radius: Config.itemRadius + 2
                    color: index === start.sel ? Theme.alpha(Theme.text, 0.1) : rowMouse.containsMouse ? Theme.alpha(Theme.text, 0.06) : "transparent"
                    border.width: index === 0 && index === start.sel ? 1 : 0
                    border.color: Theme.alpha(Theme.text, 0.14)
                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: 14
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 14
                        IconImage {
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: index === 0 ? 44 : 28
                            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                            mipmap: true
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            BarText { text: modelData.name; font.pixelSize: index === 0 ? 15 : 13 }
                            BarText { text: "App"; font.pixelSize: 11; color: Theme.textDim }
                        }
                    }
                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: start.sel = index
                        onClicked: start.open(modelData)
                    }
                }
            }
        }

        // ---- all apps ----
        Column {
            visible: !start.searching && start.allApps
            width: parent.width
            Header {
                title: "All"
                action: "‹ Back"
                onClicked: start.allApps = false
            }
            ListView {
                width: parent.width
                height: start.height - 26 - 40 - 34 - 70 - 20
                clip: true
                model: start.allSorted
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width - 12
                    height: 42
                    radius: Config.itemRadius
                    color: am.containsMouse ? Theme.alpha(Theme.text, 0.07) : "transparent"
                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 12
                        IconImage { anchors.verticalCenter: parent.verticalCenter; implicitSize: 24; source: Quickshell.iconPath(modelData.icon, "application-x-executable"); mipmap: true }
                        BarText { anchors.verticalCenter: parent.verticalCenter; text: modelData.name; font.pixelSize: 13 }
                    }
                    MouseArea { id: am; anchors.fill: parent; hoverEnabled: true; onClicked: start.open(modelData) }
                }
            }
        }

        // ---- home: pinned and recommended ----
        Column {
            visible: !start.searching && !start.allApps
            width: parent.width
            spacing: 2

            Header {
                title: "Pinned"
                action: "All  ›"
                onClicked: start.allApps = true
            }
            Grid {
                columns: 6
                columnSpacing: 0
                rowSpacing: 0
                Repeater {
                    model: start.pinned
                    delegate: AppTile {
                        required property var modelData
                        required property int index
                        entry: modelData
                        width: (start.width - 52) / 6
                        onActivated: start.open(modelData)
                        PopIn {
                            order: index
                            trigger: AppMenu.open
                            fromScale: 0.9
                            rise: 8
                            stepMs: 14
                        }
                    }
                }
            }

            Item { width: 1; height: 8 }
            Header {
                title: "Recommended"
                visible: start.recommended.length > 0
            }
            Grid {
                columns: 2
                columnSpacing: 12
                visible: start.recommended.length > 0
                Repeater {
                    model: start.recommended
                    delegate: Rectangle {
                        required property var modelData
                        width: (start.width - 52 - 12) / 2
                        height: 50
                        radius: Config.itemRadius + 2
                        color: rm.containsMouse ? Theme.alpha(Theme.text, 0.07) : "transparent"
                        Row {
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: 12
                            IconImage { anchors.verticalCenter: parent.verticalCenter; implicitSize: 30; source: Quickshell.iconPath(modelData.icon, "application-x-executable"); mipmap: true }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                BarText { text: modelData.name; font.pixelSize: 12; width: 190; elide: Text.ElideRight }
                                BarText { text: "Frequently used"; font.pixelSize: 11; color: Theme.textDim }
                            }
                        }
                        MouseArea { id: rm; anchors.fill: parent; hoverEnabled: true; onClicked: start.open(modelData) }
                    }
                }
            }
        }
    }

    // ---- footer: user and power ----
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 66
        color: Theme.alpha("#000000", 0.18)
        radius: start.radius
        // square the top corners
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: parent.radius
            color: parent.color
        }
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 1
            color: Theme.alpha(Theme.text, 0.08)
        }
        Row {
            anchors {
                left: parent.left
                leftMargin: 32
                verticalCenter: parent.verticalCenter
            }
            spacing: 12
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: 16
                color: Theme.primary
                BarText {
                    anchors.centerIn: parent
                    text: Quickshell.env("USER").charAt(0).toUpperCase()
                    color: Theme.primaryFg
                    font.bold: true
                }
            }
            BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: Quickshell.env("USER")
                font.pixelSize: 13
            }
        }
        Rectangle {
            anchors {
                right: parent.right
                rightMargin: 28
                verticalCenter: parent.verticalCenter
            }
            width: 40
            height: 40
            radius: Config.itemRadius + 2
            color: pm.containsMouse ? Theme.alpha(Theme.text, 0.08) : "transparent"
            BarText {
                anchors.centerIn: parent
                text: Theme.icon(0xf0425)
                font.pixelSize: 18
            }
            MouseArea {
                id: pm
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    AppMenu.open = false;
                    Panels.toggle("power");
                }
            }
        }
    }
}
