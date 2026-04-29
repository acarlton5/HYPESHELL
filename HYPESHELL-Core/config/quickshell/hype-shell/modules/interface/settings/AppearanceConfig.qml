import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    title: "Appearance"
    description: "Core shell aesthetics and behavior."

    // Theme Mode Section
    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(16)

            StyledText {
                text: "Color Mode"
                font.pixelSize: 18
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                StyledButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    text: "Dark Mode"
                    icon: "dark_mode"
                    iconSize: 32
                    checked: Config.runtime.appearance.theme === "dark"
                    onClicked: {
                        HypeActions.applyThemeMode("dark");
                    }
                }

                StyledButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    text: "Light Mode"
                    icon: "light_mode"
                    iconSize: 32
                    checked: Config.runtime.appearance.theme === "light"
                    onClicked: {
                        HypeActions.applyThemeMode("light");
                    }
                }
            }
        }
    }

    // Transparency Section
    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: "Transparency"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    StyledText {
                        text: "Enable glass effects and adjust background opacity."
                        font.pixelSize: 12
                        color: Appearance.colors.colSubtext
                    }
                }
                StyledSwitch {
                    checked: Config.runtime.appearance.transparency.enabled
                    onToggled: Config.runtime.appearance.transparency.enabled = checked
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Appearance.m3colors.m3outlineVariant
                visible: Config.runtime.appearance.transparency.enabled
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: Config.runtime.appearance.transparency.enabled
                spacing: 4
                
                RowLayout {
                    StyledText { text: "Opacity Factor"; font.pixelSize: 14 }
                    Item { Layout.fillWidth: true }
                    StyledText { 
                        text: Math.round(Config.runtime.appearance.transparency.alpha * 100) + "%"
                        font.pixelSize: 14
                        color: Appearance.colors.colPrimary
                    }
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0.1
                    to: 1.0
                    value: Config.runtime.appearance.transparency.alpha
                    onMoved: Config.runtime.appearance.transparency.alpha = value
                }
            }
        }
    }

    // Animations Section
    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: "Interface Animations"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    StyledText {
                        text: "Enable or disable all shell motion and transitions."
                        font.pixelSize: 12
                        color: Appearance.colors.colSubtext
                    }
                }
                StyledSwitch {
                    checked: Config.runtime.appearance.animations.enabled
                    onToggled: Config.runtime.appearance.animations.enabled = checked
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Appearance.m3colors.m3outlineVariant
                visible: Config.runtime.appearance.animations.enabled
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: Config.runtime.appearance.animations.enabled
                spacing: 4
                
                RowLayout {
                    StyledText { text: "Animation Speed"; font.pixelSize: 14 }
                    Item { Layout.fillWidth: true }
                    StyledText { 
                        text: Config.runtime.appearance.animations.durationScale.toFixed(1) + "x"
                        font.pixelSize: 14
                        color: Appearance.colors.colPrimary
                    }
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0.1
                    to: 2.0
                    value: Config.runtime.appearance.animations.durationScale
                    onMoved: Config.runtime.appearance.animations.durationScale = value
                }
            }
        }
    }

    // Rounding Section
    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            StyledText {
                text: "Rounding & Corners"
                font.pixelSize: 18
                font.bold: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                RowLayout {
                    StyledText { text: "Corner Radius Factor"; font.pixelSize: 14 }
                    Item { Layout.fillWidth: true }
                    StyledText { 
                        text: Config.runtime.appearance.rounding.factor.toFixed(1)
                        font.pixelSize: 14
                        color: Appearance.colors.colPrimary
                    }
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0.0
                    to: 2.0
                    value: Config.runtime.appearance.rounding.factor
                    onMoved: Config.runtime.appearance.rounding.factor = value
                }
            }
        }
    }
}
