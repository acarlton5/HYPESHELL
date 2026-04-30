import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.components

ContentMenu {
    id: aboutPage

    title: "About"
    description: "System information and HypeShell updates"

    function display(value) {
        const text = String(value || "").trim()
        return text.length > 0 && text !== "NaN" ? text : "--"
    }

    function updateStatusText() {
        if (UpdateService.status !== "Idle")
            return UpdateService.status
        if (UpdateService.errorText.length > 0)
            return UpdateService.errorText
        if (!UpdateService.remoteKnown)
            return "Unable to compare versions"
        if (!UpdateService.localKnown)
            return "Installed version unknown"
        return UpdateService.updateAvailable ? "Update available" : "HypeShell is up to date"
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(18)

            Rectangle {
                Layout.preferredWidth: 84
                Layout.preferredHeight: 84
                Layout.alignment: Qt.AlignTop
                radius: Metrics.radius("large")
                color: Appearance.m3colors.m3primaryContainer

                StyledText {
                    anchors.centerIn: parent
                    text: SystemDetails.osIcon || "H"
                    font.pixelSize: 40
                    font.weight: Font.Black
                    color: Appearance.m3colors.m3onPrimaryContainer
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(6)

                StyledText {
                    Layout.fillWidth: true
                    text: "HypeShell"
                    font.pixelSize: Metrics.fontSize("hugeass")
                    font.weight: Font.Black
                    color: Appearance.m3colors.m3primary
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: aboutPage.display(SystemDetails.username) + "@" + aboutPage.display(SystemDetails.hostname)
                    font.pixelSize: Metrics.fontSize("large")
                    color: Appearance.m3colors.m3onSurface
                    elide: Text.ElideMiddle
                }

                StyledText {
                    Layout.fillWidth: true
                    text: aboutPage.display(SystemDetails.osName)
                    font.pixelSize: Metrics.fontSize("normal")
                    color: Appearance.m3colors.m3onSurfaceVariant
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(12)

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: Metrics.radius("normal")
                color: UpdateService.updateAvailable ? Appearance.m3colors.m3errorContainer : Appearance.m3colors.m3primaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    icon: UpdateService.updateAvailable ? "new_releases" : "verified"
                    iconSize: Metrics.iconSize(28)
                    color: UpdateService.updateAvailable ? Appearance.m3colors.m3onErrorContainer : Appearance.m3colors.m3onPrimaryContainer
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(3)

                StyledText {
                    Layout.fillWidth: true
                    text: "HypeShell Update"
                    font.pixelSize: Metrics.fontSize("large")
                    font.weight: Font.Bold
                    color: Appearance.m3colors.m3onSurface
                }

                StyledText {
                    Layout.fillWidth: true
                    text: aboutPage.updateStatusText()
                    font.pixelSize: Metrics.fontSize("normal")
                    color: UpdateService.updateAvailable ? Appearance.m3colors.m3error : Appearance.m3colors.m3onSurfaceVariant
                    elide: Text.ElideRight
                }
            }

            UpdateButton {
                Layout.preferredWidth: UpdateService.updateAvailable ? 132 : 116
                enabled: !UpdateService.busy
                isUpdateAvailable: UpdateService.updateAvailable
                text: UpdateService.updateAvailable ? "Update" : "Check"
                icon: UpdateService.updateAvailable ? "system_update_alt" : "sync"
                onClicked: {
                    if (UpdateService.updateAvailable)
                        UpdateService.runUpdate()
                    else
                        UpdateService.checkForUpdates()
                }
            }
        }
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(14)

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                MaterialSymbol {
                    icon: "terminal"
                    iconSize: Metrics.iconSize(24)
                    color: Appearance.m3colors.m3primary
                }

                StyledText {
                    Layout.fillWidth: true
                    text: "System"
                    font.pixelSize: Metrics.fontSize("large")
                    font.weight: Font.Bold
                    color: Appearance.m3colors.m3onSurface
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: aboutPage.width > 900 ? 3 : (aboutPage.width > 560 ? 2 : 1)
                columnSpacing: Metrics.spacing(10)
                rowSpacing: Metrics.spacing(10)

                InfoTile { label: "OS"; value: aboutPage.display(SystemDetails.osName); icon: "desktop_windows" }
                InfoTile { label: "Kernel"; value: aboutPage.display(SystemDetails.kernelVersion); icon: "memory" }
                InfoTile { label: "Arch"; value: aboutPage.display(SystemDetails.architecture); icon: "developer_board" }
                InfoTile { label: "Uptime"; value: aboutPage.display(SystemDetails.uptime); icon: "schedule" }
                InfoTile { label: "Processes"; value: String(SystemDetails.runningProcesses || "--"); icon: "account_tree" }
                InfoTile { label: "Users"; value: String(SystemDetails.loggedInUsers || "--"); icon: "group" }
                InfoTile { label: "CPU"; value: aboutPage.display(SystemDetails.cpuLoad) + " / " + aboutPage.display(SystemDetails.cpuTemp); icon: "speed" }
                InfoTile { label: "RAM"; value: aboutPage.display(SystemDetails.ramUsage); icon: "memory_alt" }
                InfoTile { label: "Disk"; value: aboutPage.display(SystemDetails.diskUsage); icon: "hard_drive" }
                InfoTile { label: "Swap"; value: aboutPage.display(SystemDetails.swapUsage); icon: "swap_horiz" }
                InfoTile { label: "IP"; value: aboutPage.display(SystemDetails.ipAddress); icon: "lan" }
                InfoTile { label: "Quickshell"; value: aboutPage.display(SystemDetails.qsVersion); icon: "bolt" }
            }
        }
    }

    component InfoTile: Rectangle {
        id: tile
        property string label: ""
        property string value: ""
        property string icon: "info"

        Layout.fillWidth: true
        Layout.preferredHeight: 76
        radius: Metrics.radius("normal")
        color: Appearance.m3colors.m3surfaceContainer

        RowLayout {
            anchors.fill: parent
            anchors.margins: Metrics.margin("small")
            spacing: Metrics.spacing(8)

            MaterialSymbol {
                Layout.preferredWidth: 28
                icon: tile.icon
                iconSize: Metrics.iconSize(22)
                color: Appearance.m3colors.m3primary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(2)

                StyledText {
                    Layout.fillWidth: true
                    text: tile.label
                    font.pixelSize: Metrics.fontSize("smaller")
                    font.weight: Font.Bold
                    color: Appearance.m3colors.m3onSurfaceVariant
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: tile.value
                    font.pixelSize: Metrics.fontSize("small")
                    color: Appearance.m3colors.m3onSurface
                    elide: Text.ElideMiddle
                }
            }
        }
    }

    component UpdateButton: Rectangle {
        id: updateButton
        property string text: "Check"
        property string icon: "sync"
        property bool isUpdateAvailable: false

        signal clicked()

        implicitHeight: 40
        radius: Metrics.radius("large")
        color: !enabled
            ? Appearance.m3colors.m3surfaceContainerHighest
            : isUpdateAvailable ? Appearance.m3colors.m3error : Appearance.m3colors.m3primary
        opacity: enabled ? 1 : 0.55

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Metrics.margin("normal")
            anchors.rightMargin: Metrics.margin("normal")
            spacing: Metrics.spacing(6)

            MaterialSymbol {
                icon: updateButton.icon
                iconSize: Metrics.iconSize(20)
                color: updateButton.isUpdateAvailable ? Appearance.m3colors.m3onError : Appearance.m3colors.m3onPrimary
            }

            StyledText {
                text: updateButton.text
                font.pixelSize: Metrics.fontSize("small")
                font.weight: Font.Bold
                color: updateButton.isUpdateAvailable ? Appearance.m3colors.m3onError : Appearance.m3colors.m3onPrimary
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: updateButton.enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            onClicked: updateButton.clicked()
        }
    }
}
