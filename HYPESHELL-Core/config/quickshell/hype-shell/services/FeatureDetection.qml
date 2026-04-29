import QtQuick
import Quickshell

Item {
    id: root
    property bool hasGlobalShortcuts: false
    
    Component.onCompleted: {
        try {
            const comp = Qt.createComponent("TestShortcut.qml");
            if (comp.status === Component.Ready) {
                root.hasGlobalShortcuts = true;
                console.log("[HypeShell] GlobalShortcut support detected.");
            } else {
                console.warn("[HypeShell] GlobalShortcut support NOT detected.");
            }
        } catch (e) {
            console.warn("[HypeShell] GlobalShortcut support NOT detected.");
        }
    }
}
