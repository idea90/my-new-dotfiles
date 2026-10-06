import QtQuick
import QtQuick.Layouts
import qs
import qs.modules

// Everything inside the bar. Kept free of Quickshell window types so it can
// be previewed on its own.
Rectangle {
    id: content

    color: Theme.alpha(Theme.surfaceLow, 0.88)
    radius: Theme.radius
    border.width: 1
    border.color: Theme.alpha(Theme.outlineVariant, 0.7)

    RowLayout {
        id: left
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 5
        }
        spacing: 6

        Launcher {}
        Workspaces {}
        WindowTitle {
            // Stop before the centered clock
            Layout.maximumWidth: Math.max(0, content.width / 2 - center.width / 2 - x - 16)
        }
    }

    RowLayout {
        id: center
        anchors.centerIn: parent
        spacing: 6

        Clock {
            id: clock
        }
        NowPlaying {
            id: nowPlaying
            // Hide instead of running under the right-hand pills on narrow screens
            fits: content.width / 2 + (clock.implicitWidth + 6 + implicitWidth) / 2 + 8 < right.x
        }
    }

    RowLayout {
        id: right
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 5
        }
        spacing: 6

        Tray {}
        Hardware {}
        Status {}
        Actions {}
    }
}
