import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.config
import qs.modules.functions
import qs.modules.components
import qs.services

Scope {
    id: scope
    property var settingsWindow: null
    property string pendingMenu: ""

    IpcHandler {
        function open(menu: string) {
            scope.pendingMenu = menu;
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
            visible: true
            focusable: true
            aboveWindows: true
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            Component.onCompleted: {
                settingsWindow = root
                if (scope.pendingMenu !== "")
                    root.navigateTo(scope.pendingMenu)
            }
            Component.onDestruction: {
                if (settingsWindow === root)
                    settingsWindow = null
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            property int selectedIndex: 0
            onSelectedIndexChanged: Qt.callLater(applyPageProps)
            // Navigation helper
            function navigateTo(label) {
                const normalized = label.toLowerCase();
                for (var i = 0; i < menuModel.length; i++) {
                    if (menuModel[i].header)
                        continue

                    if (menuModel[i].label.toLowerCase() === normalized) {
                        root.selectedIndex = menuModel[i].page
                        break
                    }

                    const aliases = menuModel[i].aliases || []
                    for (var a = 0; a < aliases.length; a++) {
                        if (String(aliases[a]).toLowerCase() === normalized) {
                            root.selectedIndex = menuModel[i].page
                            return
                        }
                    }
                }
            }

            function selectedPage() {
                for (var i = 0; i < menuModel.length; i++) {
                    if (!menuModel[i].header && menuModel[i].page === root.selectedIndex)
                        return menuModel[i]
                }
                return menuModel[1]
            }

            function applyPageProps() {
                const page = selectedPage()
                if (!page || !page.props || !settingsPage.item)
                    return

                for (var p in page.props) {
                    if (settingsPage.item.hasOwnProperty(p))
                        settingsPage.item[p] = page.props[p]
                }
            }

            property var menuModel: [
                { "header": true, "label": "System" },
                { "icon": "network_wifi", "label": "Wireless", "page": 0, "source": Qt.resolvedUrl("NetworkConfig.qml"), "aliases": ["network", "wifi"] },
                { "icon": "bluetooth", "label": "Bluetooth", "page": 1, "source": Qt.resolvedUrl("BluetoothConfig.qml") },
                { "icon": "volume_up", "label": "Audio", "page": 2, "source": Qt.resolvedUrl("AudioConfig.qml"), "aliases": ["sound"] },

                { "header": true, "label": "Interface" },
                { "icon": "palette", "label": "Look & Feel", "page": 3, "source": Qt.resolvedUrl("AppearanceConfig.qml"), "aliases": ["appearance", "theme", "appearance mode", "wallpaper", "wallpapers", "wallbash"] },
                { "icon": "dock_to_bottom", "label": "Bar", "page": 4, "source": Qt.resolvedUrl("BarConfig.qml") },
                { "icon": "search", "label": "Launcher", "page": 5, "source": Qt.resolvedUrl("LauncherConfig.qml") },
                { "icon": "notifications", "label": "Notifications", "page": 6, "source": Qt.resolvedUrl("NotificationConfig.qml"), "aliases": ["overlays", "osd"] },
                { "icon": "keyboard", "label": "Keybindings", "page": 7, "source": Qt.resolvedUrl("KeybindsConfig.qml"), "aliases": ["keys", "shortcuts"] },

                { "header": true, "label": "Extensions" },
                { "icon": "extension", "label": "Modules", "page": 8, "source": Qt.resolvedUrl("ModulesConfig.qml"), "props": { "viewMode": "modules" } },
                { "icon": "widgets", "label": "Gadgets", "page": 9, "source": Qt.resolvedUrl("ModulesConfig.qml"), "props": { "viewMode": "gadgets" } },
                { "icon": "deployed_code", "label": "Plugins", "page": 10, "source": Qt.resolvedUrl("Plugins.qml") },
                { "icon": "storefront", "label": "Store", "page": 11, "source": Qt.resolvedUrl("Store.qml"), "aliases": ["hype store", "hypestore"] },
                { "icon": "dashboard_customize", "label": "DSS Systems", "page": 12, "source": Qt.resolvedUrl("DssWorkspaceConfig.qml"), "aliases": ["dss"] },

                { "header": true, "label": "Theme Specific" },
                { "icon": "auto_awesome", "label": "Theme Settings", "page": 13, "source": "file://" + Directories.home + "/.config/hype/themes/" + WallpaperSlideshow.hypeThemeName + "/settings/Main.qml" },

                { "header": true, "label": "Support" },
                { "icon": "info", "label": "About", "page": 14, "source": Qt.resolvedUrl("About.qml"), "aliases": ["update", "updates", "check for updates"] }
            ]

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.35
            }

            StyledRect {
                id: settingsSurface

                width: Math.max(320, Math.min(parent.width - Metrics.margin("verylarge"), 1280))
                height: Math.max(360, Math.min(parent.height - Metrics.margin("verylarge"), 720))
                x: Math.max(0, (parent.width - width) / 2)
                y: Math.max(0, (parent.height - height) / 2)
                color: MaterialColors.colors.background
                opacity: 1.0
                radius: Appearance.rounding.large

                function clampToScreen() {
                    x = Math.max(0, Math.min(x, root.width - width))
                    y = Math.max(0, Math.min(y, root.height - height))
                }

                MouseArea {
                    z: 10
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    drag.target: settingsSurface
                    drag.axis: Drag.XAndYAxis
                    drag.minimumX: 0
                    drag.minimumY: 0
                    drag.maximumX: Math.max(0, root.width - settingsSurface.width)
                    drag.maximumY: Math.max(0, root.height - settingsSurface.height)

                    onReleased: settingsSurface.clampToScreen()
                }

                MaterialSymbol {
                    anchors.top: parent.top
                    anchors.right: closeButton.left
                    anchors.topMargin: Metrics.margin("normal") + 8
                    anchors.rightMargin: Metrics.margin("small")
                    icon: "drag_indicator"
                    iconSize: Metrics.iconSize(22)
                    color: MaterialColors.colors.on_surface_variant
                    z: 11
                }
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Sidebar
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 220
                        color: MaterialColors.colors.surface_container_low
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Metrics.margin("normal")
                            spacing: Metrics.spacing(8)

                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: root.menuModel
                                spacing: 4
                                clip: true

                                delegate: Item {
                                    width: parent.width
                                    height: modelData.header ? 30 : 48
                                    visible: true

                                    StyledText {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        visible: modelData.header
                                        text: modelData.label || ""
                                        font.pixelSize: Metrics.fontSize("smaller")
                                        font.weight: Font.Bold
                                        color: MaterialColors.colors.on_surface_variant
                                        elide: Text.ElideRight
                                    }

                                    // Item Delegate
                                    StyledRect {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        visible: !modelData.header
                                        color: root.selectedIndex === modelData.page ? MaterialColors.colors.secondary_container : "transparent"
                                        radius: 12

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 10
                                            spacing: Metrics.spacing(10)

                                            MaterialSymbol {
                                                Layout.preferredWidth: 28
                                                icon: modelData.icon || ""
                                                iconSize: 22
                                                color: root.selectedIndex === modelData.page ? MaterialColors.colors.on_secondary_container : MaterialColors.colors.on_surface
                                            }

                                            StyledText {
                                                Layout.fillWidth: true
                                                text: modelData.label || ""
                                                font.pixelSize: Metrics.fontSize("small")
                                                font.weight: root.selectedIndex === modelData.page ? Font.Bold : Font.Medium
                                                color: root.selectedIndex === modelData.page ? MaterialColors.colors.on_secondary_container : MaterialColors.colors.on_surface
                                                elide: Text.ElideRight
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
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        HypeModule {
                            id: settingsPage
                            anchors.fill: parent
                            moduleName: root.selectedPage().label || ""
                            source: root.selectedPage().source || ""

                            onItemChanged: root.applyPageProps()
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: root.selectedPage().label === "Theme Settings" && settingsPage.hasError
                            color: MaterialColors.colors.background
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

                        StyledButton {
                            id: closeButton

                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: Metrics.margin("normal")
                            anchors.rightMargin: Metrics.margin("normal")
                            icon: "close"
                            text: ""
                            secondary: true
                            tooltipText: "Close settings"
                            onClicked: {
                                Globals.states.settingsOpen = false
                                if (settingsWindow === root)
                                    settingsWindow = null
                            }
                        }
                    }
                }
            }
        }
    }
}
