import QtQuick
import QtQuick.Layouts
import qs
import qs.modules
import qs.services

// One zone of the bar (left, center or right), built from Config.barLayout.
// The zone's list is split into islands at each "|" entry. On a side bar the
// zone stacks its islands top to bottom.
GridLayout {
    id: zone

    required property string name
    // Largest width an island holding the window title may have (-1: unlimited)
    property real titleLimit: -1
    property real freeWidth: -1   // room for the now-playing module (-1: unlimited)

    readonly property var groups: {
        const out = [[]];
        for (const id of Config.barLayout[name] ?? []) {
            if (id === "|")
                out.push([]);
            else if (id in BarModules.modules)
                out[out.length - 1].push(id);
        }
        return out.filter(g => g.length > 0);
    }

    flow: Theme.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
    rows: Theme.vertical ? -1 : 1
    columns: Theme.vertical ? 1 : -1
    rowSpacing: Config.islandSpacing
    columnSpacing: Config.islandSpacing

    Repeater {
        model: zone.groups

        Island {
            id: isl

            required property var modelData
            required property int index
            readonly property bool hasTitle: modelData.includes("title")

            shown: modelData.some(id => BarModules.wanted(id, zone.freeWidth))

            PopIn {
                order: index
                rise: -16
                fromScale: 0.8
                stepMs: 60
            }
            readonly property bool dotsGroup: modelData.includes("workspaces") && (Config.wsStyle === "dots" || Config.wsStyle === "lines")
            padding: Theme.vertical ? (dotsGroup ? 14 : 4) : hasTitle ? 14 : dotsGroup ? 16 : 4
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: hasTitle && zone.titleLimit >= 0 ? Math.max(0, zone.titleLimit - x - 16) : 100000

            Repeater {
                model: isl.modelData

                Loader {
                    required property string modelData
                    visible: BarModules.wanted(modelData, zone.freeWidth)
                    active: visible
                    sourceComponent: modelData === "title" ? title : BarModules.modules[modelData]

                    Component {
                        id: title
                        WindowTitle {
                            width: Math.min(implicitWidth, Math.max(0, isl.Layout.maximumWidth - 28))
                        }
                    }
                }
            }
        }
    }
}
