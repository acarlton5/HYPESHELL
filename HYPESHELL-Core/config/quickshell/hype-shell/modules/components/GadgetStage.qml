import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.components

Item {
    id: root
    property string side: "left" // "left" or "right"
    
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.margin("small")
        spacing: Metrics.margin("small")

        Repeater {
            model: root.side === "left" ? ModuleManager.leftSidebarGadgets : ModuleManager.rightSidebarGadgets
            
            delegate: Item {
                Layout.fillWidth: true
                Layout.preferredHeight: moduleLoader.item ? Math.max(moduleLoader.item.implicitHeight, 100) : 100
                
                HypeModule {
                    id: moduleLoader
                    anchors.fill: parent
                    moduleId: modelData
                    moduleName: ModuleManager.getModule(modelData)?.name || ""
                    source: ModuleManager.getModule(modelData)?.source || ""
                }
            }
        }
    }
}
