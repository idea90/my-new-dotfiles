import QtQuick
import qs
import qs.modules

// A style preset as a small picture plus its name. `vals` holds the preset's merged
// settings; `kind` picks how it is drawn: "bar", "look" or "launcher".
Item {
    id: card

    property string kind: "bar"
    property string name: ""
    property var vals: ({})
    property bool selected: false
    signal picked

    implicitWidth: 152
    implicitHeight: 104

    function c(key, fallback) {
        return Theme.byName(vals[key], fallback);
    }

    Rectangle {
        id: frame
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 82
        radius: 10
        clip: true
        border.width: card.selected ? 2 : 1
        border.color: card.selected ? Theme.primary : mouse.containsMouse ? Theme.alpha(Theme.text, 0.35) : Theme.alpha(Theme.outlineVariant, 0.9)

        // Stand-in wallpaper
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.alpha(Theme.primaryContainer, 0.9) }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.tertiaryContainer, 0.9) }
        }

        Loader {
            anchors.fill: parent
            sourceComponent: card.kind === "launcher" ? launcherPreview
                : card.kind === "cc" ? ccPreview
                : card.kind === "power" ? powerPreview
                : card.kind === "lock" ? lockPreview
                : card.kind === "island" ? islandPreview
                : card.kind === "look" ? lookPreview : barPreview
        }

        Rectangle {
            visible: card.selected
            anchors {
                top: parent.top
                right: parent.right
                margins: 6
            }
            width: 16
            height: 16
            radius: 8
            color: Theme.primary
            BarText {
                anchors.centerIn: parent
                text: Theme.icon(0xf012c)
                font.pixelSize: 10
                color: Theme.primaryFg
            }
        }
    }

    BarText {
        anchors {
            top: frame.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        text: card.name
        font.pixelSize: 12
        font.bold: card.selected
        color: card.selected ? Theme.primary : Theme.text
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.picked()
    }

    // ---- a miniature bar ----------------------------------------------------
    component MiniBar: Item {
        property var v: card.vals
        readonly property string bg: v.barBackground ?? "islands"
        readonly property real scale: 0.42
        readonly property real barH: Math.max(12, (v.barHeight ?? 38) * scale)
        readonly property real islandH: bg === "band" ? Math.max(8, barH - 6) : barH - 2
        readonly property color islandColor: Theme.alpha(Theme.byName(v.barColor, Theme.surfaceLow), v.islandOpacity ?? 0.92)

        height: barH
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 6
            rightMargin: 6
        }
        y: (v.barPosition ?? "top") === "bottom" ? parent.height - height - 6 : 6

        Rectangle {
            visible: bg === "band" || bg === "solid"
            anchors.fill: parent
            radius: Math.min(6, (v.barRadius ?? 8) / 3)
            color: bg === "band" ? Theme.alpha(Theme.byName(v.bandColor, Theme.surfaceLow), v.bandOpacity ?? 0.5) : islandColor
        }

        // Three islands: left, center, right
        Repeater {
            model: [
                { x: 0.0, w: 34 },
                { x: 0.5, w: 30 },
                { x: 1.0, w: 40 }
            ]
            delegate: Rectangle {
                required property var modelData
                visible: bg === "islands" || bg === "band"
                width: modelData.w
                height: islandH
                anchors.verticalCenter: parent.verticalCenter
                x: modelData.x === 0 ? (bg === "band" ? 3 : 0)
                   : modelData.x === 0.5 ? (parent.width - width) / 2
                   : parent.width - width - (bg === "band" ? 3 : 0)
                radius: Math.min((v.islandRadius ?? 19) * scale, height / 2)
                color: islandColor
                border.width: (v.islandBorder ?? 0) > 0 ? 1 : 0
                border.color: Theme.alpha(Theme.byName(v.borderColor, Theme.outlineVariant), 0.9)

                Rectangle {
                    width: parent.width * 0.5
                    height: 3
                    radius: 2
                    anchors.centerIn: parent
                    color: Theme.alpha(Theme.text, 0.6)
                }
            }
        }

        // Plain / transparent bar: just text-like marks
        Repeater {
            model: [0.08, 0.5, 0.86]
            delegate: Rectangle {
                required property real modelData
                visible: bg === "none" || bg === "solid"
                width: 24
                height: 3
                radius: 2
                x: parent.width * modelData - (modelData > 0.4 ? width / 2 : 0)
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.alpha(Theme.text, 0.75)
            }
        }
    }

    Component {
        id: barPreview
        Item {
            MiniBar {}
        }
    }

    // ---- a look: bar on top plus a panel -----------------------------------
    Component {
        id: lookPreview
        Item {
            MiniBar {}
            Rectangle {
                width: 62
                height: 44
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 8
                }
                radius: Math.min(10, (card.vals.panelRadius ?? 14) / 2.2)
                color: Theme.alpha(Theme.byName(card.vals.panelColor, Theme.surfaceLow), Math.max(0.5, card.vals.panelOpacity ?? 1))
                border.width: card.vals.panelBorder ?? 1
                border.color: Theme.byName(card.vals.panelBorderColor, Theme.outlineVariant)

                Row {
                    anchors {
                        left: parent.left
                        top: parent.top
                        margins: 7
                    }
                    spacing: 4
                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            required property int index
                            width: 13
                            height: 11
                            radius: Math.min(4, (card.vals.itemRadius ?? 12) / 3)
                            color: index === 0 ? Theme.primary : Theme.alpha(Theme.text, 0.2)
                        }
                    }
                }
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: 7
                    }
                    height: 6
                    radius: 3
                    color: Theme.alpha(Theme.text, 0.25)
                }
            }
        }
    }

    // ---- a launcher: windowed card or full-screen grid ---------------------
    Component {
        id: launcherPreview
        Item {
            readonly property var v: card.vals
            readonly property bool fs: v.launcherFullscreen ?? false

            Rectangle {
                anchors.fill: parent
                color: Theme.alpha("#000000", fs ? 0.45 : 0.25)
            }

            // Full-screen: search pill and a grid of icons
            Item {
                visible: fs
                anchors.fill: parent
                Rectangle {
                    width: 46
                    height: 8
                    radius: 4
                    anchors {
                        top: parent.top
                        topMargin: 8
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: Theme.alpha(Theme.text, 0.35)
                }
                Grid {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: 22
                    }
                    columns: Math.min(8, v.launcherFsColumns ?? 7)
                    spacing: 5
                    Repeater {
                        model: Math.min(8, v.launcherFsColumns ?? 7) * Math.min(4, v.launcherFsRows ?? 4)
                        delegate: Rectangle {
                            width: Math.max(7, (v.launcherFsIcon ?? 64) / 9)
                            height: width
                            radius: width / 3.2
                            color: Theme.alpha(Theme.text, 0.55)
                        }
                    }
                }
            }

            // Windowed: card with optional side image and list or grid
            Rectangle {
                visible: !fs
                width: Math.min(parent.width - 14, (v.launcherWidth ?? 560) / 560 * 78 + (v.launcherSideImage ? 26 : 0))
                height: Math.min(parent.height - 12, 56 + (v.launcherRows ?? 8) * 2)
                anchors.centerIn: parent
                radius: Math.min(10, (v.launcherRadius ?? 14) / 2.2)
                color: Theme.alpha(Theme.surfaceLow, Math.max(0.55, v.launcherOpacity ?? 0.6))
                border.width: 1
                border.color: Theme.alpha(Theme.outlineVariant, 0.9)

                Rectangle {
                    visible: v.launcherSideImage ?? false
                    width: 22
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        margins: 4
                        left: (v.launcherImageSide ?? "left") === "left" ? parent.left : undefined
                        right: (v.launcherImageSide ?? "left") === "right" ? parent.right : undefined
                    }
                    radius: 4
                    color: Theme.primary
                    opacity: 0.8
                }
                Item {
                    anchors {
                        fill: parent
                        margins: 6
                        leftMargin: 6 + ((v.launcherSideImage ?? false) && (v.launcherImageSide ?? "left") === "left" ? 26 : 0)
                        rightMargin: 6 + ((v.launcherSideImage ?? false) && (v.launcherImageSide ?? "left") === "right" ? 26 : 0)
                    }
                    Rectangle {
                        width: parent.width
                        height: 8
                        radius: 4
                        color: Theme.alpha(Theme.text, 0.3)
                    }
                    // List rows
                    Column {
                        visible: (v.launcherLayout ?? "list") !== "grid"
                        y: 13
                        spacing: 3
                        width: parent.width
                        Repeater {
                            model: 4
                            delegate: Rectangle {
                                required property int index
                                width: parent.width
                                height: 6
                                radius: 3
                                color: index === 0 ? Theme.primary : Theme.alpha(Theme.text, 0.18)
                            }
                        }
                    }
                    // Grid cells
                    Grid {
                        visible: v.launcherLayout === "grid"
                        y: 13
                        columns: Math.min(6, v.launcherColumns ?? 5)
                        spacing: 3
                        Repeater {
                            model: Math.min(6, v.launcherColumns ?? 5) * 2
                            delegate: Rectangle {
                                width: 9
                                height: 9
                                radius: 3
                                color: Theme.alpha(Theme.text, 0.5)
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- a control center: placement, height, header and toggle style --------
    Component {
        id: ccPreview
        Item {
            readonly property var v: card.vals
            readonly property bool onLeft: (v.ccSide ?? "right") === "left"
            readonly property bool fit: v.ccFit ?? false
            readonly property string ts: v.ccToggleStyle ?? "mixed"

            Rectangle {
                id: panelMock
                width: Math.min(parent.width - 10, (v.ccWidth ?? 400) / 400 * 52)
                anchors {
                    top: parent.top
                    topMargin: (v.ccTopMargin ?? 54) > 20 ? 6 : 0
                    bottom: fit ? undefined : parent.bottom
                    bottomMargin: (v.ccBottomMargin ?? 12) > 4 ? 5 : 0
                    left: onLeft ? parent.left : undefined
                    right: onLeft ? undefined : parent.right
                    leftMargin: (v.ccSideMargin ?? 12) > 4 ? 5 : 0
                    rightMargin: (v.ccSideMargin ?? 12) > 4 ? 5 : 0
                }
                height: fit ? mockCol.implicitHeight + 10 : undefined
                radius: 6
                color: Theme.alpha(Theme.surfaceLow, 0.9)
                border.width: 1
                border.color: Theme.alpha(Theme.outlineVariant, 0.9)

                Column {
                    id: mockCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 5
                    }
                    spacing: 4

                    // header
                    Row {
                        visible: v.ccHeader ?? true
                        spacing: 4
                        Rectangle { width: 9; height: 9; radius: 5; color: Theme.primary }
                        Rectangle { width: 16; height: 4; radius: 2; anchors.verticalCenter: parent.verticalCenter; color: Theme.alpha(Theme.text, 0.5) }
                    }

                    // toggles
                    Row {
                        visible: ts === "mixed"
                        spacing: 3
                        Repeater {
                            model: 2
                            delegate: Rectangle { width: 17; height: 9; radius: 3; color: Theme.primaryContainer }
                        }
                    }
                    Grid {
                        visible: ts === "mixed"
                        columns: 3
                        spacing: 3
                        Repeater {
                            model: 6
                            delegate: Rectangle { width: 11; height: 5; radius: 2; color: index === 0 ? Theme.primaryContainer : Theme.alpha(Theme.text, 0.2); required property int index }
                        }
                    }
                    Grid {
                        visible: ts === "tiles"
                        columns: Math.min(5, v.ccColumns ?? 4)
                        spacing: 3
                        Repeater {
                            model: Math.min(5, v.ccColumns ?? 4) * 2
                            delegate: Rectangle { width: 9; height: 9; radius: 3; color: index < 2 ? Theme.primaryContainer : Theme.alpha(Theme.text, 0.2); required property int index }
                        }
                    }
                    Flow {
                        visible: ts === "icons"
                        width: parent.width
                        spacing: 3
                        Repeater {
                            model: 8
                            delegate: Rectangle { width: 7; height: 7; radius: 4; color: index < 3 ? Theme.primary : Theme.alpha(Theme.text, 0.25); required property int index }
                        }
                    }

                    // sliders
                    Rectangle { visible: v.ccSliders ?? true; width: parent.width; height: 3; radius: 2; color: Theme.alpha(Theme.text, 0.25) }
                    Rectangle { visible: v.ccSliders ?? true; width: parent.width * 0.7; height: 3; radius: 2; color: Theme.alpha(Theme.text, 0.25) }

                    // notifications
                    Rectangle {
                        visible: v.ccNotifications ?? true
                        width: parent.width
                        height: 9
                        radius: 3
                        color: Theme.alpha(Theme.text, 0.14)
                    }
                }
            }
        }
    }

    // ---- the power menu: shape and arrangement of the six buttons -----------
    Component {
        id: powerPreview
        Item {
            readonly property var v: card.vals
            readonly property string shape: v.powerShape ?? "card"
            readonly property int cols: (v.powerLayout ?? "row") === "column" ? 1 : (v.powerLayout ?? "row") === "grid" ? 3 : 6

            Rectangle {
                anchors.fill: parent
                color: Theme.alpha("#000000", 0.35)
            }
            Column {
                anchors.centerIn: parent
                spacing: 4
                Rectangle {
                    visible: v.powerHeader ?? false
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 30
                    height: 7
                    radius: 3
                    color: Theme.alpha("#ffffff", 0.8)
                }
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: cols
                    spacing: cols === 6 ? 3 : 4
                    Repeater {
                        model: 6
                        delegate: Rectangle {
                            required property int index
                            readonly property real base: cols === 6 ? 17 : cols === 3 ? 22 : 12
                            width: shape === "pill" ? (cols === 1 ? 46 : 30) : base
                            height: shape === "pill" ? (cols === 1 ? 6 : 10) : shape === "circle" ? base : base * 1.15
                            radius: shape === "card" ? 3 : height / 2
                            color: index === 0 ? Theme.primaryContainer : Theme.alpha(Theme.surfaceMid, Math.max(0.4, v.powerOpacity ?? 0.85))
                            border.width: 1
                            border.color: index === 0 ? Theme.primary : Theme.alpha(Theme.outlineVariant, 0.9)
                        }
                    }
                }
            }
        }
    }

    // ---- the lock screen: clock placement, clock style and the card ----------
    Component {
        id: lockPreview
        Item {
            readonly property var v: card.vals
            readonly property string align: v.lockAlign ?? "center"
            readonly property bool split: (v.lockLayout ?? "stack") === "split"
            readonly property string cs: v.lockClockStyle ?? "big"

            Rectangle {
                anchors.fill: parent
                color: (v.lockWallpaper ?? true) ? Theme.alpha("#000000", Math.min(0.8, (v.lockDim ?? 0.3) + (v.lockBlur ?? 14) / 160))
                                                 : Theme.surfaceLow
            }
            Grid {
                columns: split ? 2 : 1
                columnSpacing: 10
                rowSpacing: 5
                horizontalItemAlignment: align === "center" ? Grid.AlignHCenter : Grid.AlignLeft
                verticalItemAlignment: Grid.AlignVCenter
                x: align === "center" ? (parent.width - width) / 2 : align === "corner" ? 8 : 16
                y: align === "corner" ? parent.height - height - 8 : (parent.height - height) / 2

                // clock, drawn in the style's font
                Text {
                    readonly property string hm: "8:17"
                    text: cs === "stacked" ? "8\n17" : hm
                    lineHeight: cs === "stacked" ? 0.8 : 1
                    font.family: (v.lockClockFont ?? "") !== "" ? v.lockClockFont : Theme.font
                    font.weight: v.lockClockWeight ?? 700
                    font.pixelSize: cs === "small" ? 13 : cs === "stacked" ? 15 : 22
                    color: (v.lockClockAccent ?? false) ? Theme.primary : "#ffffff"
                }
                // card
                Rectangle {
                    width: 46
                    height: (v.lockAvatar ?? true) ? 30 : 16
                    radius: 5
                    color: (v.lockCard ?? true) ? Theme.alpha(Theme.surfaceLow, Math.max(0.4, v.lockCardOpacity ?? 0.8)) : "transparent"
                    border.width: (v.lockCard ?? true) ? 1 : 0
                    border.color: Theme.alpha(Theme.outlineVariant, 0.9)
                    Rectangle {
                        visible: v.lockAvatar ?? true
                        width: 9
                        height: 9
                        radius: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 4
                        color: Theme.primary
                    }
                    Rectangle {
                        width: 36
                        height: 6
                        radius: 3
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        color: Theme.alpha(Theme.text, 0.35)
                    }
                }
            }
        }
    }

    // ---- the dynamic island: a pill at the top with its contents ------------
    Component {
        id: islandPreview
        Item {
            readonly property var v: card.vals
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 4 + (v.islandTop ?? 6) / 3
                height: Math.max(10, (v.islandCompactHeight ?? 34) / 2.4)
                width: pillRow.implicitWidth + 16
                radius: height / 2
                color: Theme.alpha((v.islandColor ?? "black") === "black" ? "#000000" : Theme.surfaceLow, v.islandPillOpacity ?? 1)
                Row {
                    id: pillRow
                    anchors.centerIn: parent
                    spacing: 4
                    Row {
                        visible: v.islandWorkspaces ?? true
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Rectangle { width: 7; height: 3; radius: 2; color: Theme.primary }
                        Repeater {
                            model: 3
                            delegate: Rectangle { width: 3; height: 3; radius: 2; color: Qt.rgba(1, 1, 1, 0.5) }
                        }
                    }
                    Rectangle {
                        visible: v.islandClock ?? true
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14
                        height: 4
                        radius: 2
                        color: "#ffffff"
                    }
                    Rectangle {
                        visible: v.islandDate ?? false
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12
                        height: 3
                        radius: 2
                        color: Qt.rgba(1, 1, 1, 0.6)
                    }
                    Rectangle {
                        visible: v.islandBattery ?? true
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6
                        height: 4
                        radius: 1
                        color: Qt.rgba(1, 1, 1, 0.7)
                    }
                }
            }
            // A hint of the hover panel underneath, when enabled
            Rectangle {
                visible: v.islandHover ?? true
                anchors.horizontalCenter: parent.horizontalCenter
                y: 34
                width: 96
                height: 28
                radius: 10
                color: Theme.alpha((v.islandColor ?? "black") === "black" ? "#000000" : Theme.surfaceLow, 0.45 * (v.islandPillOpacity ?? 1))
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.15)
            }
        }
    }
}
