pragma Singleton

import QtQuick
import Quickshell

// Toggled from the bar; Bar.qml's IdleInhibitor follows it
Singleton {
    property bool inhibited: false

    function toggle() {
        inhibited = !inhibited;
    }
}
