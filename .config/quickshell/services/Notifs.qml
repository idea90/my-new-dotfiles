pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Notification daemon (replaces swaync). Every notification stays in the
// control center until dismissed; new ones also pop up for a few seconds.
Singleton {
    id: root

    property bool dnd: false
    readonly property var list: server.trackedNotifications.values
    readonly property int count: list.length
    property var popups: []

    function togglePanel() {
        Panels.toggle("controlcenter");
    }

    function toggleDnd() {
        dnd = !dnd;
    }

    function clearAll() {
        for (const n of list.slice())
            n.dismiss();
    }

    function hidePopup(n) {
        popups = popups.filter(p => p !== n);
    }

    // Seconds a popup stays up: the app's request, else by urgency; 0 = until dismissed
    function popupSeconds(n) {
        if (n.urgency === NotificationUrgency.Critical)
            return 0;
        if (n.expireTimeout > 0)
            return n.expireTimeout;
        return n.urgency === NotificationUrgency.Low ? 3 : 5;
    }

    NotificationServer {
        id: server

        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            n.closed.connect(() => root.hidePopup(n));
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [...root.popups, n];
        }
    }

    IpcHandler {
        target: "notifications"
        function toggleDnd(): void {
            root.toggleDnd();
        }
        function clear(): void {
            root.clearAll();
        }
    }
}
