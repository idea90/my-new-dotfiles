import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs
import qs.modules
import qs.services

// Super+V: searchable clipboard history. Enter or click pastes, Delete removes.
PanelWindow {
    id: win

    visible: Clipboard.open
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "qs-launcher"

    property string query: ""
    readonly property var shown: Clipboard.items.filter(i => query === "" || i.text.toLowerCase().includes(query.toLowerCase()))

    onVisibleChanged: {
        if (visible) {
            search.text = "";
            list.currentIndex = 0;
            search.forceActiveFocus();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", 0.25)
        MouseArea {
            anchors.fill: parent
            onClicked: Clipboard.open = false
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.14
        width: 560
        height: Math.min(parent.height * 0.7, col.implicitHeight + 28)
        radius: Config.launcherRadius
        color: Theme.alpha(Theme.byName(Config.panelColor, Theme.surfaceLow), Math.max(0.75, Config.launcherOpacity))
        border.width: Config.panelBorder
        border.color: Theme.panelBorderFill

        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: col
            anchors {
                fill: parent
                margins: 14
            }
            spacing: 10

            Rectangle {
                width: parent.width
                height: 44
                radius: Theme.pillRadius
                color: Theme.surfaceHigh

                BarText {
                    id: icon
                    anchors {
                        left: parent.left
                        leftMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    text: Theme.icon(0xf014d)
                    color: Theme.primary
                    font.pixelSize: 18
                }
                TextField {
                    id: search
                    anchors {
                        left: icon.right
                        right: clearBtn.left
                        leftMargin: 10
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    background: null
                    color: Theme.text
                    placeholderText: "Search clipboard"
                    placeholderTextColor: Theme.alpha(Theme.text, 0.45)
                    font.family: Theme.font
                    font.pixelSize: 15
                    onTextChanged: {
                        win.query = text;
                        list.currentIndex = 0;
                    }
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape)
                            Clipboard.open = false;
                        else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab)
                            list.incrementCurrentIndex();
                        else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab)
                            list.decrementCurrentIndex();
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (win.shown.length > 0)
                                Clipboard.pick(win.shown[list.currentIndex]);
                        } else if (event.key === Qt.Key_Delete) {
                            if (win.shown.length > 0)
                                Clipboard.remove(win.shown[list.currentIndex]);
                        } else
                            return;
                        event.accepted = true;
                    }
                }
                Chip {
                    id: clearBtn
                    anchors {
                        right: parent.right
                        rightMargin: 6
                        verticalCenter: parent.verticalCenter
                    }
                    label: "Clear all"
                    hoverBg: Theme.error
                    hoverFg: Theme.errorFg
                    onLeftClicked: Clipboard.clear()
                }
            }

            ListView {
                id: list
                width: parent.width
                height: Math.min(contentHeight, 440)
                clip: true
                spacing: 4
                model: win.shown
                highlightMoveDuration: 100
                boundsBehavior: Flickable.StopAtBounds
                highlight: Rectangle {
                    radius: Theme.innerRadius + 2
                    color: Theme.primaryContainer
                }

                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: ListView.isCurrentItem
                    width: list.width
                    height: modelData.image !== "" ? 92 : 40

                    Image {
                        visible: row.modelData.image !== ""
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        height: 80
                        width: 140
                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Image.AlignLeft
                        source: row.modelData.image !== "" ? "file://" + row.modelData.image : ""
                        sourceSize.height: 160
                        asynchronous: true
                        cache: false
                    }
                    BarText {
                        visible: row.modelData.image === ""
                        anchors {
                            left: parent.left
                            right: parent.right
                            leftMargin: 14
                            rightMargin: 14
                            verticalCenter: parent.verticalCenter
                        }
                        text: row.modelData.text.replace(/\s+/g, " ")
                        elide: Text.ElideRight
                        color: row.sel ? Theme.primaryContainerFg : Theme.text
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onEntered: list.currentIndex = row.index
                        onClicked: event => event.button === Qt.RightButton ? Clipboard.remove(row.modelData) : Clipboard.pick(row.modelData)
                    }
                }
            }

            BarText {
                visible: win.shown.length === 0
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: Clipboard.items.length === 0 ? "Nothing copied yet" : "No matches"
                color: Theme.textDim
            }
            BarText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Enter pastes · Delete or right-click removes · Esc closes"
                color: Theme.alpha(Theme.textDim, 0.8)
                font.pixelSize: 11
            }
        }
    }
}
