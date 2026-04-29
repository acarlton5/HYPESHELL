import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.config
import qs.modules.components

Item {
    id: root
    anchors.fill: parent

    Flickable {
        anchors.fill: parent
        contentHeight: contentLayout.implicitHeight + 150
        clip: true
        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: contentLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Metrics.margin("small")
            anchors.rightMargin: Metrics.margin("small")
            anchors.topMargin: 100
            spacing: Metrics.margin("small")

            Repeater {
                model: ModuleManager.leftSidebarGadgets
                
                delegate: HypeModule {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    moduleId: modelData
                    moduleName: ModuleManager.getModule(modelData)?.name || ""
                    source: ModuleManager.getModule(modelData)?.source || ""
                }
            }
        }
    }
}
