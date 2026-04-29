import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    title: "Wallpaper"
    description: "Manage your wallpapers"

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
        ClippingRectangle {
            id: wpContainer

            Layout.alignment: Qt.AlignHCenter
            width: root.screen.width / 2
            height: width * root.screen.height / root.screen.width
            radius: Metrics.radius("unsharpenmore")
            color: Appearance.m3colors.m3surfaceContainer

            StyledText {
                text: "Current Wallpaper:"
                font.pixelSize: Metrics.fontSize("big")
                font.bold: true
            }

            ClippingRectangle {
                id: wpPreview

                Layout.alignment: Qt.AlignHCenter | Qt.AlignCenter
                anchors.fill: parent
                radius: Metrics.radius("unsharpenmore")
                color: Appearance.m3colors.m3paddingContainer
                layer.enabled: true

                StyledText {
                    opacity: !Config.runtime.appearance.background.enabled ? 1 : 0
                    font.pixelSize: Metrics.fontSize("title")
                    text: "Wallpaper Manager Disabled"
                    anchors.centerIn: parent

                    Behavior on opacity {
                        enabled: Config.runtime.appearance.animations.enabled
                        Anim { }
                    }
                }

                Image {
                    opacity: Config.runtime.appearance.background.enabled ? 1 : 0
                    anchors.fill: parent
                    source: Config.runtime.appearance.background.path
                    fillMode: Image.PreserveAspectCrop
                    cache: true

                    Behavior on opacity {
                        enabled: Config.runtime.appearance.animations.enabled
                        Anim { }
                    }
                }
            }
        }

        StyledButton {
            icon: "wallpaper"
            text: "Change Wallpaper"
            Layout.fillWidth: true
            onClicked: {
                Globals.states.sidebarLeftPage = 2
                Globals.visiblility.sidebarRight = false
                Globals.visiblility.sidebarLeft = true
                Quickshell.execDetached(["hype", "ipc", "call", "sidebarLeft", "openWallpapers"])
                Globals.states.settingsOpen = false
            }
        }

        StyledSwitchOption {
            title: "Enabled"
            description: "Enabled or disable built-in wallpaper daemon."
            prefField: "appearance.background.enabled"
        }
    }


    ContentCard {
        StyledText {
            text: "Wallpaper Slideshow"
            font.pixelSize: Metrics.fontSize("big")
            font.bold: true
        }

        StyledSwitchOption {
            title: "Enable Slideshow"
            description: "Automatically rotate wallpapers from the active theme folder."
            prefField: "appearance.background.slideshow.enabled"
        }

        StyledText {
            text: "Source: ~/.config/hype/themes/<active-theme>/wallpapers"
            font.pixelSize: Metrics.fontSize("small")
            color: Appearance.m3colors.m3onSurfaceVariant
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(10)

            ColumnLayout {
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

            Item { Layout.fillWidth: true }

            StyledTextField {
                id: slideshowSecondsField
                Layout.preferredWidth: 120
                horizontalAlignment: Text.AlignHCenter
                placeholder: "300"
                validator: IntValidator { bottom: 1; top: 86400 }
                Component.onCompleted: text = String(currentSlideshowSeconds())
                onEditingFinished: {
                    applySlideshowSeconds(text)
                    text = String(currentSlideshowSeconds())
                }
            }

            StyledButton {
                text: "Set"
                onClicked: {
                    applySlideshowSeconds(slideshowSecondsField.text)
                    slideshowSecondsField.text = String(currentSlideshowSeconds())
                }
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Metrics.chronoDuration(400)
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.animation.curves.standard
    }
}
