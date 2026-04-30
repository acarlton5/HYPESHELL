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
        contentHeight: contentLayout.implicitHeight + Metrics.margin("verylarge")
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
                spacing: Metrics.spacing(6)

                StyledText {
                    Layout.fillWidth: true
                    text: "HYPESHELL"
                    font.pixelSize: Metrics.fontSize("hugeass")
                    font.weight: Font.Black
                    color: Appearance.m3colors.m3primary
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: SystemDetails.username + "@" + SystemDetails.hostname
                    font.pixelSize: Metrics.fontSize("large")
                    color: Appearance.m3colors.m3onSurfaceVariant
                    elide: Text.ElideMiddle
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.width >= 500 ? 2 : 1
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
                        Layout.preferredHeight: 104
                        radius: Metrics.radius("normal")
                        color: Appearance.m3colors.m3surfaceContainer

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Metrics.margin("small")
                            spacing: Metrics.spacing(10)

                            Rectangle {
                                Layout.preferredWidth: 44
                                Layout.preferredHeight: 44
                                Layout.alignment: Qt.AlignTop
                                radius: Metrics.radius("normal")
                                color: Appearance.m3colors.m3primaryContainer

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    icon: modelData.icon
                                    iconSize: Metrics.iconSize(25)
                                    color: Appearance.m3colors.m3onPrimaryContainer
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: Metrics.spacing(3)

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    font.pixelSize: Metrics.fontSize("small")
                                    font.weight: Font.Bold
                                    color: Appearance.m3colors.m3onSurfaceVariant
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.value || "--"
                                    font.pixelSize: Metrics.fontSize("large")
                                    font.weight: Font.Bold
                                    color: Appearance.m3colors.m3onSurface
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.detail || "--"
                                    font.pixelSize: Metrics.fontSize("small")
                                    color: Appearance.m3colors.m3onSurfaceVariant
                                    elide: Text.ElideMiddle
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: root.width >= 420 ? 176 : 220
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
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Metrics.spacing(2)
                        columns: root.width >= 420 ? 2 : 1
                        columnSpacing: Metrics.spacing(10)
                        rowSpacing: Metrics.spacing(8)

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
