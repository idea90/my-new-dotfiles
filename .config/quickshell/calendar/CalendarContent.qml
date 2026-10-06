import QtQuick
import qs
import qs.modules
import qs.services

// Month calendar (weeks start Monday). Arrows or scroll change month,
// clicking the title goes back to today.
Card {
    id: cal

    property date today: Time.now
    property int year: today.getFullYear()
    property int month: today.getMonth()

    // 42 cells starting on the Monday on/before the 1st
    readonly property var days: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() + 6) % 7;
        const cells = [];
        for (let i = 0; i < 42; i++)
            cells.push(new Date(year, month, 1 - offset + i));
        return cells;
    }

    function shift(step) {
        const d = new Date(year, month + step, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    implicitWidth: 300
    implicitHeight: column.implicitHeight + 28

    Connections {
        target: Panels
        function onOpenChanged() {
            if (Panels.open === "calendar") {
                cal.year = cal.today.getFullYear();
                cal.month = cal.today.getMonth();
            }
        }
    }

    WheelHandler {
        onWheel: event => cal.shift(event.angleDelta.y > 0 ? -1 : 1)
    }

    Column {
        id: column
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 8

        Item {
            width: parent.width
            height: 30

            Chip {
                anchors.left: parent.left
                implicitHeight: 30
                padding: 8
                icon: Theme.icon(0xf0141)
                onLeftClicked: cal.shift(-1)
            }
            BarText {
                anchors.centerIn: parent
                text: Qt.formatDate(new Date(cal.year, cal.month, 1), "MMMM yyyy")
                font.bold: true
                font.pixelSize: 15

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        cal.year = cal.today.getFullYear();
                        cal.month = cal.today.getMonth();
                    }
                }
            }
            Chip {
                anchors.right: parent.right
                implicitHeight: 30
                padding: 8
                icon: Theme.icon(0xf0142)
                onLeftClicked: cal.shift(1)
            }
        }

        Grid {
            columns: 7
            spacing: 2

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                BarText {
                    required property string modelData
                    width: 37
                    height: 24
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.pixelSize: 11
                    color: Theme.textDim
                }
            }

            Repeater {
                model: cal.days

                Rectangle {
                    id: day

                    required property var modelData
                    readonly property bool inMonth: modelData.getMonth() === cal.month
                    readonly property bool isToday: modelData.toDateString() === cal.today.toDateString()

                    width: 37
                    height: 32
                    radius: 16
                    color: isToday ? Theme.primary : "transparent"

                    BarText {
                        anchors.centerIn: parent
                        text: day.modelData.getDate()
                        font.pixelSize: 13
                        font.bold: day.isToday
                        color: day.isToday ? Theme.primaryFg
                             : day.inMonth ? Theme.text
                             : Theme.alpha(Theme.text, 0.3)
                    }
                }
            }
        }
    }
}
