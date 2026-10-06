import QtQuick
import qs

// Translucent card for desktop widgets
Rectangle {
    default property alias content: inner.data
    property int padding: 16

    implicitWidth: 300
    implicitHeight: inner.childrenRect.height + padding * 2
    radius: 20
    color: Theme.alpha(Theme.surfaceLow, 0.82)
    border.width: 1
    border.color: Theme.alpha(Theme.outlineVariant, 0.8)

    Item {
        id: inner
        anchors {
            fill: parent
            margins: parent.padding
        }
    }
}
