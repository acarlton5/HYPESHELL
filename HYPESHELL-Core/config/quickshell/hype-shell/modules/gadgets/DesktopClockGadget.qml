import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.components

Item {
    id: root
    implicitWidth: 600
    implicitHeight: 300
    
    property bool showSeconds: Config.runtime.appearance.background.clock.showSeconds || false
    property bool is24h: Config.runtime.appearance.background.clock.is24h !== false
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: -20

        StyledText {
            text: Time.format(root.is24h ? (root.showSeconds ? "HH:mm:ss" : "HH:mm") : (root.showSeconds ? "hh:mm:ss AP" : "hh:mm AP"))
            font.pixelSize: 120
            font.weight: Font.Black
            color: Appearance.m3colors.m3primary
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            text: Time.format("dddd, MMMM d")
            font.pixelSize: 32
            font.weight: Font.Light
            color: Appearance.m3colors.m3onSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
            opacity: 0.8
        }
    }
}
