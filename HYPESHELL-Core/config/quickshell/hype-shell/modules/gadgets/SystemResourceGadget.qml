import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.components

ContentCard {
    id: root
    
    implicitWidth: 320
    implicitHeight: 300
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.margin("large")
        spacing: Metrics.margin("normal")

        StyledText {
            text: "System Resources"
            font.pixelSize: Metrics.fontSize("large")
            font.weight: Font.Bold
            color: Appearance.m3colors.m3primary
        }

        // CPU
        ResourceBar {
            label: "CPU Usage"
            valueText: SystemDetails.cpuLoad
            percent: SystemDetails.cpuPercent
        }

        // RAM
        ResourceBar {
            label: "RAM Usage"
            valueText: SystemDetails.ramUsage
            percent: SystemDetails.ramPercent
        }

        // Disk
        ResourceBar {
            label: "Disk Usage"
            valueText: SystemDetails.diskUsage
            percent: SystemDetails.diskPercent
        }

        // Swap
        ResourceBar {
            label: "Swap Usage"
            valueText: SystemDetails.swapUsage
            percent: SystemDetails.swapPercent
        }
    }

    component ResourceBar: ColumnLayout {
        property string label: ""
        property string valueText: ""
        property real percent: 0.0
        
        spacing: Metrics.spacing(4)
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                text: label
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            StyledText {
                text: valueText
                font.pixelSize: Metrics.fontSize("smaller")
                color: Appearance.m3colors.m3onSurface
                Layout.alignment: Qt.AlignRight
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 8
            radius: 4
            color: Appearance.m3colors.m3surfaceContainerHigh
            
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, percent))
                height: parent.height
                radius: 4
                color: Appearance.m3colors.m3primary
                
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }
    }
}
