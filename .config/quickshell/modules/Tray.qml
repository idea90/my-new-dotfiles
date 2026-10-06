import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

// Left click: activate. Right click: the app's menu.
Pill {
    padding: 6

    Repeater {
        model: SystemTray.items

        Item {
            id: entry

            required property SystemTrayItem modelData

            width: 26
            height: Theme.pillHeight

            IconImage {
                anchors.centerIn: parent
                implicitSize: 16
                source: entry.modelData.icon
                mipmap: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: event => {
                    if (event.button === Qt.RightButton || entry.modelData.onlyMenu) {
                        if (entry.modelData.hasMenu) {
                            const pos = entry.mapToItem(null, 0, entry.height + 6);
                            entry.modelData.display(QsWindow.window, pos.x, pos.y);
                        }
                    } else {
                        entry.modelData.activate();
                    }
                }
            }
        }
    }
}
