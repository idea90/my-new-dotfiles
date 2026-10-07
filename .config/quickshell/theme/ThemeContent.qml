import QtQuick
import QtQuick.Layouts
import qs
import qs.modules
import qs.services

// Wallpaper grid with dark/light, scheme and random. Keys: arrows, Enter,
// D (dark/light), R (random), Esc. Wallhaven browsing is in Settings.
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

    readonly property var shown: Wallpapers.items

    function activate(item) {
        Wallpapers.apply(item.path);
        Panels.close();
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
                text: Wallpapers.loading ? "preparing thumbnails…" : Wallpapers.items.length + " images"
                color: Theme.textDim
                font.pixelSize: 12
            }
            Chip {
                icon: Theme.icon(0xf0ac)
                label: "Get more"
                bg: Theme.surfaceHigh
                // Wallhaven browsing lives in Settings → Wallpaper and widgets
                onLeftClicked: {
                    Panels.settingsTab = "";
                    Panels.settingsTab = "Wallpaper and widgets";
                    Panels.open = "settings";
                }
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

        // Color scheme chips
        Flow {
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
                        source: "file://" + tile.modelData.thumb
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 400
                    }

                    // Current wallpaper badge
                    Rectangle {
                        visible: tile.modelData.path === Wallpapers.current
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
                visible: !Wallpapers.loading && picker.shown.length === 0
                text: "No images in ~/wallpapers · Get more from Wallhaven"
                color: Theme.textDim
            }
        }

        BarText {
            text: "Enter apply · D dark/light · R random · Esc close"
            color: Theme.alpha(Theme.text, 0.45)
            font.pixelSize: 11
        }
    }
}
