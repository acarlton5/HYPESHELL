import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    id: updatesPage

    title: "Updates"
    description: "Check for published HypeShell updates and run the installer."

    function display(value) {
        const text = String(value || "").trim()
        return text.length > 0 && text !== "NaN" ? text : "--"
    }

    function statusText() {
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

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(18)

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(14)

                Rectangle {
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72
                    radius: Metrics.radius("large")
                    color: UpdateService.updateAvailable ? Appearance.m3colors.m3errorContainer : Appearance.m3colors.m3primaryContainer

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: UpdateService.updateAvailable ? "new_releases" : "verified"
                        iconSize: Metrics.iconSize(36)
                        color: UpdateService.updateAvailable ? Appearance.m3colors.m3onErrorContainer : Appearance.m3colors.m3onPrimaryContainer
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(5)

                    StyledText {
                        Layout.fillWidth: true
                        text: updatesPage.statusText()
                        font.pixelSize: Metrics.fontSize("large")
                        font.weight: Font.Bold
                        color: UpdateService.updateAvailable ? Appearance.m3colors.m3error : Appearance.m3colors.m3onSurface
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Updates are published through acarlton5/HypeUpdater and installed from acarlton5/HYPESHELL."
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                        wrapMode: Text.WordWrap
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                StyledButton {
                    Layout.preferredWidth: 164
                    text: "Check"
                    icon: "sync"
                    secondary: true
                    enabled: !UpdateService.busy
                    onClicked: UpdateService.checkForUpdates()
                }

                StyledButton {
                    Layout.preferredWidth: 188
                    text: "Run Update"
                    icon: "system_update_alt"
                    enabled: !UpdateService.busy && UpdateService.remoteKnown
                    tooltipText: UpdateService.updateAvailable ? "Run the HypeShell installer" : "Re-run the current HypeShell installer"
                    onClicked: UpdateService.runUpdate()
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(12)

            StyledText {
                Layout.fillWidth: true
                text: "Version Details"
                font.pixelSize: Metrics.fontSize("large")
                font.weight: Font.Bold
            }

            GridLayout {
                Layout.fillWidth: true
                columns: updatesPage.width > 760 ? 2 : 1
                columnSpacing: Metrics.spacing(10)
                rowSpacing: Metrics.spacing(10)

                DetailRow { label: "Installed fingerprint"; value: UpdateService.localFingerprint }
                DetailRow { label: "Latest fingerprint"; value: UpdateService.remoteFingerprint }
                DetailRow { label: "Latest version"; value: UpdateService.remoteVersion.length > 0 ? UpdateService.remoteVersion : Config.runtime.shell.version }
                DetailRow { label: "Last checked"; value: UpdateService.lastChecked }
            }
        }
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(10)

            StyledText {
                Layout.fillWidth: true
                text: "Update Source"
                font.pixelSize: Metrics.fontSize("large")
                font.weight: Font.Bold
            }

            DetailRow { label: "Fingerprint"; value: UpdateService.fingerprintUrl }
            DetailRow { label: "Metadata"; value: UpdateService.metadataUrl }
            DetailRow { label: "Installer"; value: UpdateService.installerUrl }
        }
    }

    component DetailRow: Rectangle {
        id: detailRow

        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 56
        radius: Metrics.radius("small")
        color: Appearance.m3colors.m3surfaceContainerLow

        RowLayout {
            anchors.fill: parent
            anchors.margins: Metrics.margin("small")
            spacing: Metrics.spacing(10)

            StyledText {
                Layout.preferredWidth: 150
                text: detailRow.label
                font.pixelSize: Metrics.fontSize("smaller")
                font.weight: Font.Bold
                color: Appearance.m3colors.m3onSurfaceVariant
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: updatesPage.display(detailRow.value)
                font.pixelSize: Metrics.fontSize("smaller")
                color: Appearance.m3colors.m3onSurface
                elide: Text.ElideMiddle
            }
        }
    }
}
