import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.modules
import qs.services

// Countdown card, then a thumbnail of the last shot with quick actions
PanelWindow {
    id: win

    readonly property bool counting: Shot.countdown > 0
    visible: counting || Shot.selecting || (Shot.previewShown && Shot.lastFile !== "")
    color: "transparent"

    anchors {
        top: Config.shotPreviewPosition.startsWith("top")
        bottom: Config.shotPreviewPosition.startsWith("bottom")
        left: Config.shotPreviewPosition.endsWith("left")
        right: Config.shotPreviewPosition.endsWith("right")
    }
    margins {
        top: 54
        bottom: 16
        left: 16
        right: 16
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Config.shotPreviewWidth
    implicitHeight: card.implicitHeight
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-screenshot-preview"

    Card {
        id: card
        width: parent.width
        implicitHeight: win.counting || Shot.selecting ? 96 : content.implicitHeight + 24

        Timer {
            id: hide
            interval: Config.shotPreviewSeconds * 1000
            running: Shot.previewShown && !win.counting && !hover.hovered && Config.shotPreviewSeconds > 0
            onTriggered: Shot.previewShown = false
        }
        HoverHandler {
            id: hover
        }

        Column {
            visible: Shot.selecting && !win.counting
            anchors.centerIn: parent
            spacing: 4
            BarText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Theme.icon(0xf0f28) + "  Drag to select an area"
                font.bold: true
            }
            BarText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "or click a window · Esc cancels"
                color: Theme.textDim
                font.pixelSize: 12
            }
        }

        BarText {
            visible: win.counting
            anchors.centerIn: parent
            text: Theme.icon(0xf051b) + "  Capturing in " + Shot.countdown
            font.pixelSize: 18
            font.bold: true
        }

        Column {
            id: content
            visible: !win.counting && !Shot.selecting
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 8

            Rectangle {
                width: parent.width
                height: width * 0.6
                radius: Math.max(0, Config.itemRadius - 2)
                color: Theme.surfaceMid
                clip: true

                Image {
                    anchors.fill: parent
                    source: Shot.lastFile !== "" ? "file://" + Shot.lastFile : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Shot.open();
                        Shot.previewShown = false;
                    }
                }
            }
            Row {
                spacing: 4
                Chip {
                    icon: Theme.icon(0xf018f)
                    bg: Theme.surfaceHigh
                    onLeftClicked: Shot.copy()
                }
                Chip {
                    icon: Theme.icon(0xf0770)
                    bg: Theme.surfaceHigh
                    onLeftClicked: Shot.showInFolder()
                }
                Chip {
                    icon: Theme.icon(0xf01b4)
                    bg: Theme.surfaceHigh
                    hoverBg: Theme.error
                    hoverFg: Theme.errorFg
                    onLeftClicked: Shot.discard()
                }
                Chip {
                    icon: Theme.icon(0xf0156)
                    bg: Theme.surfaceHigh
                    onLeftClicked: Shot.previewShown = false
                }
            }
        }
    }
}
