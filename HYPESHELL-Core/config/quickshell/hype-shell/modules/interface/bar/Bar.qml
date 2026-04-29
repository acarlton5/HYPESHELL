import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.components
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            property int rd: Config.runtime.bar.radius * Config.runtime.appearance.rounding.factor
            property int margin: Config.runtime.bar.margins
            property bool floating: Config.runtime.bar.floating
            property bool merged: Config.runtime.bar.merged
            property string pos: Config.runtime.bar.position
            property string screenName: String(modelData?.name || "")
            property bool isIntegratedDisplay: /edp/i.test(screenName)
            property real barScale: isIntegratedDisplay ? 0.84 : 1.0
            property int barDensity: Math.max(20, Math.round(Config.runtime.bar.density * barScale))
            property bool vertical: pos === "left" || pos === "right"

            screen: modelData
            visible: Config.runtime.bar.enabled && Config.initialized
            WlrLayershell.namespace: "hype:bar"
            exclusiveZone: floating ? barDensity + Metrics.margin("tiny") : barDensity
            implicitHeight: vertical ? undefined : barDensity
            implicitWidth: vertical ? barDensity : undefined
            color: "transparent"

            anchors {
                top: pos === "top" || pos === "left" || pos === "right"
                bottom: pos === "bottom" || pos === "left" || pos === "right"
                left: pos === "left" || pos === "top" || pos === "bottom"
                right: pos === "right" || pos === "top" || pos === "bottom"
            }

            margins {
                top: floating ? margin : (merged && vertical ? margin : 0)
                bottom: floating ? margin : (merged && vertical ? margin : 0)
                left: floating ? margin : (merged && !vertical ? margin : 0)
                right: floating ? margin : (merged && !vertical ? margin : 0)
            }

            StyledRect {
                id: background
                color: Appearance.m3colors.m3background
                anchors.fill: parent
                radius: floating ? rd : 0
                
                // Fallback for non-floating corners if merged
                topLeftRadius: floating ? rd : (merged && (pos === "bottom" || pos === "right") ? rd : 0)
                topRightRadius: floating ? rd : (merged && (pos === "bottom" || pos === "left") ? rd : 0)
                bottomLeftRadius: floating ? rd : (merged && (pos === "top" || pos === "right") ? rd : 0)
                bottomRightRadius: floating ? rd : (merged && (pos === "top" || pos === "left") ? rd : 0)

                BarContent {
                    anchors.fill: parent
                    uiScale: bar.barScale
                    density: bar.barDensity
                    compactMode: bar.isIntegratedDisplay
                }
            }
        }
    }
}
