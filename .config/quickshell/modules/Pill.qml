import QtQuick
import qs

// Rounded group background; children go in a row
Rectangle {
    id: pill

    default property alias content: row.data
    property int padding: 2

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.surfaceHigh
    visible: row.visibleChildren.length > 0

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 0
    }
}
