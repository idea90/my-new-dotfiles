import QtQuick
import qs
import qs.modules
import qs.services

// Album art, title, artist, progress and controls
WidgetCard {
    visible: Media.available

    Row {
        width: parent.width
        spacing: 14

        Rectangle {
            width: 76
            height: 76
            radius: 12
            color: Theme.tertiaryContainer
            clip: true

            Image {
                id: art
                anchors.fill: parent
                source: Media.art
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 160
                visible: status === Image.Ready
            }
            BarText {
                anchors.centerIn: parent
                visible: !art.visible
                text: Theme.icon(0xf075a)
                font.pixelSize: 30
                color: Theme.tertiaryContainerFg
            }
        }

        Column {
            width: parent.width - 90
            spacing: 4

            BarText {
                width: parent.width
                text: Media.title
                font.bold: true
                elide: Text.ElideRight
            }
            BarText {
                width: parent.width
                text: Media.artist
                font.pixelSize: 12
                color: Theme.textDim
                elide: Text.ElideRight
            }

            Rectangle {
                width: parent.width
                height: 4
                radius: 2
                color: Theme.surfaceHighest

                Rectangle {
                    width: parent.width * Media.progress
                    height: parent.height
                    radius: 2
                    color: Theme.tertiary
                    Behavior on width {
                        NumberAnimation { duration: 900 }
                    }
                }
            }

            Row {
                spacing: 2
                Chip {
                    implicitHeight: 28
                    icon: Theme.icon(0xf04ae)
                    onLeftClicked: Media.previous()
                }
                Chip {
                    implicitHeight: 28
                    icon: Media.playing ? Theme.icon(0xf03e4) : Theme.icon(0xf040a)
                    fg: Theme.primary
                    onLeftClicked: Media.toggle()
                }
                Chip {
                    implicitHeight: 28
                    icon: Theme.icon(0xf04ad)
                    onLeftClicked: Media.next()
                }
            }
        }
    }
}
