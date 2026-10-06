import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Full-screen message between choosing a power action and running it
Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData

        visible: Goodbye.showing || fade.opacity > 0
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: Goodbye.showing ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.namespace: Config.powerBlur ? "qs-powermenu" : "quickshell-goodbye"

        Item {
            id: fade
            anchors.fill: parent
            opacity: Goodbye.showing ? 1 : 0
            focus: true
            Keys.onPressed: Goodbye.cancel()

            Behavior on opacity {
                NumberAnimation { duration: Theme.dur(350); easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.alpha("#000000", 0.72)
            }
            MouseArea {
                anchors.fill: parent
                onClicked: Goodbye.cancel()
            }

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Goodbye.icon
                    font.family: Theme.font
                    font.pixelSize: 64
                    color: Theme.primary
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Goodbye.message
                    font.family: Theme.font
                    font.pixelSize: 34
                    font.bold: true
                    color: Theme.text
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Press any key to cancel"
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: Theme.textDim
                }
            }

            onVisibleChanged: if (visible) forceActiveFocus()
        }
    }
}
