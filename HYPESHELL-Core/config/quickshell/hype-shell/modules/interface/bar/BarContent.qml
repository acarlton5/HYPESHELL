import QtQuick
import QtQuick.Layouts
import Quickshell
import "content/"
import qs.config
import qs.modules.components
import qs.services

Item {
    property real uiScale: 1.0
    property int density: Config.runtime.bar.density
    property bool compactMode: false
    property bool isHorizontal: (Config.runtime.bar.position === "top" || Config.runtime.bar.position === "bottom")
    scale: uiScale

    Row {
        id: hCenterRow
        visible: isHorizontal && !compactMode
        anchors.centerIn: parent
        spacing: Metrics.spacing(4)

        SystemUsageModule {}
        MediaPlayerModule {
            visible: Config.runtime.plugins.mediaPlayer.showInBar
        }
        ActiveWindowModule {}
        ClockModule {}
    }

    RowLayout {
        id: hLeftRow

        visible: isHorizontal
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Metrics.spacing(4)
        anchors.leftMargin: density * 0.3

        ToggleModule {
            icon: "menu"
            iconSize: Metrics.iconSize(22)
            iconColor: Appearance.m3colors.m3primary
            toggle: Globals.visiblility.sidebarLeft

            onToggled: function(value) {
                Globals.visiblility.sidebarLeft = value
            }
        }

        WorkspaceModule {}
    }

    RowLayout {
        id: hRightRow

        visible: isHorizontal
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Metrics.spacing(4)
        anchors.rightMargin: density * 0.3

        SystemTray {
            id: sysTray
            visible: !compactMode
        }

        StyledText {
            id: seperator
            visible: !compactMode && (sysTray.items.count > 0) && Config.runtime.bar.modules.statusIcons.enabled
            Layout.alignment: Qt.AlignLeft
            font.pixelSize: Metrics.fontSize("hugeass")
            text: "·"
        }

        ClockModule {
            visible: compactMode
        }

        StatusIconsModule {}

        StyledText {
            id: seperator2
            visible: !compactMode
            Layout.alignment: Qt.AlignLeft
            font.pixelSize: Metrics.fontSize("hugeass")
            text: "·"
        }

        ToggleModule {
            icon: "power_settings_new"
            iconSize: Metrics.iconSize(22)
            iconColor: Appearance.m3colors.m3primary
            toggle: Globals.visiblility.powermenu

            onToggled: function(value) {
                Globals.visiblility.powermenu = value
            }
        }
    }

    // Vertical Layout
    Item {
        visible: !isHorizontal
        anchors.top: parent.top
        anchors.topMargin: density * 0.1
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: vRow.implicitHeight
        implicitHeight: vRow.implicitWidth

        Row {
            id: vRow
            anchors.centerIn: parent
            spacing: Metrics.spacing(8)
            rotation: 90

            ToggleModule {
                icon: "menu"
                iconSize: Metrics.iconSize(22)
                iconColor: Appearance.m3colors.m3primary
                toggle: Globals.visiblility.sidebarLeft
                rotation: 270

                onToggled: function(value) {
                    Globals.visiblility.sidebarLeft = value
                }
            }

            SystemUsageModule {}
            MediaPlayerModule {
                visible: Config.runtime.plugins.mediaPlayer.showInBar
            }

            SystemTray {
                rotation: 0
            }
        }
    }

    Item {
        visible: !isHorizontal
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 35
        implicitWidth: centerRow.implicitHeight
        implicitHeight: centerRow.implicitWidth

        Row {
            id: centerRow
            anchors.centerIn: parent

            WorkspaceModule {
                rotation: 90
            }
        }
    }

    Item {
        visible: !isHorizontal
        anchors.bottom: parent.bottom
        anchors.bottomMargin: density * 0.1
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: row.implicitHeight
        implicitHeight: row.implicitWidth

        Row {
            id: row
            anchors.centerIn: parent
            spacing: Metrics.spacing(6)
            rotation: 90

            ClockModule {
                rotation: 270
            }

            StatusIconsModule {}

            ToggleModule {
                icon: "power_settings_new"
                iconSize: Metrics.iconSize(22)
                iconColor: Appearance.m3colors.m3primary
                toggle: Globals.visiblility.powermenu
                rotation: 270

                onToggled: function(value) {
                    Globals.visiblility.powermenu = value
                }
            }
        }
    }
}
