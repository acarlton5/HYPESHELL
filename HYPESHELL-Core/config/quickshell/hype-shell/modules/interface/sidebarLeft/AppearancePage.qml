import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.modules.components

Item {
    id: root
    anchors.fill: parent
    property string wallpaperFolder: "file://" + Quickshell.env("HOME") + "/Pictures"

    function refreshWallpaperFolder() {
        const themeFolder = String(WallpaperSlideshow.themeWallpaperFolder || "").trim()
        if (themeFolder.length > 0) {
            root.setWallpaperFolder(themeFolder)
            return
        }

        if (!readHypeThemeProc.running)
            readHypeThemeProc.running = true
    }

    onVisibleChanged: {
        if (visible)
            refreshWallpaperFolder()
    }

    Component.onCompleted: refreshWallpaperFolder()

    Connections {
        target: WallpaperSlideshow

        function onHypeThemeNameChanged() {
            root.refreshWallpaperFolder()
        }

        function onThemeWallpaperFolderChanged() {
            root.refreshWallpaperFolder()
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentLayout.implicitHeight + 100
        clip: true
        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: contentLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Metrics.margin("normal")
            anchors.rightMargin: Metrics.margin("normal")
            anchors.topMargin: 100
            anchors.top: parent.top
            spacing: Metrics.margin("large")

            // LIGHT / DARK MODE SELECTOR
            ContentCard {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(12)
                    
                    StyledText {
                        text: "Theme Mode"
                        font.pixelSize: Metrics.fontSize("large")
                        font.weight: Font.Bold
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Metrics.margin("normal")

                        StyledButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            text: "Dark"
                            icon: "dark_mode"
                            checked: Config.runtime.appearance.theme === "dark"
                            onClicked: {
                                Quickshell.execDetached(["hype", "ipc", "call", "global", "setTheme", "dark"])
                            }
                        }

                        StyledButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            text: "Light"
                            icon: "light_mode"
                            checked: Config.runtime.appearance.theme === "light"
                            onClicked: {
                                Quickshell.execDetached(["hype", "ipc", "call", "global", "setTheme", "light"])
                            }
                        }
                    }
                }
            }

            // WALLPAPERS SECTION
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(8)
                
                StyledText {
                    text: "Wallpapers"
                    font.pixelSize: Metrics.fontSize("large")
                    font.weight: Font.Bold
                }

                StyledText {
                    text: wallpaperFolder.replace("file://" + Quickshell.env("HOME"), "~")
                    font.pixelSize: Metrics.fontSize("small")
                    color: Appearance.m3colors.m3onSurfaceVariant
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }

                // Grid of Wallpapers
                GridLayout {
                    id: wallGrid
                    columns: 2
                    columnSpacing: Metrics.margin("small")
                    rowSpacing: Metrics.margin("small")
                    Layout.fillWidth: true

                    Repeater {
                        model: wallpaperModel
                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 140

                            ContentCard {
                                anchors.fill: parent
                                clip: true
                                cardMargin: 0
                                verticalPadding: 0

                                Image {
                                    anchors.fill: parent
                                    source: fileUrl
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        Config.updateKey("appearance.background.path", fileUrl);
                                        if (Config.runtime.appearance.colors.autogenerated) {
                                            Quickshell.execDetached(["hype", "ipc", "call", "global", "regenColors"]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: wallpaperModel.count === 0
                    text: "No wallpapers found in this folder."
                    font.pixelSize: Metrics.fontSize("normal")
                    color: Appearance.m3colors.m3onSurfaceVariant
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    FolderListModel {
        id: wallpaperModel
        folder: root.wallpaperFolder
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.PNG", "*.JPG", "*.JPEG", "*.WEBP"]
        showDirs: false
    }

    function setWallpaperFolder(path) {
        const cleaned = String(path || "").trim()
        root.wallpaperFolder = "file://" + (cleaned.length > 0 ? cleaned : Quickshell.env("HOME") + "/Pictures")
    }

    Process {
        id: readHypeThemeProc
        command: ["bash", "-lc", "theme=$(sed -nE 's/^[[:space:]]*hypeTheme[[:space:]]*=[[:space:]]*\"?([^\"[:space:]]+)\"?.*$/\\1/p' \"$HOME/.config/hype/hype.conf\" | head -n1); theme_dir=\"$HOME/.config/hype/themes/$theme/wallpapers\"; if [ -n \"$theme\" ] && [ -d \"$theme_dir\" ]; then printf '%s' \"$theme_dir\"; else printf '%s' \"$HOME/Pictures\"; fi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.setWallpaperFolder(text)
            }
        }
    }
}
