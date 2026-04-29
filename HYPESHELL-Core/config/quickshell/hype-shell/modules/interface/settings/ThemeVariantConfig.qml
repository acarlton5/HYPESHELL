import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Appearance 1.0
import qs.modules.components
import qs.services

ColumnLayout {
    spacing: 24
    Layout.fillWidth: true
    Layout.margins: 32

    ColumnLayout {
        spacing: 8
        StyledText {
            text: "Appearance Mode"
            font.pixelSize: 28
            font.weight: Font.Bold
        }
        StyledText {
            text: "Choose between light and dark variants of your active theme."
            opacity: 0.7
        }
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        color: Appearance.colors.colLayer1
        radius: 16
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            ColumnLayout {
                Layout.fillWidth: true
                StyledText {
                    text: Appearance.darkMode ? "Dark Mode" : "Light Mode"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }
                StyledText {
                    text: "Current theme: " + Config.runtime.appearance.colors.scheme
                    opacity: 0.6
                }
            }

            LightDarkToggle {
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    ColumnLayout {
        spacing: 16
        Layout.fillWidth: true
        
        StyledText {
            text: "Palette Preview"
            font.pixelSize: 18
            font.weight: Font.Bold
        }

        GridLayout {
            columns: 4
            rowSpacing: 12
            columnSpacing: 12
            
            Repeater {
                model: [
                    { name: "Primary", color: Appearance.colors.colPrimary },
                    { name: "Accent", color: Appearance.m3colors.m3tertiary },
                    { name: "Surface", color: Appearance.colors.colLayer0 },
                    { name: "Text", color: Appearance.colors.colOnLayer1 },
                    { name: "Surface Overlay", color: Appearance.colors.colLayer1 },
                    { name: "Muted Text", color: Appearance.colors.colSubtext },
                    { name: "Error", color: Appearance.m3colors.m3error },
                    { name: "Outline", color: Appearance.colors.colOutline }
                ]
                
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 40
                        radius: 8
                        color: modelData.color
                        border.color: Appearance.colors.colOutline
                        border.width: 1
                    }
                    StyledText {
                        text: modelData.name
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
