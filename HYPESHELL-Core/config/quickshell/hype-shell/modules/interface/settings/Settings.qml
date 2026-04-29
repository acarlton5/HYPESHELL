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
                { "icon": "bluetooth", "label": "Bluetooth", "page": 0, "source": Qt.resolvedUrl("BluetoothConfig.qml") },
                { "icon": "network_wifi", "label": "Wireless", "page": 1, "source": Qt.resolvedUrl("NetworkConfig.qml") },
                { "icon": "volume_up", "label": "Audio", "page": 2, "source": Qt.resolvedUrl("AudioConfig.qml") },

                { "header": true, "label": "Appearance" },
                { "icon": "palette", "label": "Theme", "page": 3, "source": Qt.resolvedUrl("AppearanceConfig.qml") },
                { "icon": "dark_mode", "label": "Appearance Mode", "page": 9, "source": Qt.resolvedUrl("ThemeVariantConfig.qml") },
                { "icon": "wallpaper", "label": "Wallpapers", "page": 4, "source": Qt.resolvedUrl("WallpaperConfig.qml") },
                { "icon": "auto_awesome", "label": "Wallbash", "page": 10, "source": Qt.resolvedUrl("WallbashConfig.qml") },

                { "header": true, "label": "Theme Specific" },
                // These will be dynamically injected or pointed to the theme folder
                { "icon": "auto_awesome", "label": "Theme Settings", "page": 5, "source": "file://" + Directories.home + "/.config/hype/themes/" + WallpaperSlideshow.hypeThemeName + "/settings/Main.qml" },

                { "header": true, "label": "Support" },
                { "icon": "info", "label": "About", "page": 11, "source": Qt.resolvedUrl("About.qml") }
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
                        Layout.preferredWidth: 84
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
                                    height: modelData.header ? 10 : 52
                                    visible: true

                                    // Item Delegate
                                    StyledRect {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        visible: !modelData.header
                                        color: root.selectedIndex === modelData.page ? MaterialColors.colors.secondary_container : "transparent"
                                        radius: 12

                                        MaterialSymbol {
                                            anchors.centerIn: parent
                                            icon: modelData.icon || ""
                                            iconSize: 24
                                            color: root.selectedIndex === modelData.page ? MaterialColors.colors.on_secondary_container : MaterialColors.colors.on_surface
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
