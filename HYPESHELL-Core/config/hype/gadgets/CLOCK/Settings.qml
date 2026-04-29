import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components

ColumnLayout {
    Layout.fillWidth: true
    spacing: Metrics.spacing(8)

    StyledSwitchOption {
        title: "Analog Mode"
        description: "Use analog mode. Disable for digital mode."
        prefField: "appearance.background.clock.isAnalog"
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
        description: "Rotate the analog polygon background."
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
        enabled: Config.runtime.appearance.background.clock.isAnalog
        opacity: enabled ? 1 : 0.8
    }

    RowLayout {
        Layout.fillWidth: true
        enabled: Config.runtime.appearance.background.clock.isAnalog
        opacity: enabled ? 1 : 0.8

        ColumnLayout {
            StyledText {
                text: "Clock Shape"
                font.pixelSize: Metrics.fontSize("normal")
            }
            StyledText {
                text: "Pick the analog polygon shape."
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }

        Item { Layout.fillWidth: true }

        StyledDropDown {
            label: "Shape Type"
            model: ["Cookie 7 Sided", "Cookie 9 Sided", "Cookie 12 Sided", "Pixel Circle", "Circle", "Ghostish"]
            currentIndex: Number(Config.runtime.appearance.background.clock.shape)
            onSelectedIndexChanged: function(index) {
                Config.updateKey("appearance.background.clock.shape", index)
            }
        }
    }
}
