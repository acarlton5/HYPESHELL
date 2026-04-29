pragma Singleton
import QtQuick

QtObject {
    readonly property string pluginName: "mediaPlayerWidget"
    readonly property var defaults: ({
        enabled: true,
        positionPreset: "top-center",
        xPos: 0,
        yPos: 0,
        peekRequest: "",
        peekDurationMs: 5000,
    })
}
