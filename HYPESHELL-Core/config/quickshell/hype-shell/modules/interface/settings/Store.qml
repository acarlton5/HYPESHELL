import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.functions
import qs.modules.components

ContentMenu {
    id: root

    title: "HypeStore"
    description: "Discover themes, gadgets, and shell modules for your desktop."

    property string searchQuery: ""
    property string currentCategory: "all"
    property string statusText: ""
    property bool loading: false
    property bool busy: catalogProcess.running || actionProcess.running
    property var catalog: []
    readonly property var fallbackFeatured: ({
        id: "hype-default",
        packageType: "HYPETHEME",
        name: "Hype Default",
        author: "HypeShell",
        version: "included",
        description: "The bundled HypeShell theme with wallpaper, palette, and shell overrides.",
        installed: true,
        sourceName: "Local"
    })
    property var featuredItem: catalog.length > 0 ? catalog[0] : fallbackFeatured
    readonly property var categories: [
        { id: "all", label: "All", icon: "grid_view", type: "" },
        { id: "themes", label: "Themes", icon: "palette", type: "HYPETHEME" },
        { id: "gadgets", label: "Gadgets", icon: "widgets", type: "HYPEGADGET" },
        { id: "modules", label: "Modules", icon: "extension", type: "HYPEMODULE" }
    ]
    readonly property var filteredCatalog: filterCatalog()

    function shellQuote(value) {
        return "'" + String(value || "").replace(/'/g, "'\"'\"'") + "'"
    }

    function packageTypeForCategory(categoryId) {
        if (categoryId === "themes")
            return "HYPETHEME"
        if (categoryId === "gadgets")
            return "HYPEGADGET"
        if (categoryId === "modules")
            return "HYPEMODULE"
        return ""
    }

    function labelForType(typeName) {
        if (typeName === "HYPETHEME")
            return "Theme"
        if (typeName === "HYPEGADGET")
            return "Gadget"
        if (typeName === "HYPEMODULE")
            return "Module"
        return "Package"
    }

    function iconForType(typeName) {
        if (typeName === "HYPETHEME")
            return "palette"
        if (typeName === "HYPEGADGET")
            return "widgets"
        if (typeName === "HYPEMODULE")
            return "extension"
        return "deployed_code"
    }

    function tintForType(typeName) {
        if (typeName === "HYPETHEME")
            return Appearance.m3colors.m3primaryContainer
        if (typeName === "HYPEGADGET")
            return Appearance.m3colors.m3tertiaryContainer
        if (typeName === "HYPEMODULE")
            return Appearance.m3colors.m3secondaryContainer
        return Appearance.m3colors.m3surfaceContainerHighest
    }

    function onTintForType(typeName) {
        if (typeName === "HYPETHEME")
            return Appearance.m3colors.m3onPrimaryContainer
        if (typeName === "HYPEGADGET")
            return Appearance.m3colors.m3onTertiaryContainer
        if (typeName === "HYPEMODULE")
            return Appearance.m3colors.m3onSecondaryContainer
        return Appearance.m3colors.m3onSurface
    }

    function filterCatalog() {
        const query = root.searchQuery.trim().toLowerCase()
        const categoryType = root.packageTypeForCategory(root.currentCategory)
        const results = []

        for (let i = 0; i < root.catalog.length; i++) {
            const item = root.catalog[i]
            if (categoryType !== "" && item.packageType !== categoryType)
                continue

            if (query.length > 0) {
                const haystack = [
                    item.name || "",
                    item.id || "",
                    item.author || "",
                    item.description || "",
                    item.sourceName || ""
                ].join(" ").toLowerCase()
                if (haystack.indexOf(query) === -1)
                    continue
            }

            results.push(item)
        }

        return results
    }

    function buildListCommand() {
        const script = shellQuote(Directories.scriptsPath + "/store/hype-store.sh")
        return [
            "bash",
            "-lc",
            "{ " +
            script + " list HYPETHEME; " +
            script + " list HYPEGADGET; " +
            script + " list HYPEMODULE; " +
            "} | jq -s 'add'"
        ]
    }

    function reloadCatalog() {
        if (catalogProcess.running)
            return

        root.loading = true
        root.statusText = "Refreshing catalog"
        catalogProcess.command = buildListCommand()
        catalogProcess.running = true
    }

    function runPackageAction(item) {
        if (!item || actionProcess.running)
            return

        const action = item.installed ? "uninstall" : "install"
        root.statusText = (item.installed ? "Removing " : "Installing ") + (item.name || item.id)
        actionProcess.command = [
            "bash",
            Directories.scriptsPath + "/store/hype-store.sh",
            action,
            item.packageType,
            item.id
        ]
        actionProcess.running = true
    }

    function installedCount() {
        let count = 0
        for (let i = 0; i < root.catalog.length; i++) {
            if (root.catalog[i].installed)
                count++
        }
        return count
    }

    function countForType(typeName) {
        if (typeName === "")
            return root.catalog.length

        let count = 0
        for (let i = 0; i < root.catalog.length; i++) {
            if (root.catalog[i].packageType === typeName)
                count++
        }
        return count
    }

    Component.onCompleted: reloadCatalog()

    ContentCard {
        Layout.fillWidth: true
        color: Appearance.m3colors.m3surfaceContainerLowest

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.margin("normal")

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.margin("normal")

                StyledRect {
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72
                    radius: Metrics.radius("large")
                    color: root.tintForType(root.featuredItem.packageType)

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: root.iconForType(root.featuredItem.packageType)
                        iconSize: 34
                        color: root.onTintForType(root.featuredItem.packageType)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(4)

                    RowLayout {
                        spacing: Metrics.spacing(8)

                        StyledText {
                            text: "Featured"
                            font.pixelSize: Metrics.fontSize("small")
                            color: Appearance.colors.colSubtext
                        }

                        StyledRect {
                            Layout.preferredWidth: typeLabel.implicitWidth + 18
                            Layout.preferredHeight: 24
                            radius: 12
                            color: Appearance.m3colors.m3surfaceContainerHigh

                            StyledText {
                                id: typeLabel
                                anchors.centerIn: parent
                                text: root.labelForType(root.featuredItem.packageType)
                                font.pixelSize: Metrics.fontSize("smaller")
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.featuredItem.name || "HypeStore"
                        font.pixelSize: Metrics.fontSize("huge")
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.featuredItem.description || "Browse installable packages for HypeShell."
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.colors.colSubtext
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }

                StyledButton {
                    Layout.preferredWidth: 132
                    text: root.featuredItem.installed ? "Installed" : "Get"
                    icon: root.featuredItem.installed ? "check" : "download"
                    secondary: root.featuredItem.installed
                    enabled: !root.featuredItem.installed && !root.busy
                    onClicked: root.runPackageAction(root.featuredItem)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(10)

                Repeater {
                    model: [
                        { label: "Catalog", value: root.catalog.length },
                        { label: "Installed", value: root.installedCount() },
                        { label: "Showing", value: root.filteredCatalog.length }
                    ]

                    StyledRect {
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 54
                        radius: Metrics.radius("normal")
                        color: Appearance.m3colors.m3surfaceContainer

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Metrics.margin("small")

                            StyledText {
                                text: modelData.value
                                font.pixelSize: Metrics.fontSize("larger")
                                font.bold: true
                            }

                            StyledText {
                                text: modelData.label
                                font.pixelSize: Metrics.fontSize("small")
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                StyledButton {
                    text: "Refresh"
                    icon: "refresh"
                    secondary: true
                    enabled: !root.busy
                    onClicked: root.reloadCatalog()
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Metrics.margin("small")

        Repeater {
            model: root.categories

            StyledButton {
                text: modelData.label + "  " + root.countForType(modelData.type)
                icon: modelData.icon
                secondary: root.currentCategory !== modelData.id
                checked: root.currentCategory === modelData.id
                onClicked: root.currentCategory = modelData.id
            }
        }

        Item { Layout.fillWidth: true }
    }

    StyledTextField {
        Layout.fillWidth: true
        Layout.preferredHeight: 52
        icon: "search"
        placeholder: "Search packages"
        text: root.searchQuery
        onTextChanged: root.searchQuery = text
    }

    StyledText {
        Layout.fillWidth: true
        text: root.statusText
        visible: root.statusText.length > 0
        color: Appearance.colors.colSubtext
        font.pixelSize: Metrics.fontSize("small")
    }

    GridLayout {
        Layout.fillWidth: true
        columns: root.width > 860 ? 2 : 1
        columnSpacing: Metrics.margin("normal")
        rowSpacing: Metrics.margin("normal")

        Repeater {
            model: root.filteredCatalog

            delegate: StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 148
                radius: Metrics.radius("normal")
                color: Appearance.m3colors.m3surfaceContainerLow
                border.color: Appearance.m3colors.m3outlineVariant
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Metrics.margin("normal")
                    spacing: Metrics.margin("normal")

                    StyledRect {
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 58
                        Layout.alignment: Qt.AlignTop
                        radius: Metrics.radius("normal")
                        color: root.tintForType(modelData.packageType)

                        MaterialSymbol {
                            anchors.centerIn: parent
                            icon: root.iconForType(modelData.packageType)
                            iconSize: 28
                            color: root.onTintForType(modelData.packageType)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Metrics.spacing(4)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Metrics.spacing(8)

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name || modelData.id
                                font.bold: true
                                font.pixelSize: Metrics.fontSize("large")
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: modelData.version || ""
                                visible: String(modelData.version || "").length > 0
                                font.pixelSize: Metrics.fontSize("smaller")
                                color: Appearance.colors.colSubtext
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.description || "No description provided."
                            font.pixelSize: Metrics.fontSize("small")
                            color: Appearance.colors.colSubtext
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Metrics.spacing(8)

                            StyledText {
                                Layout.fillWidth: true
                                text: (modelData.author || "Unknown") + " - " + (modelData.sourceName || "Catalog")
                                font.pixelSize: Metrics.fontSize("smaller")
                                color: Appearance.colors.colSubtext
                                elide: Text.ElideRight
                            }

                            StyledButton {
                                Layout.preferredWidth: 120
                                text: modelData.installed ? "Remove" : "Install"
                                icon: modelData.installed ? "delete" : "download"
                                secondary: modelData.installed
                                enabled: !root.busy
                                onClicked: root.runPackageAction(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    ContentCard {
        Layout.fillWidth: true
        visible: !root.loading && root.filteredCatalog.length === 0

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.margin("normal")

            MaterialSymbol {
                icon: "travel_explore"
                iconSize: 30
                color: Appearance.m3colors.m3onSurfaceVariant
            }

            ColumnLayout {
                Layout.fillWidth: true

                StyledText {
                    text: root.searchQuery.length > 0 ? "No matching packages" : "Catalog is empty"
                    font.pixelSize: Metrics.fontSize("large")
                    font.bold: true
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.searchQuery.length > 0
                        ? "Try a different search term or category."
                        : "Refresh the catalog after adding a source in ~/.config/hype/store/sources.json."
                    color: Appearance.colors.colSubtext
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Process {
        id: catalogProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.catalog = JSON.parse(text || "[]")
                    root.statusText = root.catalog.length > 0
                        ? "Catalog refreshed"
                        : "No packages found"
                } catch (e) {
                    root.catalog = []
                    root.statusText = "Catalog could not be parsed"
                }
            }
        }

        onExited: (exitCode) => {
            root.loading = false
            if (exitCode !== 0) {
                root.catalog = []
                root.statusText = "Catalog refresh failed"
            }
        }
    }

    Process {
        id: actionProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const message = String(text || "").trim()
                if (message.length > 0)
                    root.statusText = message
            }
        }

        onExited: (exitCode) => {
            if (exitCode === 0) {
                root.reloadCatalog()
            } else {
                root.statusText = "Package action failed"
            }
        }
    }
}
