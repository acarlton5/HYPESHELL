import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    title: "Bar"
    description: "Manage the system bar configuration."

    ContentCard {
        StyledText {
            text: "General"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledSwitchOption {
            title: "Enabled"
            description: "Enable or disable the system bar."
            prefField: "bar.enabled"
        }

        ColumnLayout {
            spacing: Metrics.spacing(8)
            Layout.fillWidth: true

            StyledText {
                text: "Position"
                font.pixelSize: Metrics.fontSize(16)
                font.bold: true
            }

            RowLayout {
                spacing: Metrics.spacing(8)
                Layout.fillWidth: true

                Repeater {
                    model: ["Top", "Bottom", "Left", "Right"]

                    delegate: StyledButton {
                        property string pos: modelData.toLowerCase()
                        text: modelData
                        Layout.fillWidth: true
                        checked: Config.runtime.bar.position === pos
                        onClicked: Config.updateKey("bar.position", pos)
                    }
                }
            }
        }
    }

}
