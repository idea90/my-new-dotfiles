import QtQuick
import qs
import qs.services

// Album art, title and a progress line. Click: play/pause. Scroll: next/previous.
Item {
    id: media

    property bool fits: true
    readonly property bool wanted: Media.available && fits
    implicitWidth: row.implicitWidth + 20
    implicitHeight: 30
    opacity: Media.playing ? 1 : 0.6

    Behavior on opacity {
        NumberAnimation { duration: Theme.dur(200) }
    }

    Row {
        id: row
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 4
        }
        spacing: 8

        // Round album art, or an app icon when there's none
        Rectangle {
            width: 26
            height: 26
            radius: 13
            color: Theme.tertiaryContainer
            clip: true

            Image {
                id: art
                anchors.fill: parent
                source: Media.art
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 64
                visible: status === Image.Ready
            }
            BarText {
                anchors.centerIn: parent
                visible: !art.visible
                text: Media.app.includes("spotify") ? Theme.icon(0xf04c7)
                    : Media.app.includes("firefox") ? Theme.icon(0xf0239)
                    : Theme.icon(0xf075a)
                color: Theme.tertiaryContainerFg
                font.pixelSize: 13
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            BarText {
                id: title
                text: (Media.playing ? "" : Theme.icon(0xf03e4) + " ")
                    + (Media.title.length > 22 ? Media.title.slice(0, 21) + "…" : Media.title)
                font.pixelSize: 12
                color: Theme.text
            }

            // Progress line
            Rectangle {
                width: Math.max(120, title.implicitWidth)
                height: 3
                radius: 2
                color: Theme.surfaceHighest

                Rectangle {
                    width: parent.width * Media.progress
                    height: parent.height
                    radius: 2
                    color: Theme.tertiary
                    Behavior on width {
                        NumberAnimation { duration: Theme.dur(900) }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Media.toggle()
        onWheel: event => event.angleDelta.y > 0 ? Media.next() : Media.previous()
    }
}
