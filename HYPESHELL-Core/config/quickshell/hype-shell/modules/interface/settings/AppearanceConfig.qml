import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    id: lookFeel

    title: "Look & Feel"
    description: "Theme, wallpaper, colors, motion, and shell surface styling."

    function currentSlideshowSeconds() {
        const seconds = Number(Config.runtime.appearance.background.slideshow.intervalSeconds)
        if (!isNaN(seconds) && seconds > 0)
            return Math.round(seconds)

        const minutes = Number(Config.runtime.appearance.background.slideshow.interval)
        if (!isNaN(minutes) && minutes > 0)
            return Math.round(minutes * 60)

        return 300
    }

    function applySlideshowSeconds(rawValue) {
        const parsed = Math.round(Number(String(rawValue || "").trim()))
        if (!isNaN(parsed) && parsed > 0)
            Config.updateKey("appearance.background.slideshow.intervalSeconds", parsed)
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(16)

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(14)

                Rectangle {
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72
                    radius: Metrics.radius("large")
                    color: Appearance.m3colors.m3primaryContainer

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: Config.runtime.appearance.theme === "dark" ? "dark_mode" : "light_mode"
                        iconSize: Metrics.iconSize(34)
                        color: Appearance.m3colors.m3onPrimaryContainer
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(4)

                    StyledText {
                        Layout.fillWidth: true
                        text: Config.runtime.appearance.theme === "dark" ? "Dark appearance" : "Light appearance"
                        font.pixelSize: Metrics.fontSize("large")
                        font.weight: Font.Bold
                        color: Appearance.m3colors.m3onSurface
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Theme: " + Config.runtime.appearance.colors.scheme
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }

                StyledButton {
                    Layout.preferredWidth: 112
                    text: "Dark"
                    icon: "dark_mode"
                    checked: Config.runtime.appearance.theme === "dark"
                    secondary: Config.runtime.appearance.theme !== "dark"
                    onClicked: HypeActions.applyThemeMode("dark")
                }

                StyledButton {
                    Layout.preferredWidth: 112
                    text: "Light"
                    icon: "light_mode"
                    checked: Config.runtime.appearance.theme === "light"
                    secondary: Config.runtime.appearance.theme !== "light"
                    onClicked: HypeActions.applyThemeMode("light")
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: lookFeel.width > 760 ? 4 : 2
                columnSpacing: Metrics.spacing(10)
                rowSpacing: Metrics.spacing(10)

                Repeater {
                    model: [
                        { name: "Primary", color: Appearance.colors.colPrimary, onColor: Appearance.colors.colOnPrimary },
                        { name: "Accent", color: Appearance.m3colors.m3tertiary, onColor: Appearance.m3colors.m3onTertiary },
                        { name: "Surface", color: Appearance.colors.colLayer0, onColor: Appearance.m3colors.m3onSurface },
                        { name: "Text", color: Appearance.colors.colOnLayer1, onColor: Appearance.colors.colLayer1 }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 54
                        radius: Metrics.radius("small")
                        color: modelData.color
                        border.color: Appearance.m3colors.m3outlineVariant
                        border.width: 1

                        StyledText {
                            anchors.centerIn: parent
                            text: modelData.name
                            font.pixelSize: Metrics.fontSize("small")
                            font.weight: Font.Bold
                            color: modelData.onColor
                        }
                    }
                }
            }
        }
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(18)

            Rectangle {
                Layout.preferredWidth: 220
                Layout.preferredHeight: 132
                radius: Metrics.radius("normal")
                clip: true
                color: Appearance.m3colors.m3surfaceContainer

                Image {
                    anchors.fill: parent
                    source: Config.runtime.appearance.background.path
                    fillMode: Image.PreserveAspectCrop
                    opacity: Config.runtime.appearance.background.enabled ? 1 : 0.35
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    visible: !Config.runtime.appearance.background.enabled
                    icon: "wallpaper_slideshow"
                    iconSize: Metrics.iconSize(42)
                    color: Appearance.m3colors.m3onSurfaceVariant
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                StyledText {
                    Layout.fillWidth: true
                    text: "Wallpaper"
                    font.pixelSize: Metrics.fontSize("large")
                    font.weight: Font.Bold
                }

                StyledSwitchOption {
                    title: "Wallpaper Manager"
                    description: "Show the built-in desktop wallpaper."
                    prefField: "appearance.background.enabled"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(10)

                    StyledButton {
                        Layout.preferredWidth: 170
                        text: "Choose"
                        icon: "wallpaper"
                        secondary: true
                        onClicked: {
                            Globals.states.sidebarLeftPage = 1
                            Globals.visiblility.sidebarRight = false
                            Globals.visiblility.sidebarLeft = true
                            Quickshell.execDetached(["hype", "ipc", "call", "sidebarLeft", "openWallpapers"])
                            Globals.states.settingsOpen = false
                        }
                    }

                    StyledButton {
                        Layout.preferredWidth: 170
                        text: "Generate"
                        icon: "auto_awesome"
                        secondary: !Config.runtime.appearance.colors.autogenerated
                        onClicked: Wallbash.generateThemeFromWallpaper(Config.runtime.appearance.background.path, Config.runtime.appearance.theme)
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(12)

            StyledText {
                Layout.fillWidth: true
                text: "Dynamic Colors"
                font.pixelSize: Metrics.fontSize("large")
                font.weight: Font.Bold
            }

            StyledSwitchOption {
                title: "Auto-Generate From Wallpaper"
                description: "Regenerate shell colors when wallpaper colors change."
                prefField: "appearance.colors.autogenerated"
            }

            StyledSwitchOption {
                title: "Apply Colors User-Wide"
                description: "Run matugen templates for supported external apps."
                prefField: "appearance.colors.runMatugenUserWide"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(2)

                    StyledText {
                        text: "Matugen Scheme"
                        font.pixelSize: Metrics.fontSize("normal")
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Config.runtime.appearance.colors.matugenScheme
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }

                StyledDropDown {
                    Layout.preferredWidth: 220
                    label: "Scheme"
                    model: ["scheme-neutral", "scheme-tonal-spot", "scheme-vibrant", "scheme-expressive", "scheme-content"]
                    currentIndex: Math.max(0, model.indexOf(Config.runtime.appearance.colors.matugenScheme))
                    onSelectedIndexChanged: Config.updateKey("appearance.colors.matugenScheme", model[index])
                }
            }
        }
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(12)

            StyledText {
                Layout.fillWidth: true
                text: "Wallpaper Slideshow"
                font.pixelSize: Metrics.fontSize("large")
                font.weight: Font.Bold
            }

            StyledSwitchOption {
                title: "Enable Slideshow"
                description: "Rotate wallpapers from the active theme wallpaper folder."
                prefField: "appearance.background.slideshow.enabled"
            }

            StyledSwitchOption {
                title: "Include Subfolders"
                description: "Search nested folders for slideshow wallpapers."
                prefField: "appearance.background.slideshow.includeSubfolders"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(2)

                    StyledText {
                        text: "Interval"
                        font.pixelSize: Metrics.fontSize("normal")
                    }

                    StyledText {
                        text: "Seconds between wallpaper changes."
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                    }
                }

                StyledTextField {
                    id: slideshowSecondsField
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                    placeholder: "300"
                    validator: IntValidator { bottom: 1; top: 86400 }
                    Component.onCompleted: text = String(lookFeel.currentSlideshowSeconds())
                    onEditingFinished: {
                        lookFeel.applySlideshowSeconds(text)
                        text = String(lookFeel.currentSlideshowSeconds())
                    }
                }

                StyledButton {
                    Layout.preferredWidth: 96
                    text: "Set"
                    secondary: true
                    onClicked: {
                        lookFeel.applySlideshowSeconds(slideshowSecondsField.text)
                        slideshowSecondsField.text = String(lookFeel.currentSlideshowSeconds())
                    }
                }
            }
        }
    }

    ContentCard {
        cardMargin: Metrics.margin("large")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(14)

            StyledText {
                Layout.fillWidth: true
                text: "Surface & Motion"
                font.pixelSize: Metrics.fontSize("large")
                font.weight: Font.Bold
            }

            StyledSwitchOption {
                title: "Transparency"
                description: "Enable glass-style shell surfaces."
                prefField: "appearance.transparency.enabled"
            }

            SettingSlider {
                title: "Surface Opacity"
                valueText: Math.round(Config.runtime.appearance.transparency.alpha * 100) + "%"
                from: 0.1
                to: 1
                value: Config.runtime.appearance.transparency.alpha
                enabled: Config.runtime.appearance.transparency.enabled
                onMoved: Config.updateKey("appearance.transparency.alpha", value)
            }

            StyledSwitchOption {
                title: "Animations"
                description: "Enable shell motion and transitions."
                prefField: "appearance.animations.enabled"
            }

            SettingSlider {
                title: "Animation Speed"
                valueText: Config.runtime.appearance.animations.durationScale.toFixed(1) + "x"
                from: 0.1
                to: 2
                value: Config.runtime.appearance.animations.durationScale
                enabled: Config.runtime.appearance.animations.enabled
                onMoved: Config.updateKey("appearance.animations.durationScale", value)
            }

            SettingSlider {
                title: "Corner Radius"
                valueText: Config.runtime.appearance.rounding.factor.toFixed(1)
                from: 0
                to: 2
                value: Config.runtime.appearance.rounding.factor
                onMoved: Config.updateKey("appearance.rounding.factor", value)
            }

            SettingSlider {
                title: "Font Scale"
                valueText: Config.runtime.appearance.font.scale.toFixed(1) + "x"
                from: 0.8
                to: 1.4
                value: Config.runtime.appearance.font.scale
                onMoved: Config.updateKey("appearance.font.scale", value)
            }
        }
    }

    component SettingSlider: ColumnLayout {
        id: settingSlider

        property string title: ""
        property string valueText: ""
        property real from: 0
        property real to: 1
        property real value: 0
        signal moved(real value)

        Layout.fillWidth: true
        opacity: enabled ? 1 : 0.5
        spacing: Metrics.spacing(4)

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: settingSlider.title
                font.pixelSize: Metrics.fontSize("normal")
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: settingSlider.valueText
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3primary
            }
        }

        Slider {
            Layout.fillWidth: true
            from: settingSlider.from
            to: settingSlider.to
            value: settingSlider.value
            enabled: settingSlider.enabled
            onMoved: settingSlider.moved(value)
        }
    }
}
