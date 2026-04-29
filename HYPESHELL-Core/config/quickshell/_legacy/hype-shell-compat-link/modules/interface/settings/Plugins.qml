import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.plugins

ContentMenu {
    title: "Plugins"
    description: "Modify and Customize Installed Plugins."

    ContentCard {
        Layout.fillWidth: true

        StyledText {
            text: "Clock Widget"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledText {
            text: "Built-in gadget path: ~/.config/hype/gadgets/CLOCK"
            wrapMode: Text.WrapAnywhere
            font.pixelSize: Metrics.fontSize("small")
            color: Appearance.m3colors.m3onSurfaceVariant
        }

        StyledSwitchOption {
            title: "Show Clock"
            description: "Show or hide the desktop clock widget."
            prefField: "appearance.background.clock.enabled"
        }

        StyledSwitchOption {
            title: "Analog Mode"
            description: "Use analog mode. Disable for digital mode."
            prefField: "appearance.background.clock.isAnalog"
        }

        NumberStepper {
            label: "X Position"
            description: "Horizontal position in pixels."
            prefField: "appearance.background.clock.xPos"
            minimum: 0
            maximum: 8000
            step: 10
        }

        NumberStepper {
            label: "Y Position"
            description: "Vertical position in pixels."
            prefField: "appearance.background.clock.yPos"
            minimum: 0
            maximum: 8000
            step: 10
        }

        NumberStepper {
            label: "Edge Spacing"
            description: "Padding from display edges."
            prefField: "appearance.background.clock.edgeSpacing"
            minimum: 0
            maximum: 500
            step: 5
        }

        StyledSwitchOption {
            title: "Rotate Polygon"
            description: "Rotate the analog clock polygon background."
            prefField: "appearance.background.clock.rotatePolygonBg"
            enabled: Config.runtime.appearance.background.clock.isAnalog
            opacity: enabled ? 1 : 0.8
        }

        NumberStepper {
            label: "Rotation Duration"
            description: "Seconds for one full polygon rotation."
            prefField: "appearance.background.clock.rotationDuration"
            minimum: 1
            maximum: 120
            step: 1
        }

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                StyledText {
                    text: "Analog Clock Shape"
                    font.pixelSize: Metrics.fontSize(16)
                }

                StyledText {
                    text: "Choose the analog clock shape."
                    font.pixelSize: Metrics.fontSize(12)
                }
            }

            Item { Layout.fillWidth: true }

            StyledDropDown {
                label: "Shape Type"
                model: ["Cookie 7 Sided", "Cookie 9 Sided", "Cookie 12 Sided", "Pixel Circle", "Circle", "Ghostish"]
                currentIndex: Config.runtime.appearance.background.clock.shape

                onSelectedIndexChanged: (index) => {
                    Config.updateKey("appearance.background.clock.shape", index)
                }
            }
        }
    }

    ContentCard {
        Layout.fillWidth: true
        Layout.preferredHeight: implicitHeight
        color: "transparent"

        GridLayout {
            id: grid
            columns: 1
            Layout.fillWidth: true
            columnSpacing: Metrics.spacing(16)
            rowSpacing: Metrics.spacing(16)

            StyledText {
                text: "Plugins not found!"
                font.pixelSize: Metrics.fontSize(20)
                font.bold: true
                visible: PluginLoader.plugins.length === 0
                Layout.alignment: Qt.AlignHCenter
            }

            Repeater {
                model: PluginLoader.plugins

                delegate: ContentCard {
                    Layout.fillWidth: true

                    Loader {
                        Layout.fillWidth: true
                        asynchronous: true
                        source: Qt.resolvedUrl(
                            Directories.shellConfig + "/plugins/" + modelData + "/Settings.qml"
                        )
                    }
                }
            }
        }
    }
}
