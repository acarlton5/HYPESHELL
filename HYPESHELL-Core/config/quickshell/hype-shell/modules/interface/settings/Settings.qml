import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.functions
import qs.modules.components
import qs.services

Scope {
    id: scope
    property var settingsWindow: null

    IpcHandler {
        function open(menu: string) {
            Globals.states.settingsOpen = true;
            if (settingsWindow) {
                settingsWindow.navigateTo(menu);
            }
        }
        target: "settings"
    }

    LazyLoader {
        active: Globals.states.settingsOpen

        PanelWindow {
            id: root
            width: 1280
            height: 720
            visible: true
            color: "transparent"
            Component.onCompleted: settingsWindow = root

            property int selectedIndex: 0
            property bool sidebarCollapsed: false

            // Navigation helper
            function navigateTo(label) {
                const normalized = label.toLowerCase();
                for (var i = 0; i < menuModel.length; i++) {
                    if (!menuModel[i].header && menuModel[i].label.toLowerCase() === normalized) {
                        root.selectedIndex = menuModel[i].page;
                        break;
                    }
                }
            }

            property var menuModel: [
                { "header": true, "label": "System" },
                { "icon": "bluetooth", "label": "Bluetooth", "page": 0, "source": "BluetoothConfig.qml" },
                { "icon": "network_wifi", "label": "Wireless", "page": 1, "source": "NetworkConfig.qml" },
                { "icon": "volume_up", "label": "Audio", "page": 2, "source": "AudioConfig.qml" },

                { "header": true, "label": "Appearance" },
                { "icon": "palette", "label": "Theme", "page": 3, "source": "AppearanceConfig.qml" },
                { "icon": "dark_mode", "label": "Appearance Mode", "page": 9, "source": "ThemeVariantConfig.qml" },
                { "icon": "wallpaper", "label": "Wallpapers", "page": 4, "source": "WallpaperConfig.qml" },
                { "icon": "auto_awesome", "label": "Wallbash", "page": 10, "source": "WallbashConfig.qml" },

                { "header": true, "label": "Theme Specific" },
                // These will be dynamically injected or pointed to the theme folder
                { "icon": "auto_awesome", "label": "Theme Settings", "page": 5, "source": "file://" + Directories.home + "/.config/hype/themes/" + WallpaperSlideshow.hypeThemeName + "/settings/Main.qml" },

                { "header": true, "label": "HypeStore" },
                { "icon": "shopping_cart", "label": "Store", "page": 6, "source": "Store.qml" },
                { "icon": "toys", "label": "Modules", "page": 7, "source": "ModulesConfig.qml", "props": { "viewMode": "modules" } },
                { "icon": "widgets", "label": "Gadgets", "page": 8, "source": "ModulesConfig.qml", "props": { "viewMode": "gadgets" } },

                { "header": true, "label": "Support" },
                { "icon": "info", "label": "About", "page": 11, "source": "About.qml" }
            ]

            StyledRect {
                anchors.fill: parent
                color: Appearance.m3colors.m3background
                opacity: Appearance.transparency.enabled ? Appearance.transparency.alpha : 1.0
                radius: Appearance.rounding.large
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Sidebar
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: root.sidebarCollapsed ? 80 : 300
                        color: Appearance.m3colors.m3surfaceContainerLow
                        
                        Behavior on Layout.preferredWidth {
                            NumberAnimation { duration: 250; easing.type: Easing.InOutCubic }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Metrics.margin("large")
                            spacing: Metrics.spacing(4)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                StyledText {
                                    text: "Hype"
                                    font.pixelSize: 24
                                    font.weight: Font.Black
                                    visible: !root.sidebarCollapsed
                                }
                                Item { Layout.fillWidth: true }
                                StyledButton {
                                    icon: root.sidebarCollapsed ? "menu_open" : "menu"
                                    secondary: true
                                    onClicked: root.sidebarCollapsed = !root.sidebarCollapsed
                                }
                            }

                            Item { Layout.preferredHeight: 20 }

                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: root.menuModel
                                spacing: 4
                                clip: true

                                delegate: Item {
                                    width: parent.width
                                    height: modelData.header ? (root.sidebarCollapsed ? 0 : 40) : 48
                                    visible: !modelData.header || !root.sidebarCollapsed

                                    // Header Delegate
                                    StyledText {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        text: modelData.label.toUpperCase()
                                        font.pixelSize: 10
                                        font.bold: true
                                        opacity: 0.5
                                        visible: modelData.header && !root.sidebarCollapsed
                                    }

                                    // Item Delegate
                                    StyledRect {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        visible: !modelData.header
                                        color: root.selectedIndex === modelData.page ? Appearance.m3colors.m3secondaryContainer : "transparent"
                                        radius: 12

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            spacing: 12
                                            MaterialSymbol {
                                                icon: modelData.icon || ""
                                                iconSize: 22
                                                color: root.selectedIndex === modelData.page ? Appearance.m3colors.m3onSecondaryContainer : Appearance.m3colors.m3onSurface
                                            }
                                            StyledText {
                                                text: modelData.label
                                                visible: !root.sidebarCollapsed
                                                color: root.selectedIndex === modelData.page ? Appearance.m3colors.m3onSecondaryContainer : Appearance.m3colors.m3onSurface
                                                font.weight: root.selectedIndex === modelData.page ? Font.Bold : Font.Normal
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: root.selectedIndex = modelData.page
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Content Area
                    StackLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: root.selectedIndex

                        Repeater {
                            model: root.menuModel
                            HypeModule {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                moduleName: modelData.label || ""
                                source: modelData.source ? (modelData.source.startsWith("/") ? "file://" + modelData.source : modelData.source) : ""
                                visible: root.selectedIndex === modelData.page
                                
                                // Fallback for missing dynamic theme settings
                                Rectangle {
                                    anchors.fill: parent
                                    visible: modelData.label === "Theme Settings" && hasError
                                    color: "transparent"
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 12
                                        MaterialSymbol {
                                            icon: "auto_awesome_motion"
                                            iconSize: 64
                                            opacity: 0.2
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        StyledText {
                                            text: "This theme does not have custom settings."
                                            opacity: 0.5
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                                
                                Component.onCompleted: {
                                    if (modelData.props) {
                                        for (var p in modelData.props) {
                                            if (item && item.hasOwnProperty(p)) {
                                                item[p] = modelData.props[p];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
