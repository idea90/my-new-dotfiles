import QtQuick
import QtQuick.Layouts
import qs
import qs.modules
import qs.services

// Wallpaper grid with dark/light, scheme and random. Keys: arrows, Enter,
// D (dark/light), R (random), W (Wallhaven), / (search), Esc.
Card {
    id: picker

    width: 1120
    height: 600

    Connections {
        target: Panels
        function onOpenChanged() {
            if (Panels.open === "theme") {
                Wallpapers.refresh();
                grid.forceActiveFocus();
            }
        }
    }

    // Start on the current wallpaper once the list arrives
    Connections {
        target: Wallpapers
        function onItemsChanged() {
            const index = Wallpapers.items.findIndex(w => w.path === Wallpapers.current);
            grid.currentIndex = Math.max(0, index);
            grid.positionViewAtIndex(grid.currentIndex, GridView.Contain);
        }
    }

    readonly property var shown: Wallpapers.online ? Wallpapers.onlineItems : Wallpapers.items

    function activate(item) {
        if (Wallpapers.online) {
            Wallpapers.download(item.path);
        } else {
            Wallpapers.apply(item.path);
        }
        Panels.close();
    }

    function goOnline(on) {
        Wallpapers.online = on;
        if (on && Wallpapers.onlineItems.length === 0)
            Wallpapers.search("", 1);
        grid.currentIndex = 0;
        grid.forceActiveFocus();
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            BarText {
                text: "Theme"
                font.bold: true
                font.pixelSize: 16
            }
            BarText {
                Layout.fillWidth: true
                leftPadding: 6
                text: Wallpapers.online
                    ? (Wallpapers.downloading ? "downloading…" : Wallpapers.searching ? "searching…" : Wallpapers.error ? "wallhaven unreachable" : picker.shown.length + " results")
                    : Wallpapers.loading ? "preparing thumbnails…" : Wallpapers.items.length + " images"
                color: Theme.textDim
                font.pixelSize: 12
            }
            Chip {
                icon: Theme.icon(0xf0ac)
                label: "Wallhaven"
                fg: Wallpapers.online ? Theme.primaryFg : Theme.text
                bg: Wallpapers.online ? Theme.primary : Theme.surfaceHigh
                hoverBg: Wallpapers.online ? Theme.primary : Theme.surfaceHighest
                onLeftClicked: picker.goOnline(!Wallpapers.online)
            }
            Chip {
                icon: Wallpapers.mode === "dark" ? Theme.icon(0xf0594) : Theme.icon(0xf0599)
                label: Wallpapers.mode === "dark" ? "Dark" : "Light"
                bg: Theme.surfaceHigh
                onLeftClicked: Wallpapers.toggleMode()
            }
            Chip {
                icon: Theme.icon(0xf049d)
                label: "Random"
                bg: Theme.surfaceHigh
                onLeftClicked: {
                    Wallpapers.random();
                    Panels.close();
                }
            }
        }

        // Wallhaven search
        Rectangle {
            visible: Wallpapers.online
            Layout.fillWidth: true
            implicitHeight: 32
            radius: Theme.innerRadius
            color: Theme.surfaceMid
            border.width: search.activeFocus ? 1 : 0
            border.color: Theme.primary

            TextInput {
                id: search
                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                }
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                clip: true
                onAccepted: {
                    Wallpapers.search(text, 1);
                    grid.forceActiveFocus();
                }
                Keys.onEscapePressed: grid.forceActiveFocus()

                BarText {
                    visible: !search.text && !search.activeFocus
                    text: "Search wallhaven, Enter to run (empty = toplist)"
                    color: Theme.alpha(Theme.text, 0.45)
                }
            }
        }

        // Wallhaven filters. Each chip cycles through its options on click.
        Flow {
            visible: Wallpapers.online
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [{ label: "General", i: 0 }, { label: "Anime", i: 1 }, { label: "People", i: 2 }]

                Chip {
                    required property var modelData
                    readonly property bool on: Wallpapers.categories[modelData.i] === "1"
                    implicitHeight: 26
                    label: modelData.label
                    fg: on ? Theme.primaryFg : Theme.textDim
                    bg: on ? Theme.primary : Theme.surfaceMid
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
                    label: modelData.name + ": " + (value === "any" ? "any" : modelData.prop === "color" ? "" : value)
                    bg: Theme.surfaceMid
                    // Step forward on click, back on right click
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
                            rightMargin: 6
                            verticalCenter: parent.verticalCenter
                        }
                        width: 12
                        height: 12
                        radius: 6
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
                bg: Wallpapers.nsfw ? Theme.error : Theme.surfaceMid
                hoverBg: Wallpapers.nsfw ? Theme.error : Theme.surfaceHighest
                onLeftClicked: Wallpapers.set("nsfw", !Wallpapers.nsfw)
            }
        }

        // Color scheme chips
        Flow {
            visible: !Wallpapers.online
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: Wallpapers.schemes

                Chip {
                    required property string modelData
                    readonly property bool selected: Wallpapers.scheme === modelData
                    implicitHeight: 26
                    label: modelData
                    fg: selected ? Theme.primaryFg : Theme.textDim
                    bg: selected ? Theme.primary : Theme.surfaceMid
                    hoverBg: selected ? Theme.primary : Theme.surfaceHighest
                    onLeftClicked: Wallpapers.setScheme(modelData)
                }
            }
        }

        GridView {
            id: grid

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            cellWidth: width / 5
            cellHeight: cellWidth * 0.75 + 30
            model: picker.shown
            focus: true
            highlightMoveDuration: 120
            boundsBehavior: Flickable.StopAtBounds

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (picker.shown.length > 0)
                        picker.activate(picker.shown[currentIndex]);
                } else if (event.text === "/" && Wallpapers.online) {
                    search.forceActiveFocus();
                } else if (event.text.toLowerCase() === "w") {
                    picker.goOnline(!Wallpapers.online);
                } else if (Wallpapers.online && event.key === Qt.Key_PageDown && !Wallpapers.searching) {
                    Wallpapers.search(Wallpapers.query, Wallpapers.page + 1);
                } else if (event.text.toLowerCase() === "d") {
                    Wallpapers.toggleMode();
                } else if (event.text.toLowerCase() === "r") {
                    Wallpapers.random();
                    Panels.close();
                } else if (event.key === Qt.Key_Escape) {
                    Panels.close();
                } else {
                    return;
                }
                event.accepted = true;
            }

            highlight: Rectangle {
                radius: 12
                color: Theme.surfaceHigh
                border.width: 2
                border.color: Theme.primary
            }

            delegate: Item {
                id: tile

                required property var modelData
                required property int index

                width: grid.cellWidth
                height: grid.cellHeight

                Rectangle {
                    id: frame
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 8
                    }
                    height: width * 0.75 - 8
                    radius: 8
                    clip: true
                    color: Theme.surfaceMid

                    Image {
                        anchors.fill: parent
                        source: Wallpapers.online ? tile.modelData.thumb : "file://" + tile.modelData.thumb
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 400
                    }

                    // Current wallpaper badge
                    Rectangle {
                        visible: !Wallpapers.online && tile.modelData.path === Wallpapers.current
                        anchors {
                            top: parent.top
                            right: parent.right
                            margins: 6
                        }
                        width: 24
                        height: 24
                        radius: 12
                        color: Theme.primary

                        BarText {
                            anchors.centerIn: parent
                            text: Theme.icon(0xf012c)
                            color: Theme.primaryFg
                            font.pixelSize: 14
                        }
                    }
                }

                BarText {
                    anchors {
                        top: frame.bottom
                        topMargin: 4
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width - 16
                    horizontalAlignment: Text.AlignHCenter
                    text: tile.modelData.name
                    color: grid.currentIndex === tile.index ? Theme.primary : Theme.textDim
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: grid.currentIndex = tile.index
                    onClicked: picker.activate(tile.modelData)
                }
            }

            BarText {
                anchors.centerIn: parent
                visible: Wallpapers.online ? (!Wallpapers.searching && picker.shown.length === 0) : (!Wallpapers.loading && picker.shown.length === 0)
                text: Wallpapers.online ? "No results" : "No images in ~/wallpapers"
                color: Theme.textDim
            }
        }

        BarText {
            text: Wallpapers.online ? "Enter download + apply · / search · PgDn more · click filter: next, right click: back · W local · Esc close" : "Enter apply · D dark/light · R random · W wallhaven · Esc close"
            color: Theme.alpha(Theme.text, 0.45)
            font.pixelSize: 11
        }
    }
}
