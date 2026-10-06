pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

// Session lock state and password check.
//   qs ipc call lock lock      lock the session
//   qs ipc call lock preview   show the lock screen as an ordinary window (safe to try)
//   qs ipc call lock unlock    emergency unlock, e.g. from a TTY: qs ipc call lock unlock
Singleton {
    id: root

    property bool locked: false
    property bool preview: false
    property bool checking: false
    property string error: ""

    signal failed

    function lock() {
        error = "";
        locked = true;
    }

    function unlock() {
        locked = false;
        preview = false;
        checking = false;
        error = "";
    }

    // Preview mode accepts any password so it can't lock you out
    function submit(password) {
        if (preview) {
            unlock();
            return;
        }
        if (checking || password === "")
            return;
        pending = password;
        checking = true;
        error = "";
        pam.start();
    }

    property string pending: ""

    PamContext {
        id: pam
        configDirectory: Quickshell.shellDir + "/pam"
        config: "password.conf"

        onPamMessage: {
            if (responseRequired)
                respond(root.pending);
        }
        onCompleted: result => {
            root.pending = "";
            root.checking = false;
            if (result === PamResult.Success) {
                root.unlock();
            } else {
                root.error = "Wrong password";
                root.failed();
            }
        }
        onError: {
            root.pending = "";
            root.checking = false;
            root.error = "Authentication error";
            root.failed();
        }
    }

    IpcHandler {
        target: "lock"
        function lock(): void {
            root.lock();
        }
        function preview(): void {
            root.preview = !root.preview;
        }
        function unlock(): void {
            root.unlock();
        }
    }
}
