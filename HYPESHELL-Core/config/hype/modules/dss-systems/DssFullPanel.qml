/**
 * DssFullPanel.qml — Launches dss-panel.qml via qml6 (standalone WebEngineView).
 *
 * qml6 properly initializes QtWebEngineQuick before QGuiApplication,
 * bypassing the restriction in Quickshell that prevents WebEngineView.
 *
 * Hyprland window rules target: class "org.qt-project.qml" title "Multica Panel"
 * Close with: Super+Shift+D  (IPC sidebarDss toggle / closePanel)
 */

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property string systemUrl: "http://localhost:3001"
    signal closeRequested()

    readonly property string launchScript: Quickshell.env("HOME") +
        "/.config/hype/modules/dss-systems/launch-dss-panel.sh"

    Process {
        id: panelProc

        command: root.systemUrl.length > 0 ? [
            "bash",
            root.launchScript,
            root.systemUrl
        ] : []

        running: root.systemUrl.length > 0

        onRunningChanged: {
            if (running) {
                Quickshell.execDetached(["hyprctl", "dispatch", "submap", "dss-panel"])
            }
        }

        onExited: (code, status) => {
            Quickshell.execDetached(["hyprctl", "dispatch", "submap", "reset"])
            root.closeRequested()
        }
    }
}
