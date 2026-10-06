import QtQuick
import qs
import qs.services

// Focused window title (hidden when the workspace is empty)
BarText {
    text: Hypr.title
    color: Theme.textDim
    font.pixelSize: 13
    font.family: Theme.barFont
    elide: Text.ElideRight
}
