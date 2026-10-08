import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

// Left click: activate. Right click: the app's menu.
Grid {
    // a row on a top/bottom bar, a column on a side bar
    columns: Theme.vertical ? 1 : 100
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter
    readonly property bool hasItems: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Item {
            id: entry

            required property SystemTrayItem modelData

            width: 26
            height: Theme.barItem

            IconImage {
                anchors.centerIn: parent
                implicitSize: 16
                source: entry.modelData.icon
                mipmap: true
                // light themes: white symbolic icons would vanish, so draw them in the text color
                layer.enabled: Theme.isLight
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: Theme.text
                }
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
