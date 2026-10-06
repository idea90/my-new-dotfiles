import QtQuick
import QtQuick.Layouts
import qs
import qs.modules
import qs.services

// Three floating islands over the wallpaper: left, center, right
Item {
    id: content

    RowLayout {
        id: left
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        Island {
            Launcher {}
            Workspaces {}
        }
        Island {
            shown: Hypr.title !== ""
            padding: 14
            Layout.maximumWidth: Math.max(0, center.x - left.x - x - 16)
            WindowTitle {
                width: Math.min(implicitWidth, parent.parent.Layout.maximumWidth - 28)
            }
        }
    }

    RowLayout {
        id: center
        anchors.centerIn: parent
        spacing: 8

        Island {
            id: clockIsland
            Clock {}
        }
        Island {
            shown: nowPlaying.wanted
            NowPlaying {
                id: nowPlaying
                // Hide instead of running under the right island on narrow screens
                fits: content.width / 2 + (clockIsland.implicitWidth + 8 + implicitWidth) / 2 + 8 < right.x
            }
        }
    }

    RowLayout {
        id: right
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        Island {
            shown: tray.hasItems
            Tray {
                id: tray
            }
        }
        Island {
            Status {}
        }
        Island {
            Actions {}
        }
    }
}
