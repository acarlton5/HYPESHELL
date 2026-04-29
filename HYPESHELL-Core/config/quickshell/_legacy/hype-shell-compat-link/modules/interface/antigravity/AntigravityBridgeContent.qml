import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.modules.components

Item {
    id: root

    property bool windowMode: false
    readonly property string helperScript: Directories.shellConfig + "/antigravity-chat.sh"
    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/Antigravity/User/settings.json"

    function closeHypeSurfaces() {
        Globals.visiblility.sidebarLeft = false
        Globals.states.intelligenceWindowOpen = false
    }

    function runAction(action) {
        Quickshell.execDetached([helperScript, action])
        closeHypeSurfaces()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: root.windowMode ? Metrics.margin(16) : Metrics.margin(74)
        anchors.leftMargin: Metrics.margin(16)
        anchors.rightMargin: Metrics.margin(16)
        anchors.bottomMargin: Metrics.margin(16)
        spacing: Metrics.spacing(12)

        ContentCard {
            Layout.fillWidth: true

            RowLayout {
                spacing: Metrics.spacing(16)
                Layout.fillWidth: true

                StyledRect {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: Metrics.radius("verylarge")
                    color: Appearance.m3colors.m3primaryContainer

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "chat"
                        iconSize: Metrics.iconSize(34)
                        color: Appearance.m3colors.m3onPrimaryContainer
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(4)

                    StyledText {
                        text: "Antigravity Chat"
                        font.pixelSize: Metrics.fontSize("title")
                        font.bold: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: "Hype no longer runs its built-in Zenith chat. This panel now launches Antigravity's chat sidebar instead."
                        color: Appearance.m3colors.m3onSurfaceVariant
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                StyledButton {
                    visible: root.windowMode
                    icon: "close"
                    text: "Close"
                    onClicked: Globals.states.intelligenceWindowOpen = false
                }
            }
        }

        ContentCard {
            Layout.fillWidth: true

            StyledText {
                text: "Launch"
                font.pixelSize: Metrics.fontSize("big")
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                StyledButton {
                    Layout.fillWidth: true
                    icon: "chat"
                    text: "Open Chat Sidebar"
                    tooltipText: "Reuse your last Antigravity window when possible."
                    onClicked: root.runAction("open-chat")
                }

                StyledButton {
                    Layout.fillWidth: true
                    icon: "open_in_new"
                    text: "New Chat Window"
                    secondary: true
                    onClicked: root.runAction("open-chat-new")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                StyledButton {
                    Layout.fillWidth: true
                    icon: "code"
                    text: "Open Antigravity"
                    secondary: true
                    onClicked: root.runAction("open-app")
                }

                StyledButton {
                    Layout.fillWidth: true
                    icon: "settings"
                    text: "Open Settings File"
                    secondary: true
                    onClicked: root.runAction("open-settings")
                }
            }
        }

        InfoCard {
            Layout.fillWidth: true
            icon: "info"
            title: "Sidebar behavior lives in Antigravity"
            description: "Use Antigravity for chat provider, sidebar placement, and editor integration. Hype now acts only as a launcher bridge."
        }

        ContentCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StyledText {
                text: "Current integration"
                font.pixelSize: Metrics.fontSize("big")
                font.bold: true
            }

            StyledText {
                text: "Helper script: " + helperScript
                color: Appearance.m3colors.m3onSurfaceVariant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            StyledText {
                text: "Antigravity settings: " + settingsPath
                color: Appearance.m3colors.m3onSurfaceVariant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }

            StyledText {
                text: "If Antigravity is not already open, the helper falls back to opening a fresh chat window."
                color: Appearance.m3colors.m3onSurfaceVariant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
