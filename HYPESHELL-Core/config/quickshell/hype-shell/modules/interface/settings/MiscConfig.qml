import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.modules.components

ContentMenu {
    title: "Miscellaneous"
    description: "Configure various shell settings."

    ContentCard {
        StyledText {
            text: "User Profile"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledText {
            text: "Profile Picture Path"
            font.pixelSize: Metrics.fontSize(14)
            color: Appearance.m3colors.m3onSurfaceVariant
        }

        StyledText {
            text: Config.runtime.misc.pfp
            font.family: Metrics.fontFamily("monospace")
            font.pixelSize: Metrics.fontSize(12)
            color: Appearance.m3colors.m3primary
        }
        
        StyledText {
            text: "To change your PFP, place a file at ~/.face.icon or update the config manually."
            font.pixelSize: Metrics.fontSize(11)
            color: Appearance.m3colors.m3onSurfaceVariant
            opacity: 0.7
        }
    }

    ContentCard {
        StyledText {
            text: "Shell Information"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            StyledText { text: "Version:"; font.bold: true; Layout.preferredWidth: 100 }
            StyledText { text: Config.runtime.shell.version }
        }

        RowLayout {
            Layout.fillWidth: true
            StyledText { text: "Channel:"; font.bold: true; Layout.preferredWidth: 100 }
            StyledText { text: Config.runtime.shell.releaseChannel }
        }

        RowLayout {
            Layout.fillWidth: true
            StyledText { text: "QS Version:"; font.bold: true; Layout.preferredWidth: 100 }
            StyledText { text: Config.runtime.shell.qsVersion }
        }
    }
}
