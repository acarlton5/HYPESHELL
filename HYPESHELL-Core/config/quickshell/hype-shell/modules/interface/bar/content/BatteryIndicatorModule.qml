import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components
import qs.services

Item {
    id: batteryIndicatorModuleContainer

    visible: UPower.batteryPresent
    Layout.alignment: Qt.AlignVCenter

    // Determine if bar is isVertical
    property bool isVertical: Config.runtime.bar.position === "left" || Config.runtime.bar.position === "right"

    implicitWidth: bgRect.implicitWidth
    implicitHeight: bgRect.implicitHeight

    Rectangle {
        id: bgRect
        color: Appearance.m3colors.m3surfaceContainerLow
        radius: Metrics.radius("small")
        border.color: Appearance.m3colors.m3outlineVariant
        border.width: 1

        implicitWidth: child.implicitWidth + Metrics.margin("large")
        implicitHeight: 32
        visible: !isVertical
    }

    RowLayout {
        id: child
        anchors.centerIn: parent
        spacing: Metrics.spacing(8)

        // Nerd Font Battery Icon (Matches Login Screen)
        StyledText {
            text: UPower.battIcon // UPower service should provide Nerd Font glyphs if possible, or we use a mapping
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Metrics.fontSize(20)
            color: Appearance.m3colors.m3primary
        }

        // Battery percentage text
        StyledText {
            text: UPower.percentage + "%"
            font.pixelSize: Metrics.fontSize(14)
            font.bold: true
            color: Appearance.m3colors.m3onSurface
            visible: !isVertical
        }
    }
}
