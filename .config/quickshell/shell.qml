// Quickshell entry point: one bar per monitor.
// Edits hot-reload; restart with `qs` if something gets stuck.
import QtQuick
import Quickshell
import qs.launcher

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    LauncherWindow {}
}
