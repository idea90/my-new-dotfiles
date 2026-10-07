import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs
import qs.modules
import qs.services

// Launcher UI: dimmed backdrop, search field, app list.
// Keys: type to search, Up/Down (or Ctrl+J/K, Tab) to move, Enter to launch, Esc to close.
Item {
    id: root

    property var entries: []
    readonly property bool gridMode: Config.launcherLayout === "grid"
    readonly property var view: gridMode ? grid : list
    property string query: ""
    readonly property string lfont: Config.launcherFont !== "" ? Config.launcherFont : Theme.font
    readonly property string hl: Config.launcherHighlight      // fill | bar | outline
    readonly property string ss: Config.launcherSearchStyle    // field | line | big

    function greeting() {
        const h = Time.now.getHours();
        return h >= 5 && h < 12 ? "Good morning" : h >= 12 && h < 18 ? "Good afternoon" : h >= 18 && h < 22 ? "Good evening" : "Good night";
    }
    readonly property var results: AppMenu.search(entries, query)

    // ---- full-screen (Launchpad-style) mode ----
    readonly property bool fs: Config.launcherFullscreen
    property int fsIndex: 0
    readonly property int fsCols: Math.max(2, Config.launcherFsColumns)
    readonly property int fsRows: Math.max(1, Config.launcherFsRows)
    readonly property int pageSize: fsCols * fsRows
    readonly property int page: Math.floor(fsIndex / pageSize)
    readonly property int pageCount: Math.max(1, Math.ceil(results.length / pageSize))
    readonly property var pageItems: results.slice(page * pageSize, page * pageSize + pageSize)
    onQueryChanged: fsIndex = 0

    // Shared by both search fields
    function handleKey(event) {
        const ctrl = event.modifiers & Qt.ControlModifier;
        const k = event.key;
        event.accepted = true;
        if (k === Qt.Key_Escape) {
            AppMenu.open = false;
        } else if (fs) {
            const n = results.length;
            let g = fsIndex;
            if (k === Qt.Key_Right || k === Qt.Key_Tab || (ctrl && k === Qt.Key_J))
                g += 1;
            else if (k === Qt.Key_Left || k === Qt.Key_Backtab || (ctrl && k === Qt.Key_K))
                g -= 1;
            else if (k === Qt.Key_Down)
                g += fsCols;
            else if (k === Qt.Key_Up)
                g -= fsCols;
            else if (k === Qt.Key_PageDown)
                g += pageSize;
            else if (k === Qt.Key_PageUp)
                g -= pageSize;
            else if (k === Qt.Key_Return || k === Qt.Key_Enter) {
                if (n > 0)
                    AppMenu.launch(results[fsIndex]);
                return;
            } else {
                event.accepted = false;
                return;
            }
            fsIndex = Math.max(0, Math.min(n - 1, g));
        } else if (gridMode && k === Qt.Key_Left) {
            grid.moveCurrentIndexLeft();
        } else if (gridMode && k === Qt.Key_Right) {
            grid.moveCurrentIndexRight();
        } else if (gridMode && k === Qt.Key_Down) {
            grid.moveCurrentIndexDown();
        } else if (gridMode && k === Qt.Key_Up) {
            grid.moveCurrentIndexUp();
        } else if (k === Qt.Key_Down || k === Qt.Key_Tab || (ctrl && k === Qt.Key_J)) {
            view.incrementCurrentIndex();
        } else if (k === Qt.Key_Up || k === Qt.Key_Backtab || (ctrl && k === Qt.Key_K)) {
            view.decrementCurrentIndex();
        } else if (k === Qt.Key_Return || k === Qt.Key_Enter) {
            if (results.length > 0)
                AppMenu.launch(results[view.currentIndex]);
        } else {
            event.accepted = false;
        }
    }

    Connections {
        target: AppMenu
        function onPrefill(text) {
            prefillTimer.text = text;
            prefillTimer.restart();
        }
    }
    // After the open-reset below has run
    Timer {
        id: prefillTimer
        property string text: ""
        interval: 30
        onTriggered: {
            search.text = text;
            fsSearch.text = text;
        }
    }

    // Reset every time it opens
    Connections {
        target: AppMenu
        function onOpenChanged() {
            if (AppMenu.open) {
                Wallpapers.imageRev += 1;   // always show the current wallpaper
                search.text = "";
                fsSearch.text = "";
                root.query = "";
                root.fsIndex = 0;
                list.currentIndex = 0;
                grid.currentIndex = 0;
                (root.fs ? fsSearch : search).forceActiveFocus();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("#000000", root.fs ? Config.launcherFsDim : Config.launcherDim)

        MouseArea {
            anchors.fill: parent
            onClicked: AppMenu.open = false
        }
    }

    Rectangle {
        id: card

        visible: !root.fs
        readonly property bool hasImage: Config.launcherSideImage
        readonly property bool imageLeft: Config.launcherImageSide !== "right"
        readonly property int imageSpace: hasImage ? Config.launcherImageWidth + 10 : 0

        width: Config.launcherWidth + imageSpace
        height: column.implicitHeight + 28
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * Config.launcherTop
        radius: Config.launcherRadius
        color: Theme.alpha(Theme.byName(Config.launcherCardColor !== "" ? Config.launcherCardColor : Config.panelColor, Theme.surfaceLow), Config.launcherOpacity)
        border.width: Config.launcherBorder ? Math.max(1, Config.panelBorder) : 0
        border.color: Theme.panelBorderFill

        // Swallow clicks so they don't close the launcher
        MouseArea {
            anchors.fill: parent
        }

        // Wallpaper on the side
        Item {
            id: side
            visible: card.hasImage
            x: card.imageLeft ? 10 : card.width - width - 10
            y: 10
            width: Config.launcherImageWidth
            height: card.height - 20

            Image {
                id: sideImg
                anchors.fill: parent
                visible: false
                source: "file://" + Quickshell.env("HOME") + "/.cache/lockscreen.png?" + Wallpapers.imageRev
                cache: false
                sourceSize.height: 900
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
            Rectangle {
                id: sideMask
                anchors.fill: parent
                radius: Math.max(4, Config.launcherRadius - 4)
                visible: false
                layer.enabled: true
            }
            MultiEffect {
                anchors.fill: parent
                source: sideImg
                visible: sideImg.status === Image.Ready
                maskEnabled: true
                maskSource: sideMask
            }
            Rectangle {
                anchors.fill: parent
                radius: sideMask.radius
                visible: sideImg.status !== Image.Ready
                color: Theme.primaryContainer
            }
            // Soft fade at the bottom, with a little caption
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 90
                radius: sideMask.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: Theme.alpha("#000000", 0.55) }
                }
            }
            BarText {
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    margins: 14
                }
                text: Qt.formatDateTime(Time.now, Config.clock24h ? "HH:mm" : "h:mm AP").replace(/\s*[AP]M$/i, "") + "  ·  " + Qt.formatDateTime(Time.now, "ddd d MMM")
                color: Qt.rgba(1, 1, 1, 0.92)
                font.pixelSize: 13
            }
        }

        Column {
            id: column
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: 14 + (card.hasImage && card.imageLeft ? card.imageSpace : 0)
                rightMargin: 14 + (card.hasImage && !card.imageLeft ? card.imageSpace : 0)
                topMargin: 14
            }
            spacing: 10

            // Optional greeting above the search
            Column {
                visible: Config.launcherHeader
                width: parent.width
                topPadding: 6
                bottomPadding: 4
                spacing: 2
                BarText {
                    text: root.greeting() + ", " + Quickshell.env("USER")
                    font.family: root.lfont
                    font.pixelSize: 22
                    font.bold: true
                }
                BarText {
                    text: Qt.formatDateTime(Time.now, "dddd d MMMM") + "  ·  " + root.results.length + " apps"
                    font.family: root.lfont
                    font.pixelSize: 12
                    color: Theme.textDim
                }
            }

            // Search field: a filled box, an underlined line, or big bare text
            Rectangle {
                width: parent.width
                height: root.ss === "big" ? 62 : Config.launcherSearchHeight
                radius: Theme.pillRadius
                color: root.ss === "field" ? Theme.surfaceHigh : "transparent"

                Rectangle {
                    visible: root.ss !== "field"
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: root.ss === "line" ? 2 : 1
                    color: search.activeFocus && root.ss === "line" ? Theme.primary : Theme.alpha(Theme.text, 0.18)
                }

                BarText {
                    id: searchIcon
                    anchors {
                        left: parent.left
                        leftMargin: root.ss === "field" ? 14 : 4
                        verticalCenter: parent.verticalCenter
                    }
                    text: Theme.icon(0xf0349)
                    color: Theme.primary
                    font.pixelSize: root.ss === "big" ? 26 : 18
                }

                TextField {
                    id: search
                    anchors {
                        left: searchIcon.right
                        right: Config.launcherCounter ? counter.left : parent.right
                        leftMargin: 10
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    background: null
                    color: Theme.text
                    placeholderText: Config.launcherPlaceholder
                    placeholderTextColor: Theme.alpha(Theme.text, 0.45)
                    selectionColor: Theme.primary
                    selectedTextColor: Theme.primaryFg
                    font.family: root.lfont
                    font.pixelSize: root.ss === "big" ? 26 : 15
                    onTextChanged: {
                        root.query = text;
                        list.currentIndex = 0;
                        grid.currentIndex = 0;
                    }

                    Keys.onPressed: event => root.handleKey(event)
                }

                BarText {
                    id: counter
                    visible: Config.launcherCounter
                    anchors {
                        right: parent.right
                        rightMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    text: root.results.length + " / " + root.entries.filter(e => !e.noDisplay).length
                    color: Theme.alpha(Theme.text, 0.45)
                    font.pixelSize: 12
                }
            }

            ListView {
                id: list

                width: parent.width
                height: Math.min(contentHeight, Config.launcherRows * (Config.launcherRowHeight + 2))
                clip: true
                spacing: 2
                model: root.results
                highlightMoveDuration: 120
                boundsBehavior: Flickable.StopAtBounds
                visible: !root.gridMode && list.count > 0

                highlight: Rectangle {
                    radius: Theme.innerRadius + 2
                    color: root.hl === "fill" ? Theme.primaryContainer : root.hl === "bar" ? Theme.alpha(Theme.primary, 0.1) : "transparent"
                    border.width: root.hl === "outline" ? 2 : 0
                    border.color: Theme.primary
                    Rectangle {
                        visible: root.hl === "bar"
                        width: 3
                        height: parent.height * 0.6
                        radius: 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.primary
                    }
                }

                delegate: Item {
                    id: row

                    required property var modelData
                    required property int index
                    readonly property bool selected: ListView.isCurrentItem

                    width: list.width
                    height: Config.launcherRowHeight

                    PopIn {
                        order: row.index
                        trigger: AppMenu.open
                        fromScale: 0.96
                        rise: 14
                    }

                    IconImage {
                        id: appIcon
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        implicitSize: Config.launcherIconSize
                        source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                        mipmap: true
                    }

                    Column {
                        anchors {
                            left: appIcon.right
                            right: parent.right
                            leftMargin: 12
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 1

                        BarText {
                            width: parent.width
                            text: row.modelData.name
                            font.family: root.lfont
                            color: !row.selected ? Theme.text : root.hl === "fill" ? Theme.primaryContainerFg : Theme.primary
                            elide: Text.ElideRight
                        }
                        BarText {
                            width: parent.width
                            visible: Config.launcherDescriptions && text !== ""
                            text: row.modelData.genericName || row.modelData.comment
                            color: row.selected && root.hl === "fill" ? Theme.alpha(Theme.primaryContainerFg, 0.7) : Theme.textDim
                            font.pixelSize: 11
                            font.weight: Font.Normal
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = row.index
                        onClicked: AppMenu.launch(row.modelData)
                    }
                }
            }

            GridView {
                id: grid

                width: parent.width
                readonly property int columns: Math.max(2, Config.launcherColumns)
                cellWidth: Math.floor(width / columns)
                cellHeight: Config.launcherCellHeight
                height: Math.min(contentHeight, Config.launcherRows * cellHeight)
                clip: true
                model: root.results
                highlightMoveDuration: 120
                boundsBehavior: Flickable.StopAtBounds
                visible: root.gridMode && grid.count > 0

                highlight: Rectangle {
                    radius: Theme.innerRadius + 4
                    color: root.hl === "fill" ? Theme.primaryContainer : root.hl === "bar" ? Theme.alpha(Theme.primary, 0.1) : "transparent"
                    border.width: root.hl === "outline" ? 2 : 0
                    border.color: Theme.primary
                    Rectangle {
                        visible: root.hl === "bar"
                        width: 3
                        height: parent.height * 0.6
                        radius: 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.primary
                    }
                }

                delegate: Item {
                    id: cell

                    required property var modelData
                    required property int index
                    readonly property bool selected: GridView.isCurrentItem

                    width: grid.cellWidth
                    height: grid.cellHeight

                    PopIn {
                        order: cell.index
                        trigger: AppMenu.open
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        width: parent.width - 12

                        IconImage {
                            anchors.horizontalCenter: parent.horizontalCenter
                            implicitSize: Math.round(Config.launcherIconSize * 1.5)
                            source: Quickshell.iconPath(cell.modelData.icon, "application-x-executable")
                            mipmap: true
                        }
                        BarText {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: cell.modelData.name
                            font.pixelSize: 12
                            font.family: root.lfont
                            color: !cell.selected ? Theme.text : root.hl === "fill" ? Theme.primaryContainerFg : Theme.primary
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: grid.currentIndex = cell.index
                        onClicked: AppMenu.launch(cell.modelData)
                    }
                }
            }

            BarText {
                visible: root.results.length === 0
                width: parent.width
                height: 40
                horizontalAlignment: Text.AlignHCenter
                text: "No apps match \"" + root.query + "\""
                color: Theme.textDim
            }
        }
    }

    // ======================= full-screen mode ================================
    Item {
        id: fsView
        anchors.fill: parent
        visible: root.fs

        // Optional blurred wallpaper background instead of the live screen blur
        Image {
            id: fsWall
            anchors.fill: parent
            visible: false
            source: "file://" + Quickshell.env("HOME") + "/.cache/lockscreen.png?" + Wallpapers.imageRev
            cache: false
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
        MultiEffect {
            anchors.fill: parent
            source: fsWall
            visible: Config.launcherFsBackground === "wallpaper" && fsWall.status === Image.Ready
            blurEnabled: true
            blurMax: 64
            blur: 0.55
            autoPaddingEnabled: false
        }

        // Click anywhere empty to close
        MouseArea {
            anchors.fill: parent
            onClicked: AppMenu.open = false
            onWheel: event => {
                const dir = event.angleDelta.y < 0 ? 1 : -1;
                root.fsIndex = Math.max(0, Math.min(root.results.length - 1,
                    root.fsIndex + dir * root.pageSize));
            }
        }

        // Search pill
        Rectangle {
            id: fsSearchBox
            anchors {
                top: parent.top
                topMargin: 52
                horizontalCenter: parent.horizontalCenter
            }
            width: Math.min(420, parent.width - 80)
            height: 44
            radius: height / 2
            color: Theme.alpha(Theme.surfaceHigh, 0.7)
            border.width: 1
            border.color: Theme.alpha(Theme.outlineVariant, 0.9)

            BarText {
                id: fsSearchIcon
                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                text: Theme.icon(0xf0349)
                color: Theme.alpha(Theme.text, 0.6)
                font.pixelSize: 16
            }
            TextField {
                id: fsSearch
                anchors {
                    left: fsSearchIcon.right
                    right: parent.right
                    leftMargin: 10
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                background: null
                color: Theme.text
                placeholderText: "Search"
                placeholderTextColor: Theme.alpha(Theme.text, 0.45)
                selectionColor: Theme.primary
                selectedTextColor: Theme.primaryFg
                font.family: Theme.font
                font.pixelSize: 15
                horizontalAlignment: text === "" ? Text.AlignHCenter : Text.AlignLeft
                onTextChanged: root.query = text
                Keys.onPressed: event => root.handleKey(event)
            }
        }

        // The page of icons
        Item {
            id: pageArea
            anchors {
                top: fsSearchBox.bottom
                topMargin: 36
                bottom: dots.top
                bottomMargin: 14
                left: parent.left
                right: parent.right
                leftMargin: Math.max(40, parent.width * 0.06)
                rightMargin: Math.max(40, parent.width * 0.06)
            }

            readonly property real cellW: width / root.fsCols
            readonly property real cellH: height / root.fsRows

            // Fade the page when it changes
            property int shownPage: root.page
            onShownPageChanged: pageFade.restart()
            NumberAnimation {
                id: pageFade
                target: iconGrid
                property: "opacity"
                from: 0.2
                to: 1
                duration: Theme.dur(220)
                easing.type: Easing.OutCubic
            }

            Grid {
                id: iconGrid
                columns: root.fsCols
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: root.pageItems

                    delegate: Item {
                        id: cell

                        required property var modelData
                        required property int index
                        readonly property bool selected: root.page * root.pageSize + index === root.fsIndex

                        width: pageArea.cellW
                        height: pageArea.cellH

                        PopIn {
                            order: cell.index
                            trigger: AppMenu.open
                            fromScale: 0.5
                            rise: 30
                            stepMs: 14
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(parent.width - 10, Config.launcherFsIcon + 56)
                            height: Math.min(parent.height - 8, Config.launcherFsIcon + (Config.launcherFsNames ? 54 : 28))
                            radius: Config.itemRadius + 6
                            color: cell.selected ? Theme.alpha(Theme.text, 0.16)
                                 : mouse.containsMouse ? Theme.alpha(Theme.text, 0.08) : "transparent"
                            Behavior on color {
                                ColorAnimation { duration: Theme.dur(120) }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 10
                            width: parent.width - 16

                            IconImage {
                                anchors.horizontalCenter: parent.horizontalCenter
                                implicitSize: Config.launcherFsIcon
                                source: Quickshell.iconPath(cell.modelData.icon, "application-x-executable")
                                mipmap: true
                                scale: cell.selected || mouse.containsMouse ? 1.08 : 1
                                Behavior on scale {
                                    NumberAnimation { duration: Theme.dur(140); easing.type: Easing.OutBack }
                                }
                            }
                            BarText {
                                visible: Config.launcherFsNames
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: cell.modelData.name
                                font.pixelSize: 13
                                color: "#ffffff"
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.fsIndex = root.page * root.pageSize + cell.index
                            onClicked: AppMenu.launch(cell.modelData)
                        }
                    }
                }
            }

            BarText {
                anchors.centerIn: parent
                visible: root.results.length === 0
                text: "No apps match \"" + root.query + "\""
                color: Theme.textDim
                font.pixelSize: 16
            }
        }

        // Page dots
        Row {
            id: dots
            anchors {
                bottom: parent.bottom
                bottomMargin: 34
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 12
            visible: root.pageCount > 1

            Repeater {
                model: root.pageCount
                delegate: Rectangle {
                    required property int index
                    width: 9
                    height: 9
                    radius: 5
                    color: index === root.page ? "#ffffff" : Theme.alpha("#ffffff", 0.35)
                    scale: index === root.page ? 1.15 : 1
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.fsIndex = index * root.pageSize
                    }
                }
            }
        }
    }
}
