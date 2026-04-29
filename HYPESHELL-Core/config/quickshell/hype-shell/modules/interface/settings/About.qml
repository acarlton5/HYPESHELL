import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.components
import Quickshell

ContentMenu {
    title: "About"
    description: "System Information and Shell Updates"

    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(12)

            StyledText {
                text: "HYPE Shell 2.0"
                font.pixelSize: Metrics.fontSize(24)
                font.weight: Font.Bold
                color: Appearance.colors.colPrimary
            }

            ColumnLayout {
                spacing: 2
                StyledText {
                    text: `Version: ${Config.runtime.shell.version}`
                    font.pixelSize: Metrics.fontSize(14)
                }
                StyledText {
                    text: "Local Build: " + UpdateService.localFingerprint
                    font.pixelSize: Metrics.fontSize(12)
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }

    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(16)

            ColumnLayout {
                spacing: Metrics.spacing(4)
                StyledText {
                    text: "Software Update"
                    font.pixelSize: Metrics.fontSize(18)
                    font.bold: true
                }
                StyledText {
                    text: "Keep your shell up to date with the latest features and fixes."
                    font.pixelSize: Metrics.fontSize(12)
                    color: Appearance.m3colors.m3onSurfaceVariant
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.margin("normal")

                ColumnLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: UpdateService.status !== "Idle" ? UpdateService.status : (UpdateService.updateAvailable ? "A new version is available!" : "Your shell is up to date.")
                        font.pixelSize: Metrics.fontSize(14)
                        color: UpdateService.updateAvailable ? Appearance.m3colors.m3error : Appearance.m3colors.m3onSurface
                    }
                    StyledText {
                        text: "Remote Build: " + UpdateService.remoteFingerprint
                        font.pixelSize: Metrics.fontSize(10)
                        color: Appearance.colors.colSubtext
                    }
                }

                StyledButton {
                    id: updateBtn
                    text: UpdateService.updateAvailable ? "Update Now" : "Check"
                    icon: "system_update"
                    primary: UpdateService.updateAvailable
                    
                    onClicked: {
                        if (UpdateService.updateAvailable) {
                            HypeActions.runUpdate();
                        } else {
                            HypeActions.refreshUpdateStatus();
                        }
                    }

                    // Pulse animation if update available
                    SequentialAnimation on opacity {
                        running: UpdateService.updateAvailable
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.6; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.6; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }
    }

    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(8)

            StyledText {
                text: "Diagnostic Info"
                font.pixelSize: Metrics.fontSize(16)
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Appearance.m3colors.m3outlineVariant
            }

            Grid {
                columns: 2
                spacing: 20
                Layout.fillWidth: true

                Column {
                    StyledText { text: "Update Engine"; font.bold: true; font.pixelSize: 10 }
                    StyledText { text: UpdateService.status; font.pixelSize: 10; color: Appearance.colors.colSubtext }
                }
                Column {
                    StyledText { text: "Availability"; font.bold: true; font.pixelSize: 10 }
                    StyledText { text: UpdateService.updateAvailable ? "YES" : "NO"; font.pixelSize: 10; color: Appearance.colors.colSubtext }
                }
            }
        }
    }
}
