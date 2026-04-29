import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.components

ColumnLayout {
    id: root
    spacing: Metrics.margin("small")
    Layout.fillWidth: true

    InfoRow { label: "Uptime"; value: SystemDetails.uptime }
    InfoRow { label: "Operating System"; value: SystemDetails.osName }
    
    RowLayout {
        Layout.fillWidth: true
        spacing: Metrics.margin("small")
        
        ContentCard {
            Layout.fillWidth: true
            implicitHeight: 72
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")
                
                StyledText { 
                    text: "Kernel"
                    font.pixelSize: Metrics.fontSize("smaller")
                    color: Appearance.colors.colSubtext 
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                StyledText { 
                    text: SystemDetails.kernelVersion
                    font.pixelSize: Metrics.fontSize("small")
                    color: Appearance.m3colors.m3onSurface 
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        
        ContentCard {
            Layout.fillWidth: true
            implicitHeight: 72
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")

                StyledText { 
                    text: "Architecture"
                    font.pixelSize: Metrics.fontSize("smaller")
                    color: Appearance.colors.colSubtext 
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                StyledText { 
                    text: SystemDetails.architecture
                    font.pixelSize: Metrics.fontSize("small")
                    color: Appearance.m3colors.m3onSurface 
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    InfoRow { 
        label: "Battery"
        value: `${Math.round(UPower.percentage)}% (${UPower.acOnline ? 'AC' : 'Bat'})`
        visible: UPower.batteryPresent
    }
    
    InfoRow { label: "Running Processes"; value: SystemDetails.runningProcesses }
    InfoRow { label: "Logged-in Users"; value: SystemDetails.loggedInUsers }

    component InfoRow: ContentCard {
        property string label: ""
        property string value: ""
        
        Layout.fillWidth: true
        implicitHeight: 56
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Metrics.margin("small")
            StyledText { text: label; font.pixelSize: Metrics.fontSize("normal"); color: Appearance.colors.colPrimary }
            Item { Layout.fillWidth: true }
            StyledText { 
                text: value; 
                font.pixelSize: Metrics.fontSize("small"); 
                color: Appearance.m3colors.m3onSurface
                Layout.fillWidth: true
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
