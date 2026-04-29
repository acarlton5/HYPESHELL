import qs.config
import qs.modules.components
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    anchors.fill: parent

    property string scriptPath: Quickshell.env("HOME") + "/.local/share/bin/devusb-launch.sh"
    property var drives: []
    property var folders: []
    property var runRecords: []
    property var runCommand: []
    property var stopProjectCommand: []
    property var sessionsCommand: []
    property string selectedDrive: ""
    property string selectedFolder: ""
    property string folderQueryDrive: ""
    property string pendingStopProject: ""
    property string statusText: "Select a USB drive to begin."
    property bool loadingDrives: false
    property bool loadingFolders: false
    property bool stoppingAll: false
    property bool launchingProject: false
    property bool stoppingProject: false

    function driveLabel(item) {
        const label = String(item.label || "").trim()
        if (label.length > 0)
            return label
        const model = String(item.model || "").trim()
        if (model.length > 0)
            return model
        const mount = String(item.mount || "").trim()
        if (mount.length === 0)
            return "USB Drive"
        const parts = mount.split("/")
        return parts.length ? parts[parts.length - 1] : mount
    }

    function driveSize(item) {
        const size = String(item.size || "").trim()
        return size.length > 0 ? size : "Unknown size"
    }

    function folderButtonText(path) {
        const full = String(path || "").trim()
        if (!selectedDrive || full.length === 0)
            return ""
        const projectsPrefix = selectedDrive + "/projects/"
        if (full.startsWith(projectsPrefix))
            return full.slice(projectsPrefix.length)
        const parts = full.split("/")
        return parts.length ? parts[parts.length - 1] : full
    }

    function portFromUrl(url, fallback) {
        const text = String(url || "").trim()
        if (!text.length)
            return String(fallback || "--")
        const match = text.match(/:(\d+)(?:\/|$)/)
        if (match && match.length > 1)
            return String(match[1])
        return String(fallback || "--")
    }

    function sessionEndpointsText(item) {
        const appPort = portFromUrl(item.site, "--")
        const dbPort = portFromUrl(item.pma, "--")
        return "APP " + appPort + "    DB " + dbPort
    }

    function sessionDbText(item) {
        const user = String(item.dbUser || "").trim()
        const pass = String(item.dbPass || "").trim()
        const userText = user.length > 0 ? user : "unknown"
        const passText = pass.length > 0 ? pass : "unknown"
        return "User " + userText + "    Password " + passText
    }

    function upsertRunRecord(projectPath, state, siteUrl, pmaUrl, dbUser, dbPass) {
        const path = String(projectPath || "").trim()
        if (path.length === 0)
            return
        const name = folderButtonText(path).length > 0 ? folderButtonText(path) : path.split("/").pop()
        const next = runRecords.slice()
        const idx = next.findIndex(item => item.path === path)
        const record = {
            path: path,
            name: name,
            state: String(state || "warming"),
            site: String(siteUrl || ""),
            pma: String(pmaUrl || ""),
            dbUser: String(dbUser || ""),
            dbPass: String(dbPass || "")
        }
        if (idx >= 0)
            next[idx] = record
        else
            next.unshift(record)
        runRecords = next
    }

    function removeRunRecord(projectPath) {
        const path = String(projectPath || "").trim()
        if (path.length === 0)
            return
        runRecords = runRecords.filter(item => item.path !== path)
    }

    function setRunRecordState(projectPath, newState) {
        const path = String(projectPath || "").trim()
        if (path.length === 0)
            return
        const next = runRecords.slice()
        const idx = next.findIndex(item => item.path === path)
        if (idx < 0)
            return
        next[idx] = {
            path: next[idx].path,
            name: next[idx].name,
            state: String(newState || next[idx].state),
            site: next[idx].site,
            pma: next[idx].pma,
            dbUser: next[idx].dbUser,
            dbPass: next[idx].dbPass
        }
        runRecords = next
    }

    function refreshDrives() {
        if (drivesProc.running)
            return
        loadingDrives = true
        drivesProc.running = true
    }

    function refreshFolders() {
        if (!selectedDrive)
            return
        folderQueryDrive = selectedDrive
        loadingFolders = true
        if (foldersProc.running)
            foldersProc.running = false
        foldersProc.running = true
    }

    function selectDrive(mountPath) {
        const mount = String(mountPath || "").trim()
        if (mount.length === 0)
            return

        selectedDrive = mount
        selectedFolder = ""
        folders = []
        statusText = "Drive selected: " + selectedDrive
        refreshFolders()
        refreshSessions()
    }

    function refreshSessions() {
        if (selectedDrive.length === 0) {
            runRecords = []
            return
        }
        sessionsCommand = [scriptPath, "--running-projects", "--root", selectedDrive]
        if (sessionsProc.running)
            sessionsProc.running = false
        sessionsProc.running = true
    }

    function launchExistingFolder() {
        if (!selectedDrive || !selectedFolder)
            return
        if (launchProc.running)
            return
        launchingProject = true
        statusText = "Starting " + folderButtonText(selectedFolder) + "..."
        runCommand = [scriptPath, "--no-notify", "--root", selectedDrive, selectedFolder]
        launchProc.running = true
    }

    function createAndRun() {
        const name = String(newProjectName.text || "").trim()
        if (!selectedDrive || !name.length) {
            statusText = "Enter a project name first."
            return
        }
        if (launchProc.running)
            return
        launchingProject = true
        statusText = "Creating and starting " + name + "..."
        runCommand = [scriptPath, "--no-notify", "--root", selectedDrive, name]
        launchProc.running = true
    }

    function stopProject(projectPath) {
        const path = String(projectPath || "").trim()
        if (path.length === 0 || stopProjectProc.running)
            return
        stoppingProject = true
        pendingStopProject = path
        statusText = "Stopping " + folderButtonText(path) + "..."
        stopProjectCommand = [scriptPath, "--no-notify", "--stop-project", path]
        stopProjectProc.running = true
    }

    function stopAllContainers() {
        if (!selectedDrive) {
            statusText = "Select a drive first."
            return
        }
        if (stopAllProc.running)
            return
        stoppingAll = true
        statusText = "Stopping all compose projects..."
        stopAllProc.running = true
    }

    Component.onCompleted: {
        refreshDrives()
        refreshSessions()
    }

    Process {
        id: drivesProc
        command: [root.scriptPath, "--list-drives"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "")
                    .split("\n")
                    .map(l => l.trim())
                    .filter(l => l.length > 0)
                const parsed = []
                for (const line of lines) {
                    const parts = line.split("\t")
                    parsed.push({
                        mount: parts[0] || "",
                        label: parts[1] || "",
                        model: parts[2] || "",
                        size: parts[3] || "",
                        fstype: parts[4] || "",
                        dev: parts[5] || ""
                    })
                }
                root.drives = parsed
                root.loadingDrives = false

                if (!parsed.length) {
                    root.selectedDrive = ""
                    root.folders = []
                    root.selectedFolder = ""
                    root.runRecords = []
                    root.statusText = "No mounted USB drives found."
                    return
                }

                let keepSelected = false
                for (const item of parsed) {
                    if (item.mount === root.selectedDrive) {
                        keepSelected = true
                        break
                    }
                }
                if (!keepSelected)
                    root.selectDrive(parsed[0].mount)
                else {
                    root.refreshFolders()
                    root.refreshSessions()
                }
            }
        }
    }

    Process {
        id: foldersProc
        command: [root.scriptPath, "--list-folders", "--root", root.folderQueryDrive]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "")
                    .split("\n")
                    .map(l => l.trim())
                    .filter(l => l.length > 0)
                root.folders = lines
                root.loadingFolders = false

                if (!lines.length) {
                    root.selectedFolder = ""
                    root.statusText = "No projects found in /projects."
                    return
                }

                if (!lines.includes(root.selectedFolder))
                    root.selectedFolder = lines[0]

                root.statusText = "Project selected: " + root.folderButtonText(root.selectedFolder)
            }
        }
    }

    Process {
        id: stopAllProc
        command: [root.scriptPath, "--no-notify", "--stop-all", "--root", root.selectedDrive]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "").trim().split("\n").filter(l => l.trim().length > 0)
                const line = lines.length > 0 ? lines[lines.length - 1] : ""
                const parts = line.split("\t")
                const stopped = parts.length > 0 ? Number(parts[0]) || 0 : 0
                const total = parts.length > 1 ? Number(parts[1]) || 0 : 0
                const runningBefore = parts.length > 2 ? Number(parts[2]) || 0 : 0
                const failed = parts.length > 3 ? Number(parts[3]) || 0 : 0

                stoppingAll = false
                if (failed > 0)
                    statusText = `Stopped ${stopped}/${total} projects (${failed} failed).`
                else
                    statusText = `Stopped ${stopped}/${total} projects (running before: ${runningBefore}).`
                root.refreshDrives()
                root.refreshFolders()
                root.refreshSessions()
            }
        }
    }

    Process {
        id: sessionsProc
        command: root.sessionsCommand

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "")
                    .split("\n")
                    .map(l => l.trim())
                    .filter(l => l.length > 0)
                const parsed = []
                for (const line of lines) {
                    const parts = line.split("\t")
                    const path = parts[0] || ""
                    if (path.length === 0)
                        continue
                    const state = parts[1] || "unknown"
                    const site = parts[2] || ""
                    const pma = parts[3] || ""
                    const dbUser = parts[4] || ""
                    const dbPass = parts[5] || ""
                    const label = root.folderButtonText(path)
                    parsed.push({
                        path: path,
                        name: label.length > 0 ? label : path.split("/").pop(),
                        state: state,
                        site: site,
                        pma: pma,
                        dbUser: dbUser,
                        dbPass: dbPass
                    })
                }
                root.runRecords = parsed
            }
        }
    }

    Process {
        id: launchProc
        command: root.runCommand

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "").trim().split("\n").filter(l => l.trim().length > 0)
                const line = lines.length > 0 ? lines[lines.length - 1] : ""
                const parts = line.split("\t")
                const tag = parts.length > 0 ? parts[0] : ""

                launchingProject = false

                if (tag === "RUN" && parts.length >= 5) {
                    const projectPath = parts[1]
                    const runningState = parts[2] === "yes" ? "running" : "warming"
                    const siteUrl = parts[3]
                    const pmaUrl = parts[4]
                    upsertRunRecord(projectPath, runningState, siteUrl, pmaUrl)
                    selectedFolder = projectPath
                    statusText = runningState === "running"
                        ? ("Running: " + folderButtonText(projectPath))
                        : ("Warming up: " + folderButtonText(projectPath))
                    newProjectName.text = ""
                    root.refreshSessions()
                    return
                }

                if (tag === "ERROR" && parts.length >= 3) {
                    const projectPath = parts[1]
                    const reason = parts[2]
                    statusText = "Launch failed for " + folderButtonText(projectPath) + " (" + reason + ")."
                    root.refreshSessions()
                    return
                }

                statusText = "Launch finished."
                root.refreshSessions()
            }
        }
    }

    Process {
        id: stopProjectProc
        command: root.stopProjectCommand

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "").trim().split("\n").filter(l => l.trim().length > 0)
                const line = lines.length > 0 ? lines[lines.length - 1] : ""
                const parts = line.split("\t")
                const tag = parts.length > 0 ? parts[0] : ""
                const projectPath = parts.length > 1 ? parts[1] : pendingStopProject

                stoppingProject = false

                if (tag === "STOPPED") {
                    setRunRecordState(projectPath, "stopped")
                    statusText = "Stopped " + folderButtonText(projectPath) + "."
                    root.refreshSessions()
                    return
                }

                if (tag === "ERROR" && parts.length > 2) {
                    statusText = "Stop failed for " + folderButtonText(projectPath) + " (" + parts[2] + ")."
                    root.refreshSessions()
                    return
                }

                statusText = "Stop finished."
                root.refreshSessions()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Metrics.margin("normal")
        anchors.rightMargin: Metrics.margin("normal")
        anchors.topMargin: Metrics.margin("large")
        anchors.bottomMargin: Metrics.margin("large")
        spacing: Metrics.margin("normal")

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: Metrics.radius("verylarge")
            color: Appearance.m3colors.m3surfaceContainerHigh

            StyledRect {
                id: headerIconBg
                width: 50
                height: 50
                radius: Metrics.radius("verylarge")
                anchors.left: parent.left
                anchors.leftMargin: Metrics.margin("small")
                anchors.verticalCenter: parent.verticalCenter
                color: Appearance.m3colors.m3primaryContainer

                MaterialSymbol {
                    anchors.centerIn: parent
                    iconSize: Metrics.iconSize(35)
                    icon: "code"
                }
            }

            Row {
                id: headerActions
                anchors.right: parent.right
                anchors.rightMargin: Metrics.margin("small")
                anchors.verticalCenter: parent.verticalCenter
                spacing: Metrics.spacing(6)

                StyledButton {
                    text: ""
                    icon: "refresh"
                    secondary: true
                    tooltipText: "Refresh drives"
                    onClicked: root.refreshDrives()
                }

                StyledButton {
                    text: ""
                    icon: "power_settings_new"
                    secondary: true
                    enabled: !!root.selectedDrive && !root.stoppingAll
                    tooltipText: "Stop all compose projects"
                    onClicked: root.stopAllContainers()
                }

                StyledButton {
                    text: ""
                    icon: "close"
                    secondary: true
                    tooltipText: "Close"
                    onClicked: Globals.visiblility.sidebarDev = false
                }
            }

            Column {
                anchors.left: headerIconBg.right
                anchors.leftMargin: Metrics.margin("small")
                anchors.right: headerActions.left
                anchors.rightMargin: Metrics.margin("small")
                anchors.verticalCenter: parent.verticalCenter
                spacing: Metrics.spacing(2)

                StyledText {
                    text: "Developer Mode"
                    font.pixelSize: Metrics.fontSize("large")
                    elide: Text.ElideRight
                    width: root.width - headerIconBg.width - headerActions.width - Metrics.margin("large")
                }

                StyledText {
                    text: root.selectedDrive.length > 0 ? "USB drive selected" : "Pick a USB drive"
                    font.pixelSize: Metrics.fontSize("small")
                    color: Appearance.m3colors.m3onSurfaceVariant
                    elide: Text.ElideRight
                    width: root.width - headerIconBg.width - headerActions.width - Metrics.margin("large")
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            radius: 1
            color: Appearance.m3colors.m3outlineVariant
        }

        StyledText {
            text: "Drives"
            font.pixelSize: Metrics.fontSize("big")
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            radius: Metrics.radius("large")
            color: Appearance.m3colors.m3surfaceContainer

            ScrollView {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")
                clip: true

                Column {
                    width: parent.width
                    spacing: Metrics.spacing(8)

                    Repeater {
                        model: root.drives
                        delegate: StyledRect {
                            width: parent.width
                            height: 52
                            radius: Metrics.radius("verylarge")
                            color: root.selectedDrive === modelData.mount
                                ? Appearance.m3colors.m3primaryContainer
                                : Appearance.m3colors.m3surfaceContainerHigh

                            StyledRect {
                                id: driveIconBg
                                width: 40
                                height: 40
                                radius: Metrics.radius("verylarge")
                                anchors.left: parent.left
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.selectedDrive === modelData.mount
                                    ? Appearance.m3colors.m3primary
                                    : Appearance.m3colors.m3secondaryContainer

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    iconSize: Metrics.iconSize(26)
                                    icon: "usb"
                                    color: root.selectedDrive === modelData.mount
                                        ? Appearance.m3colors.m3onPrimary
                                        : Appearance.m3colors.m3onSecondaryContainer
                                }
                            }

                            Column {
                                anchors.left: driveIconBg.right
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.right: parent.right
                                anchors.rightMargin: Metrics.margin("normal")
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Metrics.spacing(1)

                                StyledText {
                                    text: root.driveLabel(modelData)
                                    font.pixelSize: Metrics.fontSize("normal")
                                    elide: Text.ElideRight
                                    width: parent.width
                                    color: root.selectedDrive === modelData.mount
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurface
                                }

                                StyledText {
                                    text: root.driveSize(modelData)
                                    font.pixelSize: Metrics.fontSize("small")
                                    elide: Text.ElideRight
                                    width: parent.width
                                    color: root.selectedDrive === modelData.mount
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurfaceVariant
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectDrive(modelData.mount)
                                }
                            }
                        }
                    }
                }
            }
        }

        StyledText {
            text: "Projects"
            font.pixelSize: Metrics.fontSize("big")
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 170
            radius: Metrics.radius("large")
            color: Appearance.m3colors.m3surfaceContainer

            ScrollView {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")
                clip: true

                Column {
                    width: parent.width
                    spacing: Metrics.spacing(8)

                    Repeater {
                        model: root.folders
                        delegate: StyledRect {
                            width: parent.width
                            height: 52
                            radius: Metrics.radius("verylarge")
                            color: root.selectedFolder === modelData
                                ? Appearance.m3colors.m3primaryContainer
                                : Appearance.m3colors.m3surfaceContainerHigh

                            StyledRect {
                                id: folderIconBg
                                width: 40
                                height: 40
                                radius: Metrics.radius("verylarge")
                                anchors.left: parent.left
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.selectedFolder === modelData
                                    ? Appearance.m3colors.m3primary
                                    : Appearance.m3colors.m3secondaryContainer

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    iconSize: Metrics.iconSize(26)
                                    icon: "folder"
                                    color: root.selectedFolder === modelData
                                        ? Appearance.m3colors.m3onPrimary
                                        : Appearance.m3colors.m3onSecondaryContainer
                                }
                            }

                            StyledText {
                                anchors.left: folderIconBg.right
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.right: parent.right
                                anchors.rightMargin: Metrics.margin("normal")
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.folderButtonText(modelData)
                                font.pixelSize: Metrics.fontSize("normal")
                                elide: Text.ElideRight
                                color: root.selectedFolder === modelData
                                    ? Appearance.m3colors.m3onPrimaryContainer
                                    : Appearance.m3colors.m3onSurface
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedFolder = modelData
                                    root.launchExistingFolder()
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(10)

            StyledTextField {
                id: newProjectName
                Layout.fillWidth: true
                placeholder: "new-project"
                icon: "folder"
                onAccepted: root.createAndRun()
            }

            StyledButton {
                text: "Create + Run"
                icon: "add"
                enabled: !!root.selectedDrive && !root.launchingProject
                onClicked: root.createAndRun()
            }
        }

        StyledText {
            text: "Sessions"
            font.pixelSize: Metrics.fontSize("big")
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            radius: Metrics.radius("large")
            color: Appearance.m3colors.m3surfaceContainer

            ScrollView {
                anchors.fill: parent
                anchors.margins: Metrics.margin("small")
                clip: true

                Column {
                    width: parent.width
                    spacing: Metrics.spacing(8)

                    Repeater {
                        model: root.runRecords
                        delegate: StyledRect {
                            width: parent.width
                            height: 78
                            radius: Metrics.radius("verylarge")
                            color: modelData.state === "running"
                                ? Appearance.m3colors.m3primaryContainer
                                : Appearance.m3colors.m3surfaceContainerHigh

                            StyledRect {
                                width: 36
                                height: 36
                                radius: Metrics.radius("verylarge")
                                anchors.left: parent.left
                                anchors.leftMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                color: modelData.state === "running"
                                    ? Appearance.m3colors.m3primary
                                    : Appearance.m3colors.m3secondaryContainer

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    iconSize: Metrics.iconSize(22)
                                    icon: "dns"
                                    color: modelData.state === "running"
                                        ? Appearance.m3colors.m3onPrimary
                                        : Appearance.m3colors.m3onSecondaryContainer
                                }
                            }

                                Column {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Metrics.margin("small") + 44
                                    anchors.right: stopBtn.left
                                    anchors.rightMargin: Metrics.margin("small")
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Metrics.spacing(1)

                                StyledText {
                                    text: modelData.name
                                    font.pixelSize: Metrics.fontSize("normal")
                                    elide: Text.ElideRight
                                    width: parent.width
                                    color: modelData.state === "running"
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurface
                                }

                                StyledText {
                                    text: root.sessionEndpointsText(modelData)
                                    font.pixelSize: Metrics.fontSize("small")
                                    elide: Text.ElideRight
                                    width: parent.width
                                    color: modelData.state === "running"
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurfaceVariant
                                }

                                StyledText {
                                    text: root.sessionDbText(modelData)
                                    font.pixelSize: Metrics.fontSize("small")
                                    elide: Text.ElideRight
                                    width: parent.width
                                    color: modelData.state === "running"
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurfaceVariant
                                }
                            }

                            StyledButton {
                                id: stopBtn
                                anchors.right: parent.right
                                anchors.rightMargin: Metrics.margin("small")
                                anchors.verticalCenter: parent.verticalCenter
                                text: ""
                                icon: "power_settings_new"
                                secondary: true
                                enabled: !root.stoppingProject
                                    && modelData.state !== "stopped"
                                tooltipText: "Stop"
                                onClicked: root.stopProject(modelData.path)
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        StyledText {
            text: root.loadingDrives
                ? "Loading drives..."
                : (root.loadingFolders ? "Loading projects..." : root.statusText)
            font.pixelSize: Metrics.fontSize("small")
            color: Appearance.m3colors.m3onSurfaceVariant
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }
}
