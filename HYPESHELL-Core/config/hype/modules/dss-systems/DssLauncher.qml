/**
 * DssLauncher.qml — DSS Workspace launcher tile.
 * Shows bridge status + notification count. Click → open DSS sidebar.
 */

import qs.config
import qs.modules.components
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

StyledRect {
    id: root
    width: 200
    height: 80
    radius: Metrics.radius("verylarge")
    color: connected
        ? Appearance.m3colors.m3primaryContainer
        : Appearance.m3colors.m3surfaceContainerHigh

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    property bool   connected:     false
    property int    notifCount:    0
    property int    repoCount:     0

    readonly property string daemonPath: "/run/media/morph/DATA/projects/DSS-System/server/bin/dark-factory"

    // Quick status poll — runs every 5s
    Process {
        id: statusProc
        command: [root.daemonPath, "version"]

        stdout: StdioCollector {
            onStreamFinished: {
                // Just checking if daemon exists and is executable
            }
        }
    }

    // Lightweight connectivity check via a curl to the bridge health endpoint
    Process {
        id: healthProc
        command: [
            "curl", "-sf", "--max-time", "2",
            (Config.runtime.modules.dss-systems.bridgeUrl || "http://localhost:8080") + "/health"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(String(text || "").trim())
                    root.connected = result.status === "ok" || result.status === "online" || !!result.uptime
                } catch (e) {
                    root.connected = String(text || "").trim().length > 0
                }
            }
        }

        onRunningChanged: {
            if (!running) root.connected = false
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!healthProc.running)
                healthProc.running = true
        }
    }

    // ── Icon ──────────────────────────────────────────────────────────
    StyledRect {
        id: iconBg
        width: 50; height: 50
        radius: Metrics.radius("verylarge")
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Metrics.margin("small")
        color: root.connected
            ? Appearance.m3colors.m3primary
            : Appearance.m3colors.m3secondaryContainer

        MaterialSymbol {
            anchors.centerIn: parent
            iconSize: Metrics.iconSize(30)
            icon: "hub"
            color: root.connected
                ? Appearance.m3colors.m3onPrimary
                : Appearance.m3colors.m3onSecondaryContainer
        }
    }

    // ── Labels ────────────────────────────────────────────────────────
    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: iconBg.right
        anchors.leftMargin: Metrics.margin("small")
        anchors.right: parent.right
        anchors.rightMargin: Metrics.margin("small")
        spacing: Metrics.spacing(2)

        StyledText {
            text: "DSS Systems"
            font.pixelSize: Metrics.fontSize("large")
            elide: Text.ElideRight
            width: parent.width
        }

        StyledText {
            text: root.connected ? "Bridge connected" : "Bridge offline"
            font.pixelSize: Metrics.fontSize("small")
            color: root.connected
                ? Appearance.m3colors.m3onPrimaryContainer
                : Appearance.m3colors.m3onSurfaceVariant
            elide: Text.ElideRight
            width: parent.width
        }
    }

    // ── Click handler ─────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            Globals.visiblility.sidebarRight = false
            Globals.visiblility.sidebarLeft  = false
            Globals.visiblility.sidebarDev   = true
        }
    }
}
