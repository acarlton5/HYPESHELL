/**
 * DssSidebar.qml — DSS Workspace module entry point.
 *
 * Root is a Scope so we can host two PanelWindows:
 *   1. Left sidebar (native QML — repos, notifications, quick actions)
 *   2. Full overlay panel (WebEngineView — full DSS web UI)
 *
 * Toggle via IPC:  quickshell ipc call sidebarDss toggle
 * Or via Hype bar: wire the left-sidebar bar button to call sidebarLeft.
 */

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config
import qs.modules.components
Scope {
    id: root

    // ── Shared state ──────────────────────────────────────────────────
    IpcHandler {
        target: "dss-systems"
        function toggle() {
            Globals.visiblility.sidebarRight = false
            Globals.visiblility.sidebarLeft  = false
            Globals.visiblility.sidebarDev   = !Globals.visiblility.sidebarDev
        }
        function togglePanel() {
            Globals.visiblility.dssFullPanelOpen = !Globals.visiblility.dssFullPanelOpen
        }
        function openPanel() {
            Globals.visiblility.dssFullPanelOpen = true
        }
        function closePanel() {
            Globals.visiblility.dssFullPanelOpen = false
        }
    }
    property bool   bridgeConnected:  false
    property var    repos:            []
    property var    issues:           []
    property var    myTasks:          []
    property var    notifications:    []
    property string selectedOwner:    ""
    property string selectedRepo:     ""
    property string selectedDisplay:  ""
    property string actionStatus:     ""
    property bool   actionBusy:       false

    readonly property string daemonPath: "/run/media/morph/DATA/projects/DSS-System/server/bin/dark-factory"

    // ── Daemon line parser ────────────────────────────────────────────
    function handleLine(line) {
        const trimmed = String(line || "").trim()
        if (!trimmed) return
        try {
            const msg = JSON.parse(trimmed)
            switch (msg.type) {
                case "connected":
                    root.bridgeConnected = !!msg.data
                    break
                case "repos":
                    root.repos = msg.data || []
                    // Auto-select first repo if none selected
                    if (!root.selectedOwner && root.repos.length > 0) {
                        const first = root.repos[0]
                        root.selectRepo(first.owner.login, first.name, first.name)
                    }
                    break
                case "notification":
                    const notifs = root.notifications.slice()
                    notifs.unshift(msg.data)
                    if (notifs.length > 50) notifs.pop()
                    root.notifications = notifs
                    break
                case "issues":
                    root.issues = msg.data || []
                    break
                case "my-tasks":
                    root.myTasks = msg.data || []
                    break
                case "actionResult":
                    root.actionStatus = msg.data.success
                        ? "Done" + (msg.data.stdout ? ": " + msg.data.stdout.trim() : "")
                        : "Error: " + (msg.data.stderr || msg.data.error || "unknown")
                    root.actionBusy = false
                    break
                case "error":
                    root.actionStatus = "Error: " + (msg.data.message || "unknown")
                    root.actionBusy = false
                    break
            }
        } catch (e) {}
    }

    function selectRepo(owner, repo, display) {
        root.selectedOwner   = owner
        root.selectedRepo    = repo
        root.selectedDisplay = display
        root.issues          = []
        root.actionStatus    = ""
        fetchIssues()
    }

    function fetchIssues() {
        if (!root.selectedOwner || !root.selectedRepo) return
        issueProc.command = [root.daemonPath, "issue", "list",
            "--project", root.selectedRepo, "--output", "json"]
        issueProc.running = true
    }

    function runAction(mode, owner, repo) {
        if (root.actionBusy) return
        root.actionBusy   = true
        root.actionStatus = "Running…"
        actionProc.command = [root.daemonPath, "repo", mode.replace("--", ""), owner, repo]
        actionProc.running = true
    }

    // ── Persistent daemon (SSE + repo polling) ────────────────────────
    Process {
        id: daemonProc
        command: [root.daemonPath, "daemon", "start", "--foreground", "--shell-sync"]
        running: Config.initialized && Config.runtime.modules.dssSystems.enabled

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => root.handleLine(data)
        }
    }

    // ── One-shot: issue fetch ─────────────────────────────────────────
    Process {
        id: issueProc

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "").trim().split("\n")
                for (const line of lines)
                    root.handleLine(line)
            }
        }
    }

    // ── Bridge Health Check ───────────
    Timer {
        interval: 5000; running: true; repeat: true
        triggeredOnStart: true
        onTriggered: healthProc.running = true
    }

    Process {
        id: healthProc
        command: [
            "curl", "-sf", "--max-time", "2",
            "http://127.0.0.1:3001/health"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Health check output: " + text)
                try {
                    const result = JSON.parse(String(text || "").trim())
                    root.bridgeConnected = result.status === "ok" || result.status === "online" || !!result.uptime
                } catch (e) {
                    // fall back to daemon status if curl fails but daemon is running
                }
            }
        }
    }

    // ── One-shot: bridge actions ──────────────────────────────────────
    Process {
        id: actionProc

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "").trim().split("\n")
                for (const line of lines)
                    root.handleLine(line)
                if (root.actionBusy) {
                    root.actionBusy   = false
                    root.actionStatus = "Done"
                }
                // Refresh issues after pull
                root.fetchIssues()
            }
        }
    }

    // ── LEFT SIDEBAR PanelWindow ──────────────────────────────────────

    PanelWindow {
        id: dssSidebar

        property real panelWidth: 400

        WlrLayershell.namespace: "hype:sidebarDss"
        WlrLayershell.layer: WlrLayer.Top
        color: "transparent"
        exclusiveZone: 0
        implicitWidth: typeof Compositor !== "undefined" ? Compositor.screenW : 1920

        visible: Config.initialized
            && Globals.visiblility.sidebarDev
            && Config.runtime.modules.dssSystems.enabled

        WlrLayershell.keyboardFocus: typeof Compositor !== "undefined"
            && Compositor.require("niri")
            && Globals.visiblility.sidebarDev

        HyprlandFocusGrab {
            active: typeof Compositor !== "undefined"
                && Compositor.require("hyprland")
                && Globals.visiblility.sidebarDev
            windows: [dssSidebar]
        }

        anchors {
            top:    true
            bottom: true
            left:   true
            right:  false
        }

        margins {
            top:    Config.runtime.bar.margins
            bottom: Config.runtime.bar.margins
            left:   Metrics.margin("small")
            right:  0
        }

        // Click outside → close
        MouseArea {
            anchors.fill: parent
            z: 0
            onPressed: Globals.visiblility.sidebarDev = false
        }

        StyledRect {
            id: sidebarContainer
            z: 1
            color: Appearance.m3colors.m3background
            radius: Metrics.radius("large")
            width: dssSidebar.panelWidth

            anchors {
                top:    parent.top
                bottom: parent.bottom
                left:   parent.left
            }

            MouseArea {
                anchors.fill: parent
                onPressed: mouse.accepted = true
            }

            FocusScope {
                focus: true
                anchors.fill: parent

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape)
                        Globals.visiblility.sidebarDev = false
                }

                DssSidebarContent {
                    anchors.fill: parent

                    bridgeConnected:  root.bridgeConnected
                    repos:            root.repos
                    issues:           root.issues
                    myTasks:          root.myTasks
                    notifications:    root.notifications
                    selectedOwner:    root.selectedOwner
                    selectedRepo:     root.selectedRepo
                    selectedDisplay:  root.selectedDisplay
                    actionStatus:     root.actionStatus
                    actionBusy:       root.actionBusy

                    onRepoSelected:       (owner, repo, display) => root.selectRepo(owner, repo, display)
                    onPullClicked:        () => root.runAction("--pull",         root.selectedOwner, root.selectedRepo)
                    onDockerStartClicked: () => root.runAction("--docker-start", root.selectedOwner, root.selectedRepo)
                    onDockerStopClicked:  () => root.runAction("--docker-stop",  root.selectedOwner, root.selectedRepo)
                    onOpenDssClicked:     () => { Globals.visiblility.dssFullPanelOpen = !Globals.visiblility.dssFullPanelOpen }
                    onCloseClicked:       () => { Globals.visiblility.sidebarDev = false }
                }
            }
        }
    }

    // ── FULL PANEL — LazyLoader spawns Chromium in --app mode ───────────
    Loader {
        id: fullPanelLoader
        active: Globals.visiblility.dssFullPanelOpen && Config.initialized && Config.runtime.modules.dssSystems.enabled
        sourceComponent: Component {
            DssFullPanel {
                systemUrl: "http://localhost:3001"
                onCloseRequested: Globals.visiblility.dssFullPanelOpen = false
            }
        }
    }
}
