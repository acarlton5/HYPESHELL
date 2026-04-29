import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components

ColumnLayout {
    spacing: Metrics.spacing(8)

    StyledSwitchOption {
        title: "Enabled"
        description: "Enable or disable the media player desktop gadget."
        prefField: "plugins.mediaPlayerWidget.enabled"
    }

    NumberStepper {
        label: "Peek Duration (ms)"
        description: "How long the gadget stays above windows when peeking."
        prefField: "plugins.mediaPlayerWidget.peekDurationMs"
        minimum: 500
        maximum: 60000
        step: 250
    }

}
