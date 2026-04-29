import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.modules.components
import qs.modules.gadgets

Item {
    id: root
    anchors.fill: parent

    Flickable {
        id: scroll

        anchors.fill: parent
        anchors.margins: Metrics.margin("normal")
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
