import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs
import qs.modules
import qs.services

// Launcher UI: dimmed backdrop, search field, app list.
// Keys: type to search, Up/Down (or Ctrl+J/K, Tab) to move, Enter to launch, Esc to close.
Item {
    id: root

    property var entries: []
    readonly property var results: AppMenu.search(entries, search.text)

    // Reset every time it opens
    Connections {
        target: AppMenu
        function onOpenChanged() {
            if (AppMenu.open) {
                search.text = "";
                list.currentIndex = 0;
                search.forceActiveFocus();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", Config.launcherDim)

        MouseArea {
            anchors.fill: parent
            onClicked: AppMenu.open = false
        }
    }

    Rectangle {
        id: card

        width: Config.launcherWidth
        height: column.implicitHeight + 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * Config.launcherTop
        radius: Config.launcherRadius
        color: Theme.panelFill
        border.width: Config.panelBorder
        border.color: Theme.panelBorderFill

        // Swallow clicks so they don't close the launcher
        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: column
            anchors {
                fill: parent
                margins: 14
            }
            spacing: 10

            // Search field
            Rectangle {
                width: parent.width
                height: Config.launcherSearchHeight
                radius: Theme.pillRadius
                color: Theme.surfaceHigh

                BarText {
                    id: searchIcon
                    anchors {
                        left: parent.left
                        leftMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    text: Theme.icon(0xf0349)
                    color: Theme.primary
                    font.pixelSize: 18
                }

                TextField {
                    id: search
                    anchors {
                        left: searchIcon.right
                        right: Config.launcherCounter ? counter.left : parent.right
                        leftMargin: 10
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    background: null
                    color: Theme.text
                    placeholderText: Config.launcherPlaceholder
                    placeholderTextColor: Theme.alpha(Theme.text, 0.45)
                    selectionColor: Theme.primary
                    selectedTextColor: Theme.primaryFg
                    font.family: Theme.font
                    font.pixelSize: 15
                    onTextChanged: list.currentIndex = 0

                    Keys.onPressed: event => {
                        const ctrl = event.modifiers & Qt.ControlModifier;
                        if (event.key === Qt.Key_Escape) {
                            AppMenu.open = false;
                        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || (ctrl && event.key === Qt.Key_J)) {
                            list.incrementCurrentIndex();
                        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || (ctrl && event.key === Qt.Key_K)) {
                            list.decrementCurrentIndex();
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.results.length > 0)
                                AppMenu.launch(root.results[list.currentIndex]);
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }

                BarText {
                    id: counter
                    visible: Config.launcherCounter
                    anchors {
                        right: parent.right
                        rightMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    text: root.results.length + " / " + root.entries.filter(e => !e.noDisplay).length
                    color: Theme.alpha(Theme.text, 0.45)
                    font.pixelSize: 12
                }
            }

            ListView {
                id: list

                width: parent.width
                height: Math.min(contentHeight, Config.launcherRows * (Config.launcherRowHeight + 2))
                clip: true
                spacing: 2
                model: root.results
                highlightMoveDuration: 120
                boundsBehavior: Flickable.StopAtBounds
                visible: list.count > 0

                highlight: Rectangle {
                    radius: Theme.innerRadius + 2
                    color: Theme.primaryContainer
                }

                delegate: Item {
                    id: row

                    required property var modelData
                    required property int index
                    readonly property bool selected: ListView.isCurrentItem

                    width: list.width
                    height: Config.launcherRowHeight

                    IconImage {
                        id: appIcon
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        implicitSize: Config.launcherIconSize
                        source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                        mipmap: true
                    }

                    Column {
                        anchors {
                            left: appIcon.right
                            right: parent.right
                            leftMargin: 12
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 1

                        BarText {
                            width: parent.width
                            text: row.modelData.name
                            color: row.selected ? Theme.primaryContainerFg : Theme.text
                            elide: Text.ElideRight
                        }
                        BarText {
                            width: parent.width
                            visible: Config.launcherDescriptions && text !== ""
                            text: row.modelData.genericName || row.modelData.comment
                            color: row.selected ? Theme.alpha(Theme.primaryContainerFg, 0.7) : Theme.textDim
                            font.pixelSize: 11
                            font.weight: Font.Normal
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = row.index
                        onClicked: AppMenu.launch(row.modelData)
                    }
                }
            }

            BarText {
                visible: root.results.length === 0
                width: parent.width
                height: 40
                horizontalAlignment: Text.AlignHCenter
                text: "No apps match \"" + search.text + "\""
                color: Theme.textDim
            }
        }
    }
}
