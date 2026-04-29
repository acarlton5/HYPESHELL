import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.components

ContentCard {
    id: root
    
    implicitWidth: 300
    implicitHeight: 100
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: Metrics.margin("small")
        spacing: Metrics.margin("tiny")

        StyledText {
            text: SystemDetails.osIcon
            font.family: Metrics.fontFamily("nerdIcons")
            font.pixelSize: Metrics.fontSize(32)
            color: Appearance.colors.colPrimary
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true

            StyledText {
                text: SystemDetails.osName
                font.pixelSize: Metrics.fontSize("normal")
                font.weight: Font.Bold
                color: Appearance.m3colors.m3onSurface
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            StyledText {
                text: `${SystemDetails.username}@${SystemDetails.hostname}`
                font.pixelSize: Metrics.fontSize("smallest")
                color: Appearance.colors.colSubtext
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignRight
            Layout.maximumWidth: parent.width * 0.4

            StyledText {
                text: `qs ${SystemDetails.qsVersion}`
                font.pixelSize: Metrics.fontSize("smallest")
                color: Appearance.colors.colSubtext
                Layout.fillWidth: true
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }

            StyledText {
                text: `hype v${Config.runtime.shell.version}`
                font.pixelSize: Metrics.fontSize("smallest")
                color: Appearance.colors.colSubtext
                Layout.fillWidth: true
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
