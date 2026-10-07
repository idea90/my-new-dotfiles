pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services
import Quickshell.Services.Notifications

// Notification daemon (replaces swaync). Every notification stays in the
// control center until dismissed; new ones also pop up for a few seconds.
Singleton {
    id: root

    property bool dndManual: false
    // Silent by hand, or automatically between Config.dndFrom and Config.dndTo
    readonly property bool dndScheduled: Config.dndAuto && inWindow(Time.now, Config.dndFrom, Config.dndTo)
    readonly property bool dnd: dndManual || dndScheduled

    function inWindow(d, from, to) {
        const m = s => {
            const p = String(s).split(":");
            return parseInt(p[0]) * 60 + parseInt(p[1] || 0);
        };
        const now = d.getHours() * 60 + d.getMinutes(), a = m(from), b = m(to);
        return a <= b ? now >= a && now < b : now >= a || now < b;
    }

    // Newest first, grouped by app: [{ app, items: [notifications] }]
    readonly property var groups: {
        const out = [];
        for (const n of list.slice().reverse()) {
            const app = n.appName || "Other";
            let g = out.find(x => x.app === app);
            if (!g) {
                g = { app: app, items: [] };
                out.push(g);
            }
            g.items.push(n);
        }
        return out;
    }
    readonly property var list: server.trackedNotifications.values
    readonly property int count: list.length
    property var popups: []

    function togglePanel() {
        Panels.toggle("controlcenter");
    }

    function toggleDnd() {
        dndManual = !dnd;
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
        inlineReplySupported: true
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
