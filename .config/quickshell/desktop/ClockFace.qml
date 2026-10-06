import QtQuick
import Quickshell
import qs
import qs.modules
import qs.services

// Big desktop clock: time, AM/PM, date and a greeting. Text has a dark
// "raised" shadow so it stays readable on bright wallpapers (plain text
// styling, so it also draws without GPU effects).
Item {
    id: face

    readonly property int hour: Time.now.getHours()
    readonly property string greeting: hour >= 5 && hour < 12 ? "Good morning"
        : hour >= 12 && hour < 18 ? "Good afternoon"
        : hour >= 18 && hour < 22 ? "Good evening" : "Good night"
    readonly property color shadow: Theme.alpha("#000000", 0.45)

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    Column {
        id: column
        spacing: 0

        Row {
            spacing: 12

            BarText {
                id: time
                // Qt only uses 12-hour time when AP is in the same format string
                text: Qt.formatDateTime(Time.now, "h:mm AP").replace(/\s*[AP]M$/i, "")
                font.pixelSize: 110
                font.weight: Font.Bold
                color: Theme.text
                style: Text.Raised
                styleColor: face.shadow
            }
            BarText {
                anchors.baseline: time.baseline
                text: Qt.formatDateTime(Time.now, "AP")
                font.pixelSize: 32
                font.weight: Font.Bold
                color: Theme.primary
                style: Text.Raised
                styleColor: face.shadow
            }
        }
        BarText {
            leftPadding: 6
            text: Qt.formatDateTime(Time.now, "dddd, d MMMM")
            font.pixelSize: 24
            color: Theme.primary
            style: Text.Raised
            styleColor: face.shadow
        }
        BarText {
            leftPadding: 6
            topPadding: 6
            text: face.greeting + ", " + Quickshell.env("USER")
            font.pixelSize: 16
            color: Theme.textDim
            style: Text.Raised
            styleColor: face.shadow
        }
    }
}
