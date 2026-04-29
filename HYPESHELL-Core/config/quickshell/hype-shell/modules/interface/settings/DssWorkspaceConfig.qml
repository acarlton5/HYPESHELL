import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.components

ContentMenu {
    id: dssSettings
    title: "DSS Systems"
    description: "Configure your DSS Systems workspace."

    ContentCard {
        StyledSwitchOption {
            title: "Enabled"
            description: "Enable the DSS Systems workspace module."
            prefField: "modules.dssSystems.enabled"
        }
    }

    ContentCard {
        StyledText {
            text: "Keyboard Shortcut"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledText {
            text: "Super + Shift + D"
            font.pixelSize: Metrics.fontSize(16)
            color: Appearance.m3colors.m3primary
        }

        StyledText {
            text: "Toggles the DSS Systems dashboard expansion."
            font.pixelSize: Metrics.fontSize(12)
            color: Appearance.m3colors.m3onSurfaceVariant
        }
    }
}
