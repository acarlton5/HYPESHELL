import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.components

ContentMenu {
    id: root
    property string viewMode: "modules"
    readonly property bool modulesView: viewMode === "modules"
    readonly property bool gadgetsView: viewMode === "gadgets"

    title: modulesView ? "Modules" : "Gadgets"
    description: modulesView
        ? "Manage Hype shell modules."
        : "Manage Hype desktop gadgets."

    readonly property string shellModulesRoot: Directories.home + "/.config/hype/modules"
    readonly property string shellModulesRegistryPath: shellModulesRoot + "/modules.json"
    readonly property string shellModuleListScript: Directories.scriptsPath + "/modules/list-modules.sh"

    readonly property string gadgetsRoot: Directories.home + "/.config/hype/gadgets"
    readonly property string gadgetsRegistryPath: gadgetsRoot + "/gadgets.json"
    readonly property string gadgetListScript: Directories.scriptsPath + "/gadgets/list-gadgets.sh"

    property var shellModulesModel: []
    property bool shellModulesLoading: false
    property string shellModulesError: ""

    property var gadgetsModel: []
    property bool gadgetsLoading: false
    property string gadgetsError: ""

    function toList(value) {
        if (value === undefined || value === null)
            return []

        if (Array.isArray(value))
            return value

        if (typeof value === "string")
            return []

        if (value.length !== undefined) {
            const out = []
            for (let i = 0; i < value.length; i++)
                out.push(value[i])
            return out
        }

        return []
    }

    function readConfigValue(prefField, fallbackValue) {
        const key = String(prefField || "").trim()
        if (key.length === 0)
            return fallbackValue

        const parts = key.split(".")
        let current = Config.runtime

        for (let i = 0; i < parts.length; i++) {
            if (current === undefined || current === null)
                return fallbackValue

            if (current[parts[i]] === undefined)
                return fallbackValue

            current = current[parts[i]]
        }

        return current === undefined ? fallbackValue : current
    }

    function asNumber(value, fallbackValue) {
        const parsed = Number(value)
        return isNaN(parsed) ? fallbackValue : parsed
    }

    function settingType(setting) {
        const rawType = setting && setting.type !== undefined
            ? String(setting.type).toLowerCase().trim()
            : "string"

        if (rawType === "bool")
            return "boolean"
        if (rawType === "int" || rawType === "integer" || rawType === "float" || rawType === "double")
            return "number"
        if (rawType === "select" || rawType === "choice")
            return "enum"

        return rawType
    }

    function settingOptions(setting) {
        if (!setting || !setting.options)
            return []
        return toList(setting.options)
    }

    function optionLabel(option) {
        if (option !== null && typeof option === "object") {
            if (option.label !== undefined)
                return String(option.label)
            if (option.value !== undefined)
                return String(option.value)
        }

        return String(option)
    }

    function optionValue(option) {
        if (option !== null && typeof option === "object" && option.value !== undefined)
            return option.value
        return option
    }

    function enumCurrentIndex(setting) {
        const options = settingOptions(setting)
        if (options.length === 0)
            return -1

        const fallbackValue = setting && setting.default !== undefined
            ? setting.default
            : optionValue(options[0])

        const current = readConfigValue(setting.key, fallbackValue)
        const currentString = String(current)

        for (let i = 0; i < options.length; i++) {
            if (String(optionValue(options[i])) === currentString)
                return i
        }

        return 0
    }

    function moduleEnabledKey(moduleData) {
        if (!moduleData)
            return ""

        const explicit = String(moduleData.enabledKey || "").trim()
        if (explicit.length > 0)
            return explicit

        const settings = toList(moduleData.settings)
        if (settings.length === 0)
            return ""

        for (let i = 0; i < settings.length; i++) {
            const s = settings[i]
            if (!s)
                continue
            const key = String(s.key || "").trim()
            const type = settingType(s)
            if (type === "boolean" && key.endsWith(".enabled"))
                return key
        }

        return ""
    }

    function moduleEnabled(moduleData) {
        const key = moduleEnabledKey(moduleData)
        if (key.length === 0)
            return true
        return Boolean(readConfigValue(key, true))
    }

    function moduleSettings(moduleData) {
        if (!moduleData)
            return []

        const settings = toList(moduleData.settings)
        if (settings.length === 0)
            return []

        const enabledKey = moduleEnabledKey(moduleData)
        if (enabledKey.length === 0)
            return settings

        const list = []
        for (let i = 0; i < settings.length; i++) {
            const setting = settings[i]
            if (String(setting.key || "").trim() !== enabledKey)
                list.push(setting)
        }
        return list
    }

    function parseShellModulesPayload(rawText) {
        const payload = String(rawText || "").trim()
        if (payload.length === 0) {
            shellModulesModel = []
            return
        }

        try {
            const parsed = JSON.parse(payload)
            shellModulesModel = Array.isArray(parsed) ? parsed : []
            if (!Array.isArray(parsed))
                shellModulesError = "Module list payload was not an array."
        } catch (error) {
            shellModulesModel = []
            shellModulesError = "Failed to parse module list: " + error
        }
    }

    function parseGadgetsPayload(rawText) {
        const payload = String(rawText || "").trim()
        if (payload.length === 0) {
            gadgetsModel = []
            return
        }

        try {
            const parsed = JSON.parse(payload)
            gadgetsModel = Array.isArray(parsed) ? parsed : []
            if (!Array.isArray(parsed))
                gadgetsError = "Gadget list payload was not an array."
        } catch (error) {
            gadgetsModel = []
            gadgetsError = "Failed to parse gadget list: " + error
        }
    }

    function refreshShellModules() {
        if (shellModulesLoading)
            return

        shellModulesLoading = true
        shellModulesError = ""
        shellModuleListProc.running = true
    }

    function refreshGadgets() {
        if (gadgetsLoading)
            return

        gadgetsLoading = true
        gadgetsError = ""
        gadgetListProc.running = true
    }

    function refreshAll() {
        refreshShellModules()
        refreshGadgets()
    }

    Component.onCompleted: refreshAll()

    Process {
        id: shellModuleListProc
        command: [root.shellModuleListScript]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.parseShellModulesPayload(text)
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const msg = String(text || "").trim()
                if (msg.length > 0)
                    root.shellModulesError = msg
            }
        }

        onExited: function(exitCode) {
            root.shellModulesLoading = false
            if (exitCode !== 0 && root.shellModulesError.length === 0)
                root.shellModulesError = "Could not read module manifests."
        }
    }

    Process {
        id: gadgetListProc
        command: [root.gadgetListScript]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.parseGadgetsPayload(text)
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const msg = String(text || "").trim()
                if (msg.length > 0)
                    root.gadgetsError = msg
            }
        }

        onExited: function(exitCode) {
            root.gadgetsLoading = false
            if (exitCode !== 0 && root.gadgetsError.length === 0)
                root.gadgetsError = "Could not read gadget manifests."
        }
    }

    ContentCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(8)

            StyledText {
                text: "Modules folder: " + root.shellModulesRoot
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
                visible: root.modulesView
            }

            StyledText {
                text: "Modules registry: " + root.shellModulesRegistryPath
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
                visible: root.modulesView
            }

            StyledText {
                text: "Gadgets folder: " + root.gadgetsRoot
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
                visible: root.gadgetsView
            }

            StyledText {
                text: modulesView
                    ? "Modules change shell behavior and UI features."
                    : "Gadgets are desktop widgets rendered on the background stage."
                wrapMode: Text.WordWrap
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurface
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                StyledButton {
                    text: (root.shellModulesLoading || root.gadgetsLoading) ? "Refreshing..." : "Refresh"
                    icon: "refresh"
                    enabled: !root.shellModulesLoading && !root.gadgetsLoading
                    onClicked: root.refreshAll()
                }

                StyledButton {
                    text: "Open Modules Folder"
                    icon: "folder_open"
                    secondary: true
                    onClicked: Quickshell.execDetached(["xdg-open", root.shellModulesRoot])
                    visible: root.modulesView
                }

                StyledButton {
                    text: "Open Gadgets Folder"
                    icon: "folder_open"
                    secondary: true
                    onClicked: Quickshell.execDetached(["xdg-open", root.gadgetsRoot])
                    visible: root.gadgetsView
                }
            }
        }
    }

    ContentCard {
        visible: root.gadgetsView

        StyledText {
            text: "Tip: Right-click and drag any gadget on the desktop to move it."
            wrapMode: Text.WordWrap
            color: Appearance.m3colors.m3primary
        }
    }

    ContentCard {
        visible: root.modulesView && root.shellModulesError.length > 0

        StyledText {
            text: "Modules: " + root.shellModulesError
            wrapMode: Text.WordWrap
            color: Appearance.m3colors.m3error
        }
    }

    ContentCard {
        visible: root.gadgetsView && root.gadgetsError.length > 0

        StyledText {
            text: "Gadgets: " + root.gadgetsError
            wrapMode: Text.WordWrap
            color: Appearance.m3colors.m3error
        }
    }

    ContentCard {
        visible: root.modulesView
            ? (!root.shellModulesLoading
                && root.shellModulesModel.length === 0
                && root.shellModulesError.length === 0)
            : (!root.gadgetsLoading
                && root.gadgetsModel.length === 0
                && root.gadgetsError.length === 0)

        StyledText {
            text: root.modulesView ? "No modules found." : "No gadgets found."
            wrapMode: Text.WordWrap
            color: Appearance.m3colors.m3onSurfaceVariant
        }
    }

    ContentCard {
        visible: root.modulesView && root.shellModulesModel.length > 0

        StyledText {
            text: "Shell Modules"
            font.pixelSize: Metrics.fontSize(18)
            font.bold: true
            color: Appearance.m3colors.m3primary
        }
    }

    Repeater {
        model: root.modulesView ? root.shellModulesModel : []

        delegate: ModuleEntryCard {
            moduleData: modelData
            kindLabel: "module"
        }
    }

    ContentCard {
        visible: root.gadgetsView && root.gadgetsModel.length > 0

        StyledText {
            text: "Desktop Gadgets"
            font.pixelSize: Metrics.fontSize(18)
            font.bold: true
            color: Appearance.m3colors.m3primary
        }
    }

    Repeater {
        model: root.gadgetsView ? root.gadgetsModel : []

        delegate: ModuleEntryCard {
            moduleData: modelData
            kindLabel: "gadget"
        }
    }

    component ModuleEntryCard: ContentCard {
        property var moduleData: ({})
        property string kindLabel: "module"
        property string enabledKey: root.moduleEnabledKey(moduleData)
        property bool hasEnabledKey: enabledKey.length > 0
        property bool moduleIsEnabledState: root.moduleEnabled(moduleData)
        property var visibleSettings: root.moduleSettings(moduleData)
        property string settingsQmlPath: {
            const rel = String(moduleData.settingsQml || "").trim()
            const base = String(moduleData.path || "").trim()
            if (rel.length === 0 || base.length === 0)
                return ""
            return base + "/" + rel
        }
        property bool hasSettingsQml: settingsQmlPath.length > 0

        Layout.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(10)

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    text: moduleData.name + " (" + moduleData.id + ")"
                    font.pixelSize: Metrics.fontSize(18)
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: kindLabel
                    font.pixelSize: Metrics.fontSize("small")
                    color: Appearance.m3colors.m3primary
                }
            }

            StyledText {
                text: moduleData.description
                wrapMode: Text.WordWrap
                color: Appearance.m3colors.m3onSurfaceVariant
                visible: String(moduleData.description || "").length > 0
            }

            RowLayout {
                Layout.fillWidth: true
                visible: hasEnabledKey

                StyledText {
                    text: "Enabled"
                    font.pixelSize: Metrics.fontSize("normal")
                }

                Item { Layout.fillWidth: true }

                StyledSwitch {
                    id: enabledSwitch
                    checked: moduleIsEnabledState
                    onToggled: {
                        moduleIsEnabledState = checked
                        if (enabledKey.length > 0)
                            Config.updateKey(enabledKey, checked)
                    }
                }
            }

            StyledText {
                text: "Version: " + (moduleData.version || "unknown") + "    Author: " + (moduleData.author || "unknown")
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
            }

            StyledText {
                text: "Path: " + moduleData.path
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Appearance.m3colors.m3outlineVariant
                opacity: 0.7
            }

            StyledText {
                visible: enabledKey.length > 0 && !moduleIsEnabledState
                text: (kindLabel === "module" ? "Module" : "Gadget") + " disabled. Enable it to configure settings."
                color: Appearance.m3colors.m3onSurfaceVariant
            }

            StyledText {
                text: "No configurable settings declared in this manifest."
                color: Appearance.m3colors.m3onSurfaceVariant
                visible: moduleIsEnabledState
                    && !hasSettingsQml
                    && (!visibleSettings || visibleSettings.length === 0)
            }

            Loader {
                Layout.fillWidth: true
                visible: moduleIsEnabledState && hasSettingsQml
                source: hasSettingsQml ? ("file://" + encodeURI(settingsQmlPath)) : ""
                asynchronous: true
            }

            Repeater {
                model: moduleIsEnabledState && !hasSettingsQml
                    ? root.toList(visibleSettings)
                    : []

                delegate: Loader {
                    property var settingData: modelData

                    Layout.fillWidth: true

                    sourceComponent: {
                        const t = root.settingType(settingData)
                        if (t === "boolean")
                            return BoolSettingRow
                        if (t === "number")
                            return NumberSettingRow
                        if (t === "enum")
                            return EnumSettingRow
                        return TextSettingRow
                    }

                    onLoaded: {
                        if (item)
                            item.settingData = settingData
                    }
                }
            }
        }
    }

    component BoolSettingRow: RowLayout {
        property var settingData: ({})

        Layout.fillWidth: true
        spacing: Metrics.spacing(10)

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(2)

            StyledText {
                text: settingData.label
                font.pixelSize: Metrics.fontSize("normal")
            }

            StyledText {
                text: settingData.description
                color: Appearance.m3colors.m3onSurfaceVariant
                font.pixelSize: Metrics.fontSize("small")
                wrapMode: Text.WordWrap
                visible: String(settingData.description || "").length > 0
            }

            StyledText {
                text: settingData.key
                color: Appearance.m3colors.m3onSurfaceVariant
                font.pixelSize: Metrics.fontSize("smaller")
            }
        }

        StyledSwitch {
            checked: Boolean(
                root.readConfigValue(
                    settingData.key,
                    settingData.default !== undefined ? settingData.default : false
                )
            )
            onToggled: Config.updateKey(settingData.key, checked)
        }
    }

    component NumberSettingRow: NumberStepper {
        property var settingData: ({})

        Layout.fillWidth: true
        label: settingData.label
        description: String(settingData.description || "") + " [" + settingData.key + "]"
        prefField: settingData.key
        step: root.asNumber(settingData.step, 1)
        minimum: root.asNumber(settingData.min, -2147480000)
        maximum: root.asNumber(settingData.max, 2147480000)
    }

    component EnumSettingRow: RowLayout {
        property var settingData: ({})

        property var options: root.settingOptions(settingData)
        property var labels: {
            const out = []
            for (let i = 0; i < options.length; i++)
                out.push(root.optionLabel(options[i]))
            return out
        }

        Layout.fillWidth: true
        spacing: Metrics.spacing(10)

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(2)

            StyledText {
                text: settingData.label
                font.pixelSize: Metrics.fontSize("normal")
            }

            StyledText {
                text: settingData.description
                color: Appearance.m3colors.m3onSurfaceVariant
                font.pixelSize: Metrics.fontSize("small")
                wrapMode: Text.WordWrap
                visible: String(settingData.description || "").length > 0
            }

            StyledText {
                text: settingData.key
                color: Appearance.m3colors.m3onSurfaceVariant
                font.pixelSize: Metrics.fontSize("smaller")
            }
        }

        StyledDropDown {
            Layout.preferredWidth: 260
            label: settingData.label
            model: labels
            currentIndex: root.enumCurrentIndex(settingData)
            enabled: options.length > 0

            onSelectedIndexChanged: function(index) {
                if (index < 0 || index >= options.length)
                    return
                Config.updateKey(settingData.key, root.optionValue(options[index]))
            }
        }
    }

    component TextSettingRow: RowLayout {
        property var settingData: ({})

        Layout.fillWidth: true
        spacing: Metrics.spacing(10)

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(2)

            StyledText {
                text: settingData.label
                font.pixelSize: Metrics.fontSize("normal")
            }

            StyledText {
                text: settingData.description
                color: Appearance.m3colors.m3onSurfaceVariant
                font.pixelSize: Metrics.fontSize("small")
                wrapMode: Text.WordWrap
                visible: String(settingData.description || "").length > 0
            }

            StyledText {
                text: settingData.key
                color: Appearance.m3colors.m3onSurfaceVariant
                font.pixelSize: Metrics.fontSize("smaller")
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(8)

                StyledTextField {
                    id: textField
                    Layout.fillWidth: true
                    placeholder: String(
                        root.readConfigValue(
                            settingData.key,
                            settingData.default !== undefined ? settingData.default : ""
                        )
                    )
                    Component.onCompleted: {
                        text = String(
                            root.readConfigValue(
                                settingData.key,
                                settingData.default !== undefined ? settingData.default : ""
                            )
                        )
                    }
                }

                StyledButton {
                    text: "Save"
                    icon: "save"
                    onClicked: Config.updateKey(settingData.key, textField.text)
                }

                StyledButton {
                    icon: "refresh"
                    secondary: true
                    onClicked: {
                        textField.text = String(
                            root.readConfigValue(
                                settingData.key,
                                settingData.default !== undefined ? settingData.default : ""
                            )
                        )
                    }
                }
            }
        }
    }
}
