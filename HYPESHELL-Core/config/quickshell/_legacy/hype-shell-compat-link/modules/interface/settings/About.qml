import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.components
import qs.modules.functions
import qs.services

Item {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true

    property string monoFont: Metrics.fontFamily("monospace")
    property string shellVersion: "Hype Shell v0.0.1"
    property string hostLine: (SystemDetails.username || "user") + "@" + (SystemDetails.hostname || "host")
    property string iconText: (SystemDetails.osIcon && SystemDetails.osIcon.length > 0) ? SystemDetails.osIcon : "󰣇"
    property string updateScript: Quickshell.env("HOME") + "/.local/share/bin/systemupdate.sh"
    property int pendingUpdates: -1
    property bool updateHover: false
    property string updateStatusText: "Checking for updates..."

    property color clrBase: "#0b0d10"
    property color clrCard: "#12161d"
    property color clrCardAlt: "#171c25"
    property color clrRowA: "#151a22"
    property color clrRowB: "#1a202a"
    property color clrText: "#edf2f8"
    property color clrMuted: "#aab4c2"
    property color clrAccent: Appearance.m3colors.m3primary
    property color clrBorder: "#232a35"

    property var fetchRows: [
        { key: "OS", value: SystemDetails.osName || "—" },
        { key: "Host", value: SystemDetails.hostname || "—" },
        { key: "Kernel", value: SystemDetails.kernelVersion || "—" },
        { key: "Arch", value: SystemDetails.architecture || "—" },
        { key: "Uptime", value: SystemDetails.uptime || "—" },
        { key: "CPU", value: (SystemDetails.cpuLoad || "—") + "  " + (SystemDetails.cpuTemp || "—") },
        { key: "RAM", value: SystemDetails.ramUsage || "—" },
        { key: "Swap", value: SystemDetails.swapUsage || "—" },
        { key: "Disk", value: SystemDetails.diskUsage || "—" },
        { key: "IP", value: SystemDetails.ipAddress || "—" },
        { key: "Processes", value: String(SystemDetails.runningProcesses || 0) },
        { key: "Users", value: String(SystemDetails.loggedInUsers || 0) },
        { key: "Keyboard", value: SystemDetails.keyboardLayout || "—" },
        { key: "Quickshell", value: SystemDetails.qsVersion || "—" },
        { key: "Shell", value: shellVersion }
    ]

    function parseUpdateCount(raw) {
        const line = String(raw || "").trim()
        if (!line.length)
            return 0

        try {
            const obj = JSON.parse(line)
            const text = String(obj.text || "").trim()
            const match = text.match(/(\d+)/)
            return match ? Number(match[1]) || 0 : 0
        } catch (e) {
            const fallback = line.match(/(\d+)/)
            return fallback ? Number(fallback[1]) || 0 : 0
        }
    }

    function refreshUpdateStatus() {
        if (updateCheckProc.running)
            return
        updateCheckProc.running = true
    }

    Component.onCompleted: refreshUpdateStatus()

    Timer {
        interval: 20 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refreshUpdateStatus()
    }

    Process {
        id: updateCheckProc
        command: [root.updateScript]

        stdout: StdioCollector {
            onStreamFinished: {
                const count = root.parseUpdateCount(text)
                root.pendingUpdates = count
                if (count > 0)
                    root.updateStatusText = `${count} updates available`
                else
                    root.updateStatusText = "System up to date"
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.clrBase
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.margin(22)
        spacing: Metrics.spacing(12)

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 184
            radius: Appearance.rounding.large
            color: root.clrCard
            border.width: 1
            border.color: root.clrBorder

            RowLayout {
                anchors.fill: parent
                anchors.margins: Metrics.margin(16)
                spacing: Metrics.spacing(16)

                StyledRect {
                    Layout.preferredWidth: 132
                    Layout.preferredHeight: 132
                    radius: Appearance.rounding.verylarge
                    color: root.clrCardAlt
                    border.width: 1
                    border.color: root.clrBorder

                    StyledText {
                        anchors.centerIn: parent
                        text: root.iconText
                        font.pixelSize: Metrics.fontSize(98)
                        color: root.clrAccent
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Metrics.spacing(4)

                    StyledText {
                        text: root.hostLine
                        font.family: root.monoFont
                        font.pixelSize: Metrics.fontSize(24)
                        color: root.clrText
                    }

                    StyledText {
                        text: SystemDetails.osName || "Linux"
                        font.pixelSize: Metrics.fontSize(14)
                        color: root.clrMuted
                    }

                    StyledText {
                        text: root.shellVersion
                        font.family: root.monoFont
                        font.pixelSize: Metrics.fontSize(12)
                        color: root.clrMuted
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        spacing: Metrics.spacing(12)

                        Repeater {
                            model: [
                                "Kernel " + (SystemDetails.kernelVersion || "—"),
                                "Arch " + (SystemDetails.architecture || "—"),
                                SystemDetails.uptime || "—"
                            ]

                            delegate: Row {
                                required property string modelData
                                spacing: 6

                                Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: root.clrAccent
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: modelData
                                    font.family: root.monoFont
                                    font.pixelSize: Metrics.fontSize(12)
                                    color: root.clrMuted
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.large
            color: root.clrCard
            border.width: 1
            border.color: root.clrBorder

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Metrics.margin(14)
                spacing: Metrics.spacing(8)

                StyledText {
                    text: "System Snapshot"
                    font.pixelSize: Metrics.fontSize(15)
                    color: root.clrMuted
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: width > 760 ? 2 : 1
                    columnSpacing: Metrics.spacing(10)
                    rowSpacing: Metrics.spacing(8)

                    Repeater {
                        model: root.fetchRows

                        delegate: StyledRect {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 8
                            color: index % 2 === 0 ? root.clrRowA : root.clrRowB
                            border.width: 1
                            border.color: root.clrBorder

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Metrics.margin(12)
                                anchors.rightMargin: Metrics.margin(12)
                                spacing: Metrics.spacing(8)

                                StyledText {
                                    Layout.preferredWidth: 95
                                    text: modelData.key
                                    font.family: root.monoFont
                                    font.pixelSize: Metrics.fontSize(12)
                                    color: root.clrMuted
                                }

                                Rectangle {
                                    Layout.preferredWidth: 1
                                    Layout.preferredHeight: 16
                                    color: root.clrBorder
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.value
                                    font.family: root.monoFont
                                    font.pixelSize: Metrics.fontSize(12)
                                    color: root.clrText
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    StyledRect {
        width: 52
        height: 52
        radius: Appearance.rounding.small
        color: root.pendingUpdates > 0
            ? (root.updateHover ? Qt.lighter(root.clrAccent, 1.08) : root.clrAccent)
            : (root.updateHover ? root.clrRowA : root.clrRowB)
        border.width: 1
        border.color: root.pendingUpdates > 0 ? Qt.lighter(root.clrAccent, 1.15) : root.clrBorder

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Metrics.margin(24)

        MaterialSymbol {
            anchors.centerIn: parent
            icon: "system_update_alt"
            iconSize: Metrics.iconSize(24)
            color: root.pendingUpdates > 0 ? root.clrBase : root.clrText
        }

        StyledRect {
            visible: root.pendingUpdates > 0
            width: 18
            height: 18
            radius: 9
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2
            color: root.clrText

            StyledText {
                anchors.centerIn: parent
                text: root.pendingUpdates > 99 ? "99+" : String(root.pendingUpdates)
                color: root.clrBase
                font.pixelSize: Metrics.fontSize(9)
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: root.updateHover = true
            onExited: root.updateHover = false

            onClicked: {
                Quickshell.execDetached([root.updateScript, "up"])
                refreshUpdateStatus()
            }
        }
    }
}
