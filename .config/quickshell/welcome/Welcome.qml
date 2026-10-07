import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.modules
import qs.services

// First-run tour: shown once (until ~/.cache/quickshell/welcomed exists).
// `qs ipc call welcome start` brings it back.
PanelWindow {
    id: win

    property bool open: false
    property int page: 0

    readonly property var pages: [
        { icon: 0xf03d8, title: "Welcome to Kaleido", body: "Your desktop takes its colors from the wallpaper. Everything here can be restyled, and it all saves by itself.", keys: [["Super + W", "pick a wallpaper and colors"], ["Super + I", "settings, styles and looks"]] },
        { icon: 0xf0349, title: "Open things", body: "Apps, files and quick math are one shortcut away.", keys: [["Super + D", "app launcher (try typing 2+2)"], ["Super + T", "terminal"], ["Super + V", "clipboard history"], ["Super + .", "emoji"]] },
        { icon: 0xf0570, title: "Move around", body: "Windows and workspaces, without the mouse.", keys: [["Alt + Tab", "switch windows"], ["Super + Tab", "overview of every workspace"], ["Super + 1 to 0", "go to a workspace"], ["Super + Q", "close a window"]] },
        { icon: 0xf0493, title: "Your desktop", body: "Quick toggles, screenshots and the power menu.", keys: [["Super + N", "control center"], ["Print", "screenshot (Super + K for the toolbar)"], ["Super + B", "hide or show the bar"], ["Super + Esc", "lock, log out, shut down"]] }
    ]

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
    WlrLayershell.namespace: "qs-powermenu"

    function finish() {
        open = false;
        doneFile.setText("1");
    }

    // Show once on first start
    FileView {
        id: doneFile
        path: Quickshell.env("HOME") + "/.cache/quickshell/welcomed"
        printErrors: false
        onLoadFailed: firstRun.start()
    }
    Timer {
        id: firstRun
        interval: 2500
        onTriggered: {
            win.page = 0;
            win.open = true;
        }
    }

    IpcHandler {
        target: "welcome"
        function start(): void {
            win.page = 0;
            win.open = true;
        }
    }

    onOpenChanged: if (open) keys.forceActiveFocus()

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", 0.35)
    }

    Item {
        id: keys
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape)
                win.finish();
            else if (event.key === Qt.Key_Right || event.key === Qt.Key_Return || event.key === Qt.Key_Space)
                win.page < win.pages.length - 1 ? win.page++ : win.finish();
            else if (event.key === Qt.Key_Left)
                win.page = Math.max(0, win.page - 1);
            else
                return;
            event.accepted = true;
        }
    }

    Card {
        anchors.centerIn: parent
        width: 520
        height: 400

        ColumnLayout {
            anchors {
                fill: parent
                margins: 28
            }
            spacing: 14

            BarText {
                text: Theme.icon(win.pages[win.page].icon)
                font.pixelSize: 40
                color: Theme.primary
            }
            BarText {
                text: win.pages[win.page].title
                font.pixelSize: 24
                font.bold: true
            }
            BarText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: win.pages[win.page].body
                color: Theme.textDim
            }
            GridLayout {
                columns: 2
                rowSpacing: 8
                columnSpacing: 14
                Repeater {
                    model: win.pages[win.page].keys.reduce((a, k) => a.concat([k[0], k[1]]), [])
                    delegate: Rectangle {
                        required property string modelData
                        required property int index
                        readonly property bool isKey: index % 2 === 0
                        implicitWidth: isKey ? keyText.implicitWidth + 18 : keyText.implicitWidth
                        implicitHeight: 28
                        radius: Theme.innerRadius
                        color: isKey ? Theme.surfaceHigh : "transparent"
                        border.width: isKey ? 1 : 0
                        border.color: Theme.outlineVariant
                        BarText {
                            id: keyText
                            anchors.centerIn: parent
                            text: modelData
                            font.bold: parent.isKey
                            font.pixelSize: 13
                            color: parent.isKey ? Theme.primary : Theme.text
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
            }
            RowLayout {
                Layout.fillWidth: true
                Row {
                    spacing: 6
                    Repeater {
                        model: win.pages.length
                        delegate: Rectangle {
                            required property int index
                            width: index === win.page ? 22 : 8
                            height: 8
                            radius: 4
                            color: index === win.page ? Theme.primary : Theme.surfaceHighest
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                Chip {
                    label: "Skip"
                    onLeftClicked: win.finish()
                }
                Chip {
                    label: win.page < win.pages.length - 1 ? "Next" : "Let's go"
                    bg: Theme.primary
                    fg: Theme.primaryFg
                    hoverBg: Theme.alpha(Theme.primary, 0.85)
                    onLeftClicked: win.page < win.pages.length - 1 ? win.page++ : win.finish()
                }
            }
        }
    }
}
