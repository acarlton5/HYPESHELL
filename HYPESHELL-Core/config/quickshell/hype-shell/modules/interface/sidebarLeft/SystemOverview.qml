import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.config
import qs.modules.components

Item {
    id: root
    anchors.fill: parent

    Flickable {
        anchors.fill: parent
        contentHeight: contentLayout.implicitHeight + 140
        clip: true
        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: contentLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Metrics.margin("small")
            anchors.rightMargin: Metrics.margin("small")
            anchors.topMargin: 100
            anchors.top: parent.top
            spacing: Metrics.margin("normal")

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(4)

                StyledText {
                    text: "HYPESHELL"
                    font.pixelSize: Metrics.fontSize("hugeass")
                    font.weight: Font.Black
                    color: Appearance.m3colors.m3primary
                }

                StyledText {
                    text: SystemDetails.username + "@" + SystemDetails.hostname
                    font.pixelSize: Metrics.fontSize("large")
                    color: Appearance.m3colors.m3onSurfaceVariant
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: Metrics.spacing(10)
                rowSpacing: Metrics.spacing(10)

                Repeater {
                    model: [
                        { icon: "memory", label: "CPU", value: SystemDetails.cpuLoad },
                        { icon: "developer_board", label: "RAM", value: SystemDetails.ramUsage },
                        { icon: "hard_drive", label: "Disk", value: SystemDetails.diskUsage },
                        { icon: "schedule", label: "Uptime", value: SystemDetails.uptime }
                    ]

                    StyledRect {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 96
                        radius: Metrics.radius("normal")
                        color: Appearance.m3colors.m3surfaceContainer

                        MaterialSymbol {
                            id: metricIcon
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: Metrics.margin("normal")
                            anchors.topMargin: Metrics.margin("normal")
                            icon: modelData.icon
                            iconSize: Metrics.iconSize(28)
                            color: Appearance.m3colors.m3primary
                        }

                        StyledText {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Metrics.margin("normal")
                            anchors.rightMargin: Metrics.margin("normal")
                            anchors.bottom: metricLabel.top
                            text: modelData.value || "--"
                            font.pixelSize: Metrics.fontSize("large")
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        StyledText {
                            id: metricLabel
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: Metrics.margin("normal")
                            anchors.bottomMargin: Metrics.margin("normal")
                            text: modelData.label
                            font.pixelSize: Metrics.fontSize("small")
                            color: Appearance.m3colors.m3onSurfaceVariant
                        }
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 132
                radius: Metrics.radius("normal")
                color: Appearance.m3colors.m3surfaceContainer

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Metrics.margin("normal")
                    spacing: Metrics.spacing(10)

                    StyledText {
                        text: SystemDetails.osName || "Linux"
                        font.pixelSize: Metrics.fontSize("large")
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: SystemDetails.kernelVersion + " - " + SystemDetails.architecture
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.spacing(10)

                        StyledButton {
                            Layout.fillWidth: true
                            text: "Settings"
                            icon: "settings"
                            secondary: true
                            onClicked: HypeActions.toggleSettings()
                        }

                        StyledButton {
                            Layout.fillWidth: true
                            text: "Wallpaper"
                            icon: "wallpaper"
                            secondary: true
                            onClicked: HypeActions.changeWallpaper()
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }
        }
    }
}
