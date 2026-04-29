import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    id: root
    title: "Keybindings"
    description: "Manage your system and application shortcuts."

    property string editingKey: ""
    property string editingValue: ""

    function filterKeybinds(model, searchText) {
        if (!searchText || searchText.length === 0) return model
        const search = searchText.toLowerCase()
        return model.filter(item => 
            item.label.toLowerCase().includes(search) || 
            item.category.toLowerCase().includes(search)
        )
    }

    ListModel {
        id: internalModel
        Component.onCompleted: refresh()
        function refresh() {
            clear()
            append({ "category": "System", "label": "Terminal", "keys": Config.runtime.keybinds.system.terminal, "configKey": "keybinds.system.terminal" })
            append({ "category": "System", "label": "File Manager", "keys": Config.runtime.keybinds.system.fileManager, "configKey": "keybinds.system.fileManager" })
            append({ "category": "System", "label": "Lock Screen", "keys": Config.runtime.keybinds.system.lockScreen, "configKey": "keybinds.system.lockScreen" })
            append({ "category": "System", "label": "Logout", "keys": Config.runtime.keybinds.system.logout, "configKey": "keybinds.system.logout" })
            
            append({ "category": "Windows", "label": "Close Window", "keys": Config.runtime.keybinds.windows.close, "configKey": "keybinds.windows.close" })
            append({ "category": "Windows", "label": "Toggle Float", "keys": Config.runtime.keybinds.windows.toggleFloat, "configKey": "keybinds.windows.toggleFloat" })
            append({ "category": "Windows", "label": "Fullscreen", "keys": Config.runtime.keybinds.windows.fullscreen, "configKey": "keybinds.windows.fullscreen" })
            
            append({ "category": "HypeShell", "label": "Launcher", "keys": Config.runtime.keybinds.hypeshell.launcher, "configKey": "keybinds.hypeshell.launcher" })
            append({ "category": "HypeShell", "label": "Clipboard", "keys": Config.runtime.keybinds.hypeshell.clipboard, "configKey": "keybinds.hypeshell.clipboard" })
            append({ "category": "HypeShell", "label": "Themes", "keys": Config.runtime.keybinds.hypeshell.themes, "configKey": "keybinds.hypeshell.themes" })
        }
    }

    Connections {
        target: Config.runtime.keybinds
        function onSystemChanged() { internalModel.refresh() }
        function onWindowsChanged() { internalModel.refresh() }
        function onHypeshellChanged() { internalModel.refresh() }
    }

    TextField {
        id: searchField
        Layout.fillWidth: true
        placeholderText: "Search keybinds..."
        color: Appearance.m3colors.m3onSurface
        font.pixelSize: Metrics.fontSize("normal")
        background: Rectangle {
            radius: Appearance.rounding.medium
            color: Appearance.m3colors.m3surfaceContainerHigh
        }
        leftPadding: 45

        MaterialSymbol {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            icon: "search"
            iconSize: Metrics.iconSize("small")
            color: Appearance.m3colors.m3onSurfaceVariant
        }
    }

    ListView {
        id: keybindsList
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: internalModel
        spacing: 10
        clip: true

        delegate: ContentCard {
            width: keybindsList.width
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 20

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        text: model.label
                        font.pixelSize: Metrics.fontSize("large")
                        font.bold: true
                    }

                    StyledText {
                        text: model.category
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                    }
                }

                Item {
                    Layout.preferredHeight: 36
                    Layout.fillWidth: true
                    visible: root.editingKey === model.configKey

                    TextField {
                        anchors.fill: parent
                        text: root.editingValue
                        placeholderText: "Type key..."
                        onTextChanged: root.editingValue = text
                        onAccepted: {
                            Config.updateKey(root.editingKey, text)
                            root.editingKey = ""
                        }
                        Component.onCompleted: forceActiveFocus()
                    }
                }

                Rectangle {
                    visible: root.editingKey !== model.configKey
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: keysText.implicitWidth + 20
                    color: Appearance.m3colors.m3secondaryContainer
                    radius: 6

                    StyledText {
                        id: keysText
                        anchors.centerIn: parent
                        text: model.keys
                        font.pixelSize: 13
                        color: Appearance.m3colors.m3onSecondaryContainer
                    }
                }

                StyledButton {
                    icon: root.editingKey === model.configKey ? "check" : "edit"
                    secondary: true
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 36
                    onClicked: {
                        if (root.editingKey === model.configKey) {
                            Config.updateKey(root.editingKey, root.editingValue)
                            root.editingKey = ""
                        } else {
                            root.editingKey = model.configKey
                            root.editingValue = model.keys
                        }
                    }
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        
        StyledButton {
            text: "Add Custom Keybind"
            icon: "add"
            Layout.fillWidth: true
            onClicked: {
                // Future expansion
            }
        }

        StyledButton {
            text: "Reset to Defaults"
            icon: "restore"
            secondary: true
            onClicked: {
                // Future expansion
            }
        }
    }
}
