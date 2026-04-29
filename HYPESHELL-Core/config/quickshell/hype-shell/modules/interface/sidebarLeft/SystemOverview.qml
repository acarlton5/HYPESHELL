import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.config
import qs.modules.components

Item {
    id: root
    anchors.fill: parent

    function display(value) {
        const text = String(value || "").trim()
        return text.length > 0 && text !== "NaN" ? text : "--"
    }

    function percent(value) {
        const numberValue = Number(value)
        if (isNaN(numberValue) || numberValue < 0)
            return "--"
        return Math.round(numberValue * 100) + "%"
    }

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
                        { icon: "memory", label: "CPU", value: root.display(SystemDetails.cpuLoad), detail: root.display(SystemDetails.cpuTemp) },
                        { icon: "developer_board", label: "RAM", value: root.percent(SystemDetails.ramPercent), detail: root.display(SystemDetails.ramUsage) },
                        { icon: "hard_drive", label: "Disk", value: root.percent(SystemDetails.diskPercent), detail: root.display(SystemDetails.diskUsage) },
                        { icon: "schedule", label: "Uptime", value: root.display(SystemDetails.uptime), detail: root.display(SystemDetails.ipAddress) }
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
                            anchors.bottom: metricDetail.top
                            text: modelData.value || "--"
                            font.pixelSize: Metrics.fontSize("large")
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        StyledText {
                            id: metricDetail
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Metrics.margin("normal")
                            anchors.rightMargin: Metrics.margin("normal")
                            anchors.bottom: metricLabel.top
                            text: modelData.detail || "--"
                            font.pixelSize: Metrics.fontSize("small")
                            color: Appearance.m3colors.m3onSurfaceVariant
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
                        text: root.display(SystemDetails.osName) === "--" ? "Linux" : SystemDetails.osName
                        font.pixelSize: Metrics.fontSize("large")
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: root.display(SystemDetails.kernelVersion) + " - " + root.display(SystemDetails.architecture)
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
