import QtQuick

Item {
    id: root

    property Item target
    property var bounds
    property bool dragEnabled: true
    property int dragButtons: Qt.RightButton
    property real edgeMargin: 50
    property bool dragging: dragHandler.active
    property real startSceneX: 0
    property real startSceneY: 0
    property real startTargetX: 0
    property real startTargetY: 0

    signal dragFinished()

    function clamp(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value))
    }

    function minX() {
        return Math.max(0, edgeMargin)
    }

    function minY() {
        return Math.max(0, edgeMargin)
    }

    function maxX() {
        if (!target)
            return 0
        const w = bounds ? bounds.width : width
        const maxValue = w - target.width - edgeMargin
        return Math.max(minX(), maxValue)
    }

    function maxY() {
        if (!target)
            return 0
        const h = bounds ? bounds.height : height
        const maxValue = h - target.height - edgeMargin
        return Math.max(minY(), maxValue)
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.dragEnabled && root.target !== null
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        cursorShape: root.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
    }

    DragHandler {
        id: dragHandler
        target: null
        enabled: root.dragEnabled && root.target !== null
        acceptedButtons: root.dragButtons
        grabPermissions: PointerHandler.CanTakeOverFromAnything
            | PointerHandler.CanTakeOverFromHandlersOfDifferentType
            | PointerHandler.CanTakeOverFromItems

        onActiveChanged: {
            if (active) {
                root.startSceneX = centroid.scenePosition.x
                root.startSceneY = centroid.scenePosition.y
                root.startTargetX = root.target ? root.target.x : 0
                root.startTargetY = root.target ? root.target.y : 0
            } else {
                root.dragFinished()
            }
        }

        onCentroidChanged: {
            if (!active || !root.target)
                return

            const dx = centroid.scenePosition.x - root.startSceneX
            const dy = centroid.scenePosition.y - root.startSceneY

            root.target.x = root.clamp(root.startTargetX + dx, root.minX(), root.maxX())
            root.target.y = root.clamp(root.startTargetY + dy, root.minY(), root.maxY())
        }
    }
}
