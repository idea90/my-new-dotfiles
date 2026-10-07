import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules
import qs.services

// Widgets drawn on the wallpaper, under every window.
// Config.widgetsStyle: "cards" (glass cards) | "plain" (text straight on the wallpaper)
// Config.widgetsPosition: top-left | top-right | bottom-left | bottom-right | center
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    // Background services that only run timers are created on first use; this
    // window always exists, so it keeps them alive
    readonly property var _slideshow: Slideshow
    readonly property var _nightLight: NightLight

    readonly property bool plain: Config.widgetsStyle === "plain"
    readonly property string pos: Config.widgetsPosition

    visible: Config.widgetsEnabled
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "qs-desktop"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Only the widgets take clicks; the rest is click-through
    mask: Region { item: stack }

    component Box: Rectangle {
        default property alias content: inner.data
        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight + (win.plain ? 20 : 28)
        radius: Config.panelRadius + 4
        color: win.plain ? Qt.rgba(0, 0, 0, 0.28) : Theme.alpha(Theme.surfaceLow, 0.55)
        border.width: win.plain ? 0 : 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.6)
        ColumnLayout {
            id: inner
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: win.plain ? 12 : 16
            }
            spacing: 6
        }
    }

    ColumnLayout {
        id: stack
        width: 320
        spacing: 14
        x: win.pos.endsWith("left") ? Theme.barSpaceLeft + 40
         : win.pos.endsWith("right") ? parent.width - width - Theme.barSpaceRight - 40
         : (parent.width - width) / 2
        y: win.pos.startsWith("top") ? Theme.barSpaceTop + 40
         : win.pos.startsWith("bottom") ? parent.height - height - Theme.barSpaceBottom - 80
         : (parent.height - height) / 2

        // Clock
        Box {
            visible: Config.widgetClock
            BarText {
                Layout.alignment: win.pos === "center" ? Qt.AlignHCenter : Qt.AlignLeft
                text: Qt.formatDateTime(Time.now, Config.clock24h ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "")
                font.pixelSize: win.plain ? 84 : 56
                font.bold: true
                color: "#ffffff"
                style: win.plain ? Text.Outline : Text.Normal
                styleColor: Qt.rgba(0, 0, 0, 0.25)
            }
            BarText {
                Layout.alignment: win.pos === "center" ? Qt.AlignHCenter : Qt.AlignLeft
                text: Qt.formatDateTime(Time.now, "dddd, d MMMM")
                font.pixelSize: 16
                color: Theme.primary
            }
        }

        // Weather
        Box {
            visible: Config.widgetWeather && Weather.ready
            RowLayout {
                spacing: 14
                BarText {
                    text: Weather.glyph
                    font.pixelSize: 40
                    color: Theme.primary
                }
                Column {
                    BarText {
                        text: Weather.temp + Weather.unit + "  ·  " + Weather.desc
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ffffff"
                    }
                    BarText {
                        text: Weather.place + "  ·  feels like " + Weather.feels + Weather.unit
                        font.pixelSize: 12
                        color: Qt.rgba(1, 1, 1, 0.7)
                    }
                }
            }
            RowLayout {
                visible: Weather.forecast.length > 0
                spacing: 18
                Repeater {
                    model: Weather.forecast
                    delegate: Column {
                        required property var modelData
                        BarText {
                            text: modelData.day
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.7)
                        }
                        BarText {
                            text: Weather.icon(modelData.code, true) + " " + modelData.max + "° / " + modelData.min + "°"
                            font.pixelSize: 12
                            color: "#ffffff"
                        }
                    }
                }
            }
        }

        // Music
        Box {
            visible: Config.widgetMusic && Media.available
            RowLayout {
                spacing: 12
                ClippingRectangle {
                    implicitWidth: 56
                    implicitHeight: 56
                    radius: 10
                    color: Theme.tertiaryContainer
                    Image {
                        anchors.fill: parent
                        source: Media.art
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }
                Column {
                    Layout.fillWidth: true
                    BarText {
                        width: parent.width
                        text: Media.title
                        elide: Text.ElideRight
                        font.bold: true
                        color: "#ffffff"
                    }
                    BarText {
                        width: parent.width
                        text: Media.artist
                        elide: Text.ElideRight
                        font.pixelSize: 12
                        color: Qt.rgba(1, 1, 1, 0.7)
                    }
                    Row {
                        Chip {
                            icon: Theme.icon(0xf04ae)
                            fg: "#ffffff"
                            onLeftClicked: Media.previous()
                        }
                        Chip {
                            icon: Media.playing ? Theme.icon(0xf03e4) : Theme.icon(0xf040a)
                            fg: "#ffffff"
                            onLeftClicked: Media.toggle()
                        }
                        Chip {
                            icon: Theme.icon(0xf04ad)
                            fg: "#ffffff"
                            onLeftClicked: Media.next()
                        }
                    }
                }
            }
        }

        // System
        Box {
            visible: Config.widgetSystem
            Repeater {
                model: [
                    { name: "CPU", value: Sys.cpu / 100, text: Sys.cpu + "%" },
                    { name: "Memory", value: Sys.memory / 100, text: Sys.memory + "%" },
                    { name: "Battery", value: Battery.percent / 100, text: Battery.available ? Battery.percent + "%" : "—" }
                ]
                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 10
                    BarText {
                        Layout.preferredWidth: 64
                        text: modelData.name
                        font.pixelSize: 12
                        color: Qt.rgba(1, 1, 1, 0.75)
                    }
                    MiniBar {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        value: modelData.value
                    }
                    BarText {
                        Layout.preferredWidth: 38
                        horizontalAlignment: Text.AlignRight
                        text: modelData.text
                        font.pixelSize: 12
                        color: "#ffffff"
                    }
                }
            }
        }
    }
}
