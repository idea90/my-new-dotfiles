import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.modules
import qs.services

// Super+. : search emoji by name, Enter or click types it into the focused
// window (and copies it). Arrows move, Esc closes. `qs ipc call emoji toggle`
PanelWindow {
    id: win

    property bool open: false
    property var all: []        // [char, name, category]
    property string query: ""
    property string category: "all"
    property int index: 0
    property var recent: []
    readonly property var cats: ["all", "recent", "smileys", "people & nature", "objects", "travel", "more", "symbols"]

    readonly property var shown: {
        const q = query.trim().toLowerCase();
        if (category === "recent" && q === "")
            return recent.map(c => all.find(e => e[0] === c)).filter(e => !!e);
        return all.filter(e => (category === "all" || category === "recent" || e[2] === category)
                          && (q === "" || e[1].includes(q)));
    }
    readonly property int cols: 10

    visible: open
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "qs-launcher"

    onOpenChanged: {
        if (open) {
            search.text = "";
            index = 0;
            search.forceActiveFocus();
        }
    }

    function pick(e) {
        if (!e)
            return;
        open = false;
        recent = [e[0]].concat(recent.filter(c => c !== e[0])).slice(0, 30);
        recentFile.setText(JSON.stringify(recent));
        Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | wl-copy; sleep 0.15; wtype "$1"', "sh", e[0]]);
    }

    FileView {
        path: Quickshell.shellDir + "/emoji/emoji.json"
        onLoaded: win.all = JSON.parse(text())
    }
    FileView {
        id: recentFile
        printErrors: false
        path: Quickshell.env("HOME") + "/.cache/quickshell/emoji-recent.json"
        onLoaded: {
            try {
                win.recent = JSON.parse(text());
            } catch (e) {}
        }
    }

    IpcHandler {
        target: "emoji"
        function toggle(): void {
            win.open = !win.open;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", 0.25)
        MouseArea {
            anchors.fill: parent
            onClicked: win.open = false
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.14
        width: 560
        height: col.implicitHeight + 28
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
                left: parent.left
                right: parent.right
                top: parent.top
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
                    text: Theme.icon(0xf0785)
                    color: Theme.primary
                    font.pixelSize: 18
                }
                TextField {
                    id: search
                    anchors {
                        left: icon.right
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    background: null
                    color: Theme.text
                    placeholderText: "Search emoji"
                    placeholderTextColor: Theme.alpha(Theme.text, 0.45)
                    font.family: Theme.font
                    font.pixelSize: 15
                    onTextChanged: {
                        win.query = text;
                        win.index = 0;
                    }
                    Keys.onPressed: event => {
                        const k = event.key;
                        const n = win.shown.length;
                        if (k === Qt.Key_Escape)
                            win.open = false;
                        else if (k === Qt.Key_Return || k === Qt.Key_Enter)
                            win.pick(win.shown[win.index]);
                        else if (k === Qt.Key_Right || k === Qt.Key_Tab)
                            win.index = Math.min(n - 1, win.index + 1);
                        else if (k === Qt.Key_Left || k === Qt.Key_Backtab)
                            win.index = Math.max(0, win.index - 1);
                        else if (k === Qt.Key_Down)
                            win.index = Math.min(n - 1, win.index + win.cols);
                        else if (k === Qt.Key_Up)
                            win.index = Math.max(0, win.index - win.cols);
                        else
                            return;
                        event.accepted = true;
                        grid.positionViewAtIndex(win.index, GridView.Contain);
                    }
                }
            }

            Flow {
                width: parent.width
                spacing: 4
                Repeater {
                    model: win.cats
                    delegate: Chip {
                        required property string modelData
                        label: modelData
                        bg: win.category === modelData ? Theme.primary : Theme.surfaceHigh
                        fg: win.category === modelData ? Theme.primaryFg : Theme.text
                        hoverBg: win.category === modelData ? Theme.primary : Theme.surfaceHighest
                        onLeftClicked: {
                            win.category = modelData;
                            win.index = 0;
                            search.forceActiveFocus();
                        }
                    }
                }
            }

            GridView {
                id: grid
                width: parent.width
                height: 6 * cellHeight
                cellWidth: width / win.cols
                cellHeight: 52
                clip: true
                model: win.shown
                boundsBehavior: Flickable.StopAtBounds
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: grid.cellWidth - 4
                    height: grid.cellHeight - 4
                    radius: Config.itemRadius
                    color: index === win.index ? Theme.primaryContainer : cellMouse.containsMouse ? Theme.surfaceHigh : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: modelData[0]
                        font.family: "Noto Color Emoji"
                        font.pixelSize: 28
                    }
                    MouseArea {
                        id: cellMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: win.index = index
                        onClicked: win.pick(modelData)
                    }
                }
            }

            BarText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: win.shown.length === 0 ? "No emoji match" : (win.shown[win.index] ? win.shown[win.index][1] : "")
                color: Theme.textDim
                font.pixelSize: 12
            }
        }
    }
}
