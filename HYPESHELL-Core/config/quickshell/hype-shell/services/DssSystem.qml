import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool isDaemonRunning: false
    property bool isDaemonInstalled: false
    property string daemonVersion: "—"

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            checkInstalled.running = true
            checkRunning.running = true
        }
    }

    Process {
        id: checkInstalled
        command: ["which", "multica"]
        stdout: StdioCollector {
            onStreamFinished: root.isDaemonInstalled = (exitCode === 0)
        }
    }

    Process {
        id: checkRunning
        command: ["systemctl", "is-active", "dss-systems-daemon"]
        stdout: StdioCollector {
            onStreamFinished: root.isDaemonRunning = (text.trim() === "active")
        }
    }

    Process {
        id: versionProc
        running: isDaemonInstalled
        command: ["multica", "version"]
        stdout: StdioCollector {
            onStreamFinished: root.daemonVersion = text.trim()
        }
    }

    function triggerInstall() {
        if (installProc.running) return;
        installProc.running = true
    }

    Process {
        id: installProc
        command: ["dss-daemon", "install"]
        stdout: StdioCollector {
            onStreamFinished: {
                checkInstalled.running = true
                checkRunning.running = true
            }
        }
    }

    function toggleDaemon() {
        if (isDaemonRunning) {
            stopProc.running = true
        } else {
            startProc.running = true
        }
    }

    Process { id: startProc; command: ["dss-daemon", "start"] }
    Process { id: stopProc; command: ["dss-daemon", "stop"] }
}
