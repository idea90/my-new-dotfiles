import QtQuick
import qs

// One floating island of the bar
Rectangle {
    id: island

    default property alias content: row.data
    property int padding: 4
    // Set from outside: an island can't tell from its children, because a
    // hidden island also hides them (and could then never come back)
    property bool shown: true

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: 38
    radius: 19
    color: Theme.alpha(Theme.surfaceLow, 0.92)
    border.width: 1
    border.color: Theme.alpha(Theme.outlineVariant, 0.8)
    visible: shown

    Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2
    }
}
