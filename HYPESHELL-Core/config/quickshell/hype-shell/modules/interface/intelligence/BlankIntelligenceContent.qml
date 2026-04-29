import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components

Item {
    id: root

    property bool windowMode: false

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: root.windowMode ? Metrics.margin(16) : Metrics.margin(74)
        anchors.leftMargin: Metrics.margin(16)
        anchors.rightMargin: Metrics.margin(16)
        anchors.bottomMargin: Metrics.margin(16)
        spacing: Metrics.spacing(12)

        ContentCard {
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(16)

                StyledRect {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: Metrics.radius("verylarge")
                    color: Appearance.m3colors.m3surfaceContainerHighest

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "block"
                        iconSize: Metrics.iconSize(34)
                        color: Appearance.m3colors.m3onSurfaceVariant
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(4)

                    StyledText {
                        text: "Blank"
                        font.pixelSize: Metrics.fontSize("title")
                        font.bold: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: "This slot is intentionally empty for now."
                        color: Appearance.m3colors.m3onSurfaceVariant
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                StyledButton {
                    visible: root.windowMode
                    icon: "close"
                    text: "Close"
                    onClicked: Globals.states.intelligenceWindowOpen = false
                }
            }
        }

        InfoCard {
            Layout.fillWidth: true
            icon: "info"
            title: "No AI tool configured"
            description: "The old Hype intelligence panel is disabled until you decide what should replace it."
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
