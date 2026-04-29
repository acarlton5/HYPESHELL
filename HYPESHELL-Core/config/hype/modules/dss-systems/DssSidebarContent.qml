/**
 * DssSidebarContent.qml — Inner UI of the DSS left sidebar.
 *
 * Sections (top → bottom):
 *   1. Header: icon, title, connection badge, refresh/close
 *   2. Repo picker: scrollable list of Gitea repos
 *   3. Selected repo info + action buttons (pull, start, stop, open DSS Web)
 *   4. Open Issues list
 *   5. Live Notifications feed
 *   6. Status bar
 */

import qs.config
import qs.modules.components
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    anchors.fill: parent

    // ── Props from parent ─────────────────────────────────────────────
    property bool   bridgeConnected:  false
    property var    repos:            []
    property var    issues:           []
    property var    myTasks:          []
    property var    notifications:    []
    property string selectedOwner:    ""
    property string selectedRepo:     ""
    property string selectedDisplay:  ""
    property string actionStatus:     ""
    property bool   actionBusy:       false

    // ── Signals to parent ─────────────────────────────────────────────
    signal repoSelected(string owner, string repo, string display)
    signal pullClicked()
    signal dockerStartClicked()
    signal dockerStopClicked()
    signal openDssClicked()
    signal closeClicked()

    // ── Helpers ───────────────────────────────────────────────────────
    readonly property var repoTypeLabels: ({
        db: "Database", fin: "Finance", ops: "Operations",
        admin: "Admin",  team: "Team",  docs: "Docs",
        hr: "HR",        sys: "Infrastructure"
    })

    function repoType(name) {
        const prefix = String(name || "").match(/^([a-z]+)-/)
        return prefix ? (repoTypeLabels[prefix[1]] || "Code") : "Code"
    }

    function stripPrefix(name) {
        return String(name || "").replace(/^(db|fin|ops|admin|team|docs|hr|sys)-/i, "")
    }

    function relTime(ts) {
        if (!ts) return ""
        const diff = Date.now() - new Date(ts).getTime()
        const m = Math.floor(diff / 60000)
        if (m < 1)   return "just now"
        if (m < 60)  return m + "m ago"
        const h = Math.floor(m / 60)
        if (h < 24)  return h + "h ago"
        return Math.floor(h / 24) + "d ago"
    }

    // ── Layout ────────────────────────────────────────────────────────
    ColumnLayout {
        anchors {
            fill:          parent
            leftMargin:    Metrics.margin("normal")
            rightMargin:   Metrics.margin("normal")
            topMargin:     Metrics.margin("large")
            bottomMargin:  Metrics.margin("normal")
        }
        spacing: Metrics.margin("normal")

        // ── 1. Header ─────────────────────────────────────────────────
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            radius: Metrics.radius("verylarge")
            color: Appearance.m3colors.m3surfaceContainerHigh

            // Icon
            StyledRect {
                id: headerIcon
                width: 46; height: 46
                radius: Metrics.radius("verylarge")
                anchors.left: parent.left
                anchors.leftMargin: Metrics.margin("small")
                anchors.verticalCenter: parent.verticalCenter
                color: Appearance.m3colors.m3primaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    iconSize: Metrics.iconSize(28)
                    icon: "hub"
                    color: Appearance.m3colors.m3onPrimaryContainer
                }
            }

            // Title + subtitle
            Column {
                anchors.left:           headerIcon.right
                anchors.leftMargin:     Metrics.margin("small")
                anchors.right:          headerActions.left
                anchors.rightMargin:    Metrics.margin("small")
                anchors.verticalCenter: parent.verticalCenter
                spacing: Metrics.spacing(2)

                StyledText {
                    text: "DSS Systems Workspace"
                    font.pixelSize: Metrics.fontSize("large")
                    elide: Text.ElideRight
                    width: parent.width
                }

                Row {
                    spacing: Metrics.spacing(6)

                    StyledRect {
                        width: 8; height: 8
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.bridgeConnected
                            ? Appearance.m3colors.m3primary
                            : Appearance.m3colors.m3error
                    }

                    StyledText {
                        text: root.bridgeConnected ? "Bridge live" : "Bridge offline"
                        font.pixelSize: Metrics.fontSize("small")
                        color: root.bridgeConnected
                            ? Appearance.m3colors.m3onSurfaceVariant
                            : Appearance.m3colors.m3error
                    }
                }
            }

            // Action buttons
            Row {
                id: headerActions
                anchors.right: parent.right
                anchors.rightMargin: Metrics.margin("small")
                anchors.verticalCenter: parent.verticalCenter
                spacing: Metrics.spacing(6)

                StyledButton {
                    text: ""; icon: "open_in_full"
                    secondary: true
                    tooltipText: "Open DSS Systems Panel"
                    onClicked: root.openDssClicked()
                }

                StyledButton {
                    text: ""; icon: "close"
                    secondary: true
                    tooltipText: "Close"
                    onClicked: root.closeClicked()
                }
            }
        }

        // ── divider ───────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 1; radius: 1
            color: Appearance.m3colors.m3outlineVariant
        }

        // ── 0. Tasks Assigned to Me ───────────────────────────────────
        StyledText {
            text: "Assigned to Me" + (root.myTasks.length > 0 ? " (" + root.myTasks.length + ")" : "")
            font.pixelSize: Metrics.fontSize("big")
            font.bold: true
            visible: root.myTasks.length > 0
        }

        Rectangle {
            visible: root.myTasks.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: Metrics.radius("large")
            color: Appearance.m3colors.m3surfaceContainer
            clip: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width
                    spacing: Metrics.spacing(6)

                    Repeater {
                        model: root.myTasks

                        StyledRect {
                            width: parent.width
                            height: 48
                            radius: Metrics.radius("verylarge")
                            color: Appearance.m3colors.m3surfaceContainerHigh

                            StyledRect {
                                id: taskIconBg
                                width: 32; height: 32
                                radius: Metrics.radius("verylarge")
                                anchors.left: parent.left
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                color: Appearance.m3colors.m3primaryContainer

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    iconSize: Metrics.iconSize(18)
                                    icon: "assignment"
                                    color: Appearance.m3colors.m3onPrimaryContainer
                                }
                            }

                            Column {
                                anchors.left: taskIconBg.right
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.right: parent.right
                                anchors.rightMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                StyledText {
                                    text: modelData.title
                                    font.pixelSize: Metrics.fontSize("small")
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                StyledText {
                                    text: (modelData.identifier || ("#" + modelData.number)) + " · " + (modelData.status || "open")
                                    font.pixelSize: Metrics.fontSize("small")
                                    color: Appearance.m3colors.m3onSurfaceVariant
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.openUrlExternally(modelData.html_url)
                            }
                        }
                    }
                }
            }
        }

        // ── 2. Repo picker ────────────────────────────────────────────
        StyledText {
            text: "Repositories"
            font.pixelSize: Metrics.fontSize("big")
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            radius: Metrics.radius("large")
            color: Appearance.m3colors.m3surfaceContainer
            clip: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width
                    spacing: Metrics.spacing(6)

                    Repeater {
                        model: root.repos

                        StyledRect {
                            width: parent.width
                            height: 46
                            radius: Metrics.radius("verylarge")
                            color: (root.selectedOwner === modelData.owner.login
                                    && root.selectedRepo === modelData.name)
                                ? Appearance.m3colors.m3primaryContainer
                                : Appearance.m3colors.m3surfaceContainerHigh

                            readonly property bool isSelected:
                                root.selectedOwner === modelData.owner.login
                                && root.selectedRepo === modelData.name

                            StyledRect {
                                id: repoIconBg
                                width: 32; height: 32
                                radius: Metrics.radius("verylarge")
                                anchors.left: parent.left
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                color: parent.isSelected
                                    ? Appearance.m3colors.m3primary
                                    : Appearance.m3colors.m3secondaryContainer

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    iconSize: Metrics.iconSize(18)
                                    icon: "folder"
                                    color: parent.parent.isSelected
                                        ? Appearance.m3colors.m3onPrimary
                                        : Appearance.m3colors.m3onSecondaryContainer
                                }
                            }

                            Column {
                                anchors.left: repoIconBg.right
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.right: issueBadge.left
                                anchors.rightMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                StyledText {
                                    text: root.stripPrefix(modelData.name)
                                    font.pixelSize: Metrics.fontSize("normal")
                                    elide: Text.ElideRight
                                    width: parent.width
                                    color: parent.parent.parent.isSelected
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurface
                                }

                                StyledText {
                                    text: root.repoType(modelData.name) + " · " + modelData.owner.login
                                    font.pixelSize: Metrics.fontSize("small")
                                    elide: Text.ElideRight
                                    width: parent.width
                                    color: parent.parent.parent.isSelected
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurfaceVariant
                                }
                            }

                            // Open issues badge
                            StyledRect {
                                id: issueBadge
                                visible: modelData.open_issues_count > 0
                                anchors.right: parent.right
                                anchors.rightMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                width: issueCountText.width + Metrics.margin("small") * 2
                                height: 20
                                radius: 10
                                color: Appearance.m3colors.m3errorContainer

                                StyledText {
                                    id: issueCountText
                                    anchors.centerIn: parent
                                    text: String(modelData.open_issues_count)
                                    font.pixelSize: Metrics.fontSize("small")
                                    color: Appearance.m3colors.m3onErrorContainer
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.repoSelected(
                                    modelData.owner.login,
                                    modelData.name,
                                    root.stripPrefix(modelData.name)
                                )
                            }
                        }
                    }

                    // Empty state
                    Item {
                        visible: root.repos.length === 0
                        width: parent.width
                        height: 80

                        Column {
                            anchors.centerIn: parent
                            spacing: Metrics.spacing(6)

                            MaterialSymbol {
                                anchors.horizontalCenter: parent.horizontalCenter
                                iconSize: Metrics.iconSize(28)
                                icon: "folder_off"
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "No repos — check token"
                                font.pixelSize: Metrics.fontSize("small")
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }
                        }
                    }
                }
            }
        }

        // ── 3. Selected repo actions ──────────────────────────────────
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 68
            visible: root.selectedRepo !== ""
            radius: Metrics.radius("verylarge")
            color: Appearance.m3colors.m3surfaceContainerHigh

            Row {
                anchors.centerIn: parent
                spacing: Metrics.spacing(8)

                StyledButton {
                    text: "Pull"
                    icon: "arrow_downward"
                    enabled: !root.actionBusy && root.selectedRepo !== ""
                    tooltipText: "git pull via DSS Bridge"
                    onClicked: root.pullClicked()
                }

                StyledButton {
                    text: "Start"
                    icon: "play_arrow"
                    enabled: !root.actionBusy && root.selectedRepo !== ""
                    tooltipText: "docker compose up -d"
                    onClicked: root.dockerStartClicked()
                }

                StyledButton {
                    text: "Stop"
                    icon: "stop"
                    secondary: true
                    enabled: !root.actionBusy && root.selectedRepo !== ""
                    tooltipText: "docker compose down"
                    onClicked: root.dockerStopClicked()
                }
            }
        }

        // ── 4. Open Issues ────────────────────────────────────────────
        StyledText {
            visible: root.selectedRepo !== ""
            text: "Open Items" + (root.issues.length > 0 ? " (" + root.issues.length + ")" : "")
            font.pixelSize: Metrics.fontSize("big")
            font.bold: true
        }

        Rectangle {
            visible: root.selectedRepo !== ""
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: Metrics.radius("large")
            color: Appearance.m3colors.m3surfaceContainer
            clip: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width
                    spacing: Metrics.spacing(6)

                    Repeater {
                        model: root.issues.slice(0, 12)

                        StyledRect {
                            width: parent.width
                            height: 44
                            radius: Metrics.radius("verylarge")
                            color: Appearance.m3colors.m3surfaceContainerHigh

                            MaterialSymbol {
                                id: issueIcon
                                anchors.left: parent.left
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                iconSize: Metrics.iconSize(18)
                                icon: "circle"
                                color: Appearance.m3colors.m3primary
                            }

                            Column {
                                anchors.left: issueIcon.right
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.right: issueTime.left
                                anchors.rightMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                StyledText {
                                    text: modelData.title
                                    font.pixelSize: Metrics.fontSize("small")
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                StyledText {
                                    text: "#" + modelData.number + " · " + modelData.user.login
                                    font.pixelSize: Metrics.fontSize("small")
                                    color: Appearance.m3colors.m3onSurfaceVariant
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            StyledText {
                                id: issueTime
                                anchors.right: parent.right
                                anchors.rightMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.relTime(modelData.created_at)
                                font.pixelSize: Metrics.fontSize("small")
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.openUrlExternally(modelData.html_url)
                            }
                        }
                    }

                    // Empty / loading state
                    Item {
                        visible: root.issues.length === 0
                        width: parent.width
                        height: 60

                        StyledText {
                            anchors.centerIn: parent
                            text: root.actionBusy ? "Loading…" : "All clear"
                            font.pixelSize: Metrics.fontSize("small")
                            color: Appearance.m3colors.m3onSurfaceVariant
                        }
                    }
                }
            }
        }

        // ── 5. Notifications ──────────────────────────────────────────
        StyledText {
            text: "Live Notifications" + (root.notifications.length > 0 ? " (" + root.notifications.length + ")" : "")
            font.pixelSize: Metrics.fontSize("big")
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 80
            radius: Metrics.radius("large")
            color: Appearance.m3colors.m3surfaceContainer
            clip: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width
                    spacing: Metrics.spacing(6)

                    Repeater {
                        model: root.notifications.slice(0, 20)

                        StyledRect {
                            width: parent.width
                            height: 48
                            radius: Metrics.radius("verylarge")
                            color: Appearance.m3colors.m3surfaceContainerHigh

                            StyledRect {
                                id: notifIcon
                                width: 32; height: 32
                                radius: Metrics.radius("verylarge")
                                anchors.left: parent.left
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                color: Appearance.m3colors.m3secondaryContainer

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    iconSize: Metrics.iconSize(18)
                                    icon: "notifications"
                                    color: Appearance.m3colors.m3onSecondaryContainer
                                }
                            }

                            Column {
                                anchors.left: notifIcon.right
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.right: notifTime.left
                                anchors.rightMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                StyledText {
                                    text: (modelData.label || "") + ": " + (modelData.display || "")
                                    font.pixelSize: Metrics.fontSize("small")
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                StyledText {
                                    text: (modelData.actor || "") + " · " + (modelData.repo || "")
                                    font.pixelSize: Metrics.fontSize("small")
                                    color: Appearance.m3colors.m3onSurfaceVariant
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            StyledText {
                                id: notifTime
                                anchors.right: parent.right
                                anchors.rightMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.relTime(modelData.ts)
                                font.pixelSize: Metrics.fontSize("small")
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }
                        }
                    }

                    // Empty state
                    Item {
                        visible: root.notifications.length === 0
                        width: parent.width
                        height: 60

                        Column {
                            anchors.centerIn: parent
                            spacing: Metrics.spacing(6)

                            MaterialSymbol {
                                anchors.horizontalCenter: parent.horizontalCenter
                                iconSize: Metrics.iconSize(22)
                                icon: "notifications_none"
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.bridgeConnected ? "No notifications yet" : "Bridge disconnected"
                                font.pixelSize: Metrics.fontSize("small")
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }
                        }
                    }
                }
            }
        }

        // ── 6. Status bar ─────────────────────────────────────────────
        StyledText {
            visible: root.actionStatus !== ""
            text: root.actionStatus
            font.pixelSize: Metrics.fontSize("small")
            color: root.actionStatus.startsWith("Error")
                ? Appearance.m3colors.m3error
                : Appearance.m3colors.m3onSurfaceVariant
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }
}
