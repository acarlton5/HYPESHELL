/**
 * Settings.qml — DSS Workspace module settings panel.
 * Rendered inside Hype's settings UI.
 */

import qs.config
import qs.modules.components
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: Metrics.margin("small")

    StyledSwitchOption {
        title: "Enable DSS Systems Workspace"
        subtitle: "Show DSS Systems sidebar and launcher tile"
        prefField: "modules.dssSystems.enabled"
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1; radius: 1
        color: Appearance.m3colors.m3outlineVariant
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        radius: Metrics.radius("normal")
        color: Appearance.m3colors.m3surfaceContainerHigh

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.margin("normal")
            spacing: 2

            StyledText {
                text: "Keyboard Shortcut"
                font.pixelSize: Metrics.fontSize("normal")
                font.bold: true
            }

            StyledText {
                text: "Super + Shift + D"
                font.pixelSize: Metrics.fontSize("large")
                color: Appearance.m3colors.m3primary
            }

            StyledText {
                text: "Toggles the DSS Systems dashboard expansion."
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: 52
        radius: Metrics.radius("verylarge")
        color: Appearance.m3colors.m3surfaceContainerHigh

        Row {
            anchors.left: parent.left
            anchors.leftMargin: Metrics.margin("normal")
            anchors.verticalCenter: parent.verticalCenter
            spacing: Metrics.margin("small")

            StyledRect {
                width: 10; height: 10; radius: 5
                anchors.verticalCenter: parent.verticalCenter
                color: Appearance.m3colors.m3primary
            }

            StyledText {
                text: "Bridge Integration: http://localhost:8080"
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.m3colors.m3onSurfaceVariant
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
