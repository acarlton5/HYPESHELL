pragma Singleton
import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    // Core list of modules that come with the installer
    readonly property var coreModules: [
        { id: "overview", name: "Overview", icon: "overview", source: Qt.resolvedUrl("../modules/interface/sidebarLeft/SystemOverview.qml"), protected: true },
        { id: "appearance", name: "Appearance", icon: "palette", source: Qt.resolvedUrl("../modules/interface/sidebarLeft/AppearancePage.qml"), protected: true },
        { id: "settings", name: "Settings", icon: "settings", source: Qt.resolvedUrl("../modules/interface/settings/Settings.qml"), protected: true },
        { id: "quicksettings", name: "Quick Settings", icon: "settings_input_component", source: Qt.resolvedUrl("../modules/gadgets/QuickSettingsGadget.qml"), protected: true }
    ]

    // Sidebar Page Configuration
    property var leftSidebarPages: [
        { id: "overview", name: "Overview", icon: "overview", content: "SystemOverview" },
        { id: "appearance", name: "Appearance", icon: "palette", content: "AppearancePage" }
    ]
    
    property var rightSidebarPages: [
        { id: "qs", name: "Quick Settings", icon: "settings_input_component", content: "GadgetStage" }
    ]

    // Active gadgets WITHIN the GadgetStage (per side)
    property var leftSidebarGadgets: ["overview"]
    property var rightSidebarGadgets: ["quicksettings"]

    function getModule(id) {
        return coreModules.find(m => m.id === id) || null;
    }
}
