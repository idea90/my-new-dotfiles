import QtQuick
import qs
import qs.services

// Click: play/pause. Scroll: next/previous. Hidden when nothing is playing.
Chip {
    property bool fits: true

    visible: Media.available && fits
    padding: 14
    radius: Theme.pillRadius
    fg: Theme.tertiaryContainerFg
    bg: Theme.tertiaryContainer
    hoverBg: Theme.alpha(Theme.tertiaryContainer, 0.85)
    opacity: Media.playing ? 1 : 0.65
    icon: !Media.playing ? Theme.icon(0xf03e4)
        : Media.app.includes("spotify") ? Theme.icon(0xf04c7)
        : Media.app.includes("firefox") ? Theme.icon(0xf0239)
        : Theme.icon(0xf075a)
    label: Media.title.length > 20 ? Media.title.slice(0, 19) + "…" : Media.title
    onLeftClicked: Media.toggle()
    onScrolled: step => step > 0 ? Media.next() : Media.previous()
}
