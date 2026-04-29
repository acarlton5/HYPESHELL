import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    title: "Appearance"
    description: "Adjust how the desktop looks like."

    property var hypeThemeModel: []
    property string hypeCurrentTheme: ""
    property int hypeSelectedThemeIndex: -1
    readonly property string hypeThemeListScript: Directories.home + "/.local/share/bin/hype-theme-list.sh"
    readonly property string hypeThemeApplyScript: Directories.home + "/.local/share/bin/hype-theme-apply.sh"
    property string hypePendingTheme: ""
    property string hypeApplyStdout: ""
    property string hypeApplyStderr: ""
    property string hypeLastApplyError: ""

    function applyLightDark(themeName) {
        const desired = String(themeName || "").trim().toLowerCase()
        if (desired !== "light" && desired !== "dark")
            return

        Quickshell.execDetached([
            "hype",
            "ipc",
            "call",
            "global",
            "setTheme",
            desired
        ])
    }

    function parseHypeThemeList(rawText) {
        const lines = rawText
            .split(/\r?\n/)
            .map((line) => line.trim())
            .filter((line) => line.length > 0)

        let current = ""
        const nextModel = []

        for (const line of lines) {
            if (line.startsWith("__CURRENT__=")) {
                current = line.slice("__CURRENT__=".length)
                continue
            }
            nextModel.push(line)
        }

        const previousSelected = (hypeSelectedThemeIndex >= 0 && hypeSelectedThemeIndex < hypeThemeModel.length)
            ? hypeThemeModel[hypeSelectedThemeIndex]
            : ""

        hypeThemeModel = nextModel
        hypeCurrentTheme = current

        if (nextModel.length === 0) {
            hypeSelectedThemeIndex = -1
            return
        }

        let index = nextModel.indexOf(current)
        if (index < 0)
            index = nextModel.indexOf(previousSelected)
        if (index < 0)
            index = 0

        hypeSelectedThemeIndex = index
    }

    function refreshHypeThemeList() {
        if (!hypeThemeListProc.running)
            hypeThemeListProc.running = true
    }

    function runHypeThemeSwitch(themeName) {
        const selectedTheme = String(themeName || "").trim()
        if (selectedTheme.length === 0 || hypeThemeApplyProc.running)
            return

        hypePendingTheme = selectedTheme
        hypeApplyStdout = ""
        hypeApplyStderr = ""
        hypeLastApplyError = ""
        hypeThemeApplyProc.exec([hypeThemeApplyScript, selectedTheme])
    }

    Component.onCompleted: refreshHypeThemeList()

    Timer {
        id: hypeThemeRefreshTimer
        interval: 2200
        repeat: false
        onTriggered: refreshHypeThemeList()
    }

    Process {
        id: hypeThemeListProc
        command: [hypeThemeListScript]
        running: false

        stdout: StdioCollector {
            onStreamFinished: parseHypeThemeList(text)
        }
    }

    Process {
        id: hypeThemeApplyProc

        stdout: StdioCollector {
            onStreamFinished: {
                hypeApplyStdout = text
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                hypeApplyStderr = text
            }
        }

        onExited: {
            if (exitCode !== 0) {
                const message = String(hypeApplyStderr || hypeApplyStdout || "").trim()
                hypeLastApplyError = message.length > 0 ? message : "Could not apply theme."
                Quickshell.execDetached([
                    "notify-send",
                    "Hype Shell",
                    "Could not apply theme: " + hypePendingTheme,
                    "--urgency=normal",
                    "--expire-time=3500"
                ])
            } else {
                hypeLastApplyError = ""
            }
            hypeThemeRefreshTimer.restart()
        }
    }

    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(16)

            ColumnLayout {
                spacing: Metrics.spacing(4)

                StyledText {
                    text: "Select Theme"
                    font.pixelSize: Metrics.fontSize(16)
                }

                StyledText {
                    text: "Choose between dark or light mode."
                    font.pixelSize: Metrics.fontSize(12)
                    color: "#888888"
                }
            }

            RowLayout {
                Layout.leftMargin: Metrics.margin(15)
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: Metrics.spacing(16)

                StyledButton {
                    Layout.preferredHeight: 300
                    Layout.preferredWidth: 460
                    Layout.maximumHeight: 400
                    Layout.maximumWidth: 500
                    icon: "dark_mode"
                    iconSize: Metrics.iconSize(64)
                    checked: Config.runtime.appearance.theme === "dark"
                    hoverEnabled: true

                    onClicked: {
                        applyLightDark("dark")
                    }
                }

                StyledButton {
                    Layout.preferredHeight: 300
                    Layout.preferredWidth: 460
                    Layout.maximumHeight: 400
                    Layout.maximumWidth: 500
                    icon: "light_mode"
                    iconSize: Metrics.iconSize(64)
                    checked: Config.runtime.appearance.theme === "light"
                    hoverEnabled: true

                    onClicked: {
                        applyLightDark("light")
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(8)

                StyledText {
                    text: "Hype Theme Selector"
                    font.pixelSize: Metrics.fontSize(16)
                }

                StyledText {
                    text: "Reads themes from ~/.config/hype/themes and applies via themeswitch."
                    font.pixelSize: Metrics.fontSize(12)
                    color: Appearance.m3colors.m3onSurfaceVariant
                }
            }

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    text: hypeCurrentTheme.length > 0
                        ? "Current: " + hypeCurrentTheme
                        : "Current: (not detected)"
                    font.pixelSize: Metrics.fontSize(14)
                }

                Item { Layout.fillWidth: true }

                StyledButton {
                    text: "Refresh"
                    icon: "refresh"
                    secondary: true
                    onClicked: refreshHypeThemeList()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                StyledDropDown {
                    id: hypeThemeSelector
                    Layout.fillWidth: true
                    label: "Select Hype Theme"
                    model: hypeThemeModel
                    currentIndex: hypeSelectedThemeIndex
                    onSelectedIndexChanged: (index) => {
                        hypeSelectedThemeIndex = index
                    }
                }

                StyledButton {
                    text: hypeThemeApplyProc.running ? "Applying..." : "Apply"
                    icon: "check"
                    enabled: !hypeThemeApplyProc.running
                        && hypeSelectedThemeIndex >= 0
                        && hypeSelectedThemeIndex < hypeThemeModel.length
                    onClicked: {
                        let selectedTheme = ""
                        if (hypeThemeSelector.currentIndex >= 0 && hypeThemeSelector.currentIndex < hypeThemeModel.length)
                            selectedTheme = String(hypeThemeModel[hypeThemeSelector.currentIndex] || "").trim()
                        if (selectedTheme.length === 0 && hypeSelectedThemeIndex >= 0 && hypeSelectedThemeIndex < hypeThemeModel.length)
                            selectedTheme = String(hypeThemeModel[hypeSelectedThemeIndex] || "").trim()
                        if (selectedTheme.length === 0)
                            selectedTheme = String(hypeThemeSelector.currentText || "").trim()
                        if (selectedTheme.length === 0)
                            return
                        runHypeThemeSwitch(selectedTheme)
                    }
                }
            }

            StyledText {
                visible: hypeLastApplyError.length > 0
                text: hypeLastApplyError
                wrapMode: Text.WordWrap
                color: Appearance.m3colors.m3error
                font.pixelSize: Metrics.fontSize(12)
            }

        }
    }

    ContentCard {
        StyledSwitchOption {
            title: "Tint Icons"
            description: "Either tint icons across the shell or keep them colorized."
            prefField: "appearance.tintIcons"
        }
    }

    ContentCard {
        StyledText {
            text: "Rounding"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }
        NumberStepper {
            label: "Factor"
            description: "Adjust the rounding factor."
            prefField: "appearance.rounding.factor"
            minimum: 0
            maximum: 1
            step: 0.1
        }
    }

    ContentCard {
        StyledText {
            text: "Font"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }
        NumberStepper {
            label: "Scale"
            description: "Adjust the font scale."
            prefField: "appearance.font.scale"
            minimum: 0.1
            maximum: 2
            step: 0.1
        }
    }

    ContentCard {
        StyledText {
            text: "Transparency"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }
        StyledSwitchOption {
            title: "Enabled"
            description: "Whether to enable or disable transparency."
            prefField: "appearance.transparency.enabled"
        }
        NumberStepper {
            label: "Factor"
            description: "Adjust the alpha value for transparency."
            prefField: "appearance.transparency.alpha"
            minimum: 0.1
            maximum: 1
            step: 0.1
        }
    }

    ContentCard {
        StyledText {
            text: "Animations"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }
        StyledSwitchOption {
            title: "Enabled"
            description: "Whether to enable or disable animations (applies everywhere in the shell)."
            prefField: "appearance.animations.enabled"
        }
        NumberStepper {
            label: "Duration Scale"
            description: "Adjust the duration scale of the animations."
            prefField: "appearance.animations.durationScale"
            minimum: 0.1
            maximum: 1
            step: 0.1
        }        
    }
}
