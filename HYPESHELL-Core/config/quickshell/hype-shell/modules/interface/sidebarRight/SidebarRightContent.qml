import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.config
import qs.modules.components
import qs.modules.gadgets

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.margin("normal")
        spacing: Metrics.spacing(12)

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            radius: Metrics.radius("normal")
            color: Appearance.m3colors.m3surfaceContainer

            RowLayout {
                anchors.fill: parent
                anchors.margins: Metrics.margin("normal")
                spacing: Metrics.spacing(12)

                StyledRect {
                    Layout.preferredWidth: 54
                    Layout.preferredHeight: 54
                    radius: Metrics.radius("large")
                    color: Appearance.m3colors.m3primaryContainer

                    StyledText {
                        anchors.centerIn: parent
                        text: SystemDetails.osIcon.length > 0 ? SystemDetails.osIcon : "\uf303"
                        font.family: Metrics.fontFamily("nerdIcons")
                        font.pixelSize: Metrics.fontSize(28)
                        color: Appearance.m3colors.m3onPrimaryContainer
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(2)

                    StyledText {
                        Layout.fillWidth: true
                        text: SystemDetails.osName.length > 0 ? SystemDetails.osName : "Arch Linux"
                        font.pixelSize: Metrics.fontSize("large")
                        font.weight: Font.Bold
                        color: Appearance.m3colors.m3onSurface
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: SystemDetails.uptime.length > 0 ? SystemDetails.uptime : "Up --"
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }

                StyledButton {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    icon: "settings"
                    text: ""
                    secondary: true
                    tooltipText: "Settings"
                    onClicked: {
                        Globals.visiblility.sidebarRight = false
                        Globals.states.settingsOpen = true
                    }
                }

                StyledButton {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    icon: "shopping_cart"
                    text: ""
                    secondary: true
                    tooltipText: "Store"
                    onClicked: HypeActions.openStore()
                }
            }
        }

        Flickable {
            id: scroll

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: quickSettings.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { }

            QuickSettingsGadget {
                id: quickSettings

                width: scroll.width
            }
        }
    }
}
