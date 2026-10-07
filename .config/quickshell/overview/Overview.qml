import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import qs
import qs.modules
import qs.services

// Super+Tab: every workspace with live previews of its windows.
// Click a window to focus it, click a workspace to go there; Esc closes.
// Drag a window onto another workspace to move it there.
PanelWindow {
    id: win

    property bool open: false
    readonly property real sw: screen ? screen.width : 1366
    readonly property real sh: screen ? screen.height : 768
    // Workspaces 1..max(5, highest used)
    readonly property var ids: Hypr.ids
    readonly property int cols: Math.min(5, Math.max(3, Math.ceil(ids.length / 2)))
    readonly property real cellW: (width - 120 - (cols - 1) * 18) / cols
    readonly property real cellH: cellW * sh / sw
    readonly property real scale: cellW / sw

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

    onOpenChanged: {
        if (open) {
            Hyprland.refreshToplevels();
            keys.forceActiveFocus();
        }
    }

    function windowsOn(id) {
        return Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === id && t.lastIpcObject && t.lastIpcObject.at);
    }

    IpcHandler {
        target: "overview"
        function toggle(): void {
            win.open = !win.open;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", 0.35)
        MouseArea {
            anchors.fill: parent
            onClicked: win.open = false
        }
    }

    Item {
        id: keys
        focus: true
        Keys.onEscapePressed: win.open = false
        Keys.onPressed: event => {
            // 1..9 jump to that workspace
            const n = parseInt(event.text);
            if (n >= 1 && n <= 9) {
                Hypr.focus(n);
                win.open = false;
                event.accepted = true;
            }
        }
    }

    Grid {
        anchors.centerIn: parent
        columns: win.cols
        spacing: 18

        Repeater {
            model: win.open ? win.ids : []

            delegate: Column {
                id: wsCol
                required property int modelData
                readonly property bool focused: modelData === Hypr.focusedId
                spacing: 6

                Rectangle {
                    id: frame
                    width: win.cellW
                    height: win.cellH
                    radius: Config.itemRadius + 4
                    clip: true
                    color: Theme.alpha(Theme.surfaceLow, 0.75)
                    border.width: wsCol.focused || dropArea.containsDrag ? 2 : 1
                    border.color: wsCol.focused || dropArea.containsDrag ? Theme.primary : Theme.alpha(Theme.outlineVariant, 0.9)

                    // Workspace background: the wallpaper, small
                    Image {
                        anchors.fill: parent
                        source: "file://" + Quickshell.env("HOME") + "/.cache/lockscreen.png?" + Wallpapers.imageRev
                        sourceSize.width: 320
                        fillMode: Image.PreserveAspectCrop
                        opacity: 0.55
                        asynchronous: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Hypr.focus(wsCol.modelData);
                            win.open = false;
                        }
                    }

                    DropArea {
                        id: dropArea
                        anchors.fill: parent
                        onDropped: drop => {
                            Hyprland.dispatch('hl.dsp.window.move({ workspace = ' + wsCol.modelData + ', follow = false, window = "address:0x'
                                + drop.source.address + '" })');
                            Hyprland.refreshToplevels();
                        }
                    }

                    Repeater {
                        model: win.windowsOn(wsCol.modelData)

                        delegate: Rectangle {
                            id: tile
                            required property var modelData
                            readonly property var o: modelData.lastIpcObject
                            readonly property string address: modelData.address
                            readonly property real ox: (o.at[0] - (o.monitor !== undefined ? 0 : 0)) * win.scale
                            x: ox
                            y: o.at[1] * win.scale
                            width: Math.max(24, o.size[0] * win.scale)
                            height: Math.max(18, o.size[1] * win.scale)
                            radius: 6
                            clip: true
                            color: Theme.surfaceHigh
                            border.width: tileMouse.containsMouse ? 2 : 1
                            border.color: tileMouse.containsMouse ? Theme.primary : Theme.alpha(Theme.outline, 0.6)

                            Drag.active: tileMouse.drag.active
                            Drag.source: tile
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2

                            ScreencopyView {
                                id: shot
                                anchors.fill: parent
                                captureSource: tile.modelData.wayland
                                live: false
                                constraintSize: Qt.size(tile.width * 2, tile.height * 2)
                            }
                            IconImage {
                                visible: !shot.hasContent
                                anchors.centerIn: parent
                                implicitSize: Math.min(36, parent.height * 0.6)
                                source: {
                                    const cls = tile.o["class"] || "";
                                    const entry = DesktopEntries.heuristicLookup(cls);
                                    return Quickshell.iconPath(entry ? entry.icon : cls.toLowerCase(), "application-x-executable");
                                }
                            }

                            MouseArea {
                                id: tileMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                drag.target: tile
                                onReleased: {
                                    if (tile.Drag.active)
                                        tile.Drag.drop();
                                    // snap back; the window moves for real if it was dropped on a workspace
                                    tile.x = Qt.binding(() => tile.ox);
                                    tile.y = Qt.binding(() => tile.o.at[1] * win.scale);
                                }
                                onClicked: {
                                    Hypr.focusWindow(tile.address);
                                    win.open = false;
                                }
                            }
                        }
                    }
                }

                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (wsCol.focused ? "● " : "") + "Workspace " + wsCol.modelData
                        + (win.windowsOn(wsCol.modelData).length ? "  ·  " + win.windowsOn(wsCol.modelData).length : "")
                    color: wsCol.focused ? Theme.primary : Qt.rgba(1, 1, 1, 0.85)
                    font.pixelSize: 12
                    font.bold: wsCol.focused
                }
            }
        }
    }
}
