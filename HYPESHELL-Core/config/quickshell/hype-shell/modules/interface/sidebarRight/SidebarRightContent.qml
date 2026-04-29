import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.components

Item {
    anchors.fill: parent
    
    // Hardening the width here too
    width: 500
    
    GadgetStage {
        side: "right"
    }
}
