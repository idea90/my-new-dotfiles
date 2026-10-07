import QtQuick
import qs

// Drop inside any item to make it pop in: fade, grow with a little overshoot,
// and rise a few pixels. `order` staggers siblings; `trigger` replays it each
// time it turns true (e.g. when a panel opens). Follows Config.animSpeed.
Item {
    id: pop

    property Item target: parent
    property int order: 0
    property bool trigger: true
    property real fromScale: 0.86
    property real rise: 10
    property int stepMs: 26

    function play() {
        if (!target)
            return;
        if (Config.animSpeed <= 0) {
            target.opacity = 1;
            target.scale = 1;
            shift.y = 0;
            return;
        }
        anim.stop();
        target.opacity = 0;
        target.scale = fromScale;
        shift.y = rise;
        anim.start();
    }

    Translate {
        id: shift
    }

    Component.onCompleted: {
        if (target)
            target.transform = [shift];
        if (trigger)
            play();
    }
    onTriggerChanged: if (trigger) play()

    SequentialAnimation {
        id: anim
        PauseAnimation {
            duration: Theme.dur(Math.min(pop.order, 14) * pop.stepMs)
        }
        ParallelAnimation {
            NumberAnimation { target: pop.target; property: "opacity"; to: 1; duration: Theme.dur(220); easing.type: Easing.OutCubic }
            NumberAnimation { target: pop.target; property: "scale"; to: 1; duration: Theme.dur(380); easing.type: Easing.OutBack; easing.overshoot: 1.6 }
            NumberAnimation { target: shift; property: "y"; to: 0; duration: Theme.dur(320); easing.type: Easing.OutCubic }
        }
    }
}
