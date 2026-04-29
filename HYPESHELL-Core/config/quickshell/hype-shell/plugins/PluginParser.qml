import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
pragma Singleton

Item {
    id: root

    property alias model: pluginModel
    property string pendingPid: ""
    property bool waitingForState: false

    Timer {
        id: statePoller
        interval: 100
        repeat: true
        running: false
        onTriggered: {
            if (!waitingForState)
                return

            const idx = indexOf(pendingPid)
            if (idx === -1)
                return

            const realInstalled = isInstalled(pendingPid)
            if (pluginModel.get(idx).installed !== realInstalled) {
                pluginModel.setProperty(idx, "installed", realInstalled)
                pluginModel.setProperty(idx, "busy", false)
                waitingForState = false
                pendingPid = ""
                statePoller.stop()
            }
        }
    }

    function isInstalled(pid) {
        return PluginLoader.plugins.indexOf(pid) !== -1
    }

    function indexOf(pid) {
        for (let i = 0; i < pluginModel.count; ++i) {
            if (pluginModel.get(i).id === pid)
                return i
        }
        return -1
    }

    function refresh() {
        pluginModel.clear()
        fetchProc.running = true
    }

    function install(pid) {
        runAction("install", pid)
    }

    function uninstall(pid) {
        runAction("uninstall", pid)
    }

    function update(pid) {
        runAction("update", pid)
    }

    function runAction(action, pid) {
        const idx = indexOf(pid)
        if (idx === -1)
            return

        pendingPid = pid
        waitingForState = true

        pluginModel.setProperty(idx, "busy", true)

        actionProc.command = [
            "bash",
            "-c",
            Directories.scriptsPath + "/plugins/plugins.sh " + action + " " + pid
        ]
        actionProc.running = true
    }

    ListModel {
        id: pluginModel
    }

    Process {
        id: fetchProc
        running: true
        command: [
            "bash",
            "-c",
            Directories.scriptsPath + "/plugins/plugins.sh fetch all-machine"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                text.split("\n").forEach((line) => {
                    const trimmed = line.trim()
                    if (!trimmed)
                        return

                    const parts = trimmed.split("\t")
                    if (parts.length < 8)
                        return

                    const pid = parts[0]
                    pluginModel.append({
                        id: pid,
                        name: parts[1],
                        version: parts[2],
                        author: parts[3],
                        description: parts[4],
                        requires_hype: parts[5],
                        verified: parts[6] === "true",
                        type: parts[7],
                        icon: parts[8],
                        installed: isInstalled(pid),
                        busy: false
                    })
                })
            }
        }
    }

    Process {
        id: actionProc

        stdout: StdioCollector {
            onStreamFinished: {
                PluginLoader.reload()
                statePoller.start()
            }
        }
    }
}
