import qs.config
import qs.modules.components
import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts

StyledRect {
    id: root
    width: 200
    height: 80
    radius: Metrics.radius("verylarge")
    color: devRunning
        ? Appearance.m3colors.m3primaryContainer
        : (devReady
            ? Appearance.m3colors.m3secondaryContainer
            : Appearance.m3colors.m3surfaceContainerHigh)

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    property bool devReady: false
    property bool devRunning: false
    property int runningCount: 0
    property string devRoot: ""

    function refreshStatus() {
        if (!statusProc.running)
            statusProc.running = true
        if (!drivesProc.running)
            drivesProc.running = true
    }

    Process {
        id: statusProc
        command: [Quickshell.env("HOME") + "/.local/share/bin/devusb-launch.sh", "--status"]

        stdout: StdioCollector {
            onStreamFinished: {
                const line = String(text || "").trim()
                const parts = line.split("\t")
                root.runningCount = parts.length > 3 ? Math.max(0, Number(parts[3]) || 0) : 0
                root.devRunning = root.runningCount > 0
            }
        }
    }

    Process {
        id: drivesProc
        command: [Quickshell.env("HOME") + "/.local/share/bin/devusb-launch.sh", "--list-drives"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "")
                    .split("\n")
                    .map(l => l.trim())
                    .filter(l => l.length > 0)

                root.devReady = lines.length > 0
                if (!root.devReady) {
                    root.devRoot = ""
                    return
                }

                const first = lines[0].split("\t")
                root.devRoot = first.length > 0 ? String(first[0] || "").trim() : ""
            }
        }
    }

    Timer {
        interval: 3500
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refreshStatus()
    }

    StyledRect {
        id: iconBg
        width: 50
        height: 50
        radius: Metrics.radius("verylarge")
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Metrics.margin("small")
        color: devRunning
            ? Appearance.m3colors.m3primary
            : (devReady
                ? Appearance.m3colors.m3primary
                : Appearance.m3colors.m3secondaryContainer)

        MaterialSymbol {
            anchors.centerIn: parent
            iconSize: Metrics.iconSize(35)
            icon: "terminal"
        }
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: iconBg.right
        anchors.leftMargin: Metrics.margin("small")
        spacing: Metrics.spacing(2)

        StyledText {
            text: "Developer"
            font.pixelSize: Metrics.fontSize("large")
            elide: Text.ElideRight
            width: root.width - iconBg.width - 30
        }

        StyledText {
            text: devRunning
                ? "Compose running"
                : (devReady
                    ? "USB drive attached"
                    : "No USB drive")
            font.pixelSize: Metrics.fontSize("small")
            color: devRunning ? Appearance.m3colors.m3onPrimary : Appearance.m3colors.m3onSurfaceVariant
            elide: Text.ElideRight
            width: root.width - iconBg.width - 30
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                if (devRoot.length > 0)
                    Quickshell.execDetached(["dolphin", devRoot])
                return
            }
            Globals.visiblility.sidebarRight = false
            Globals.visiblility.sidebarLeft = false
            Globals.visiblility.sidebarDev = true
        }
    }
}
