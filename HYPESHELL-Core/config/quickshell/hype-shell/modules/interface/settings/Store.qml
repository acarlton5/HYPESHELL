import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.components

Item {
    id: root

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
            return MaterialColors.colors.primary_container
        if (typeName === "HYPEGADGET")
            return MaterialColors.colors.tertiary_container
        if (typeName === "HYPEMODULE")
            return MaterialColors.colors.secondary_container
        return MaterialColors.colors.surface_container_highest
    }

    function onTintForType(typeName) {
        if (typeName === "HYPETHEME")
            return MaterialColors.colors.on_primary_container
        if (typeName === "HYPEGADGET")
            return MaterialColors.colors.on_tertiary_container
        if (typeName === "HYPEMODULE")
            return MaterialColors.colors.on_secondary_container
        return MaterialColors.colors.on_surface
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

        const isTheme = item.packageType === "HYPETHEME"
        const action = isTheme && item.installed ? "apply" : (item.installed ? "uninstall" : "install")
        root.statusText = action === "apply"
            ? "Applying " + (item.name || item.id)
            : (item.installed ? "Removing " : "Installing ") + (item.name || item.id)
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

    Rectangle {
        anchors.fill: parent
        color: MaterialColors.colors.background
        radius: Appearance.rounding.large
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.margin("verylarge")
        spacing: Metrics.spacing(16)

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(18)

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(2)

                StyledText {
                    text: "HypeStore"
                    font.pixelSize: Metrics.fontSize("wildass")
                    font.weight: Font.Black
                    color: MaterialColors.colors.on_background
                }

                StyledText {
                    text: "Themes, gadgets, and shell modules"
                    font.pixelSize: Metrics.fontSize("normal")
                    color: MaterialColors.colors.on_surface_variant
                }
            }

            StyledTextField {
                Layout.preferredWidth: Math.min(420, root.width * 0.36)
                Layout.preferredHeight: 50
                icon: "search"
                placeholder: "Search store"
                text: root.searchQuery
                onTextChanged: root.searchQuery = text
            }

            StyledButton {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                icon: "refresh"
                text: ""
                secondary: true
                enabled: !root.busy
                tooltipText: "Refresh catalog"
                onClicked: root.reloadCatalog()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(10)

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

            StyledText {
                text: root.statusText
                visible: root.statusText.length > 0
                color: MaterialColors.colors.on_surface_variant
                font.pixelSize: Metrics.fontSize("small")
                elide: Text.ElideRight
                Layout.maximumWidth: 300
            }
        }

        Flickable {
            id: scroll

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: contentColumn.implicitHeight + Metrics.margin("normal")
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { }

            ColumnLayout {
                id: contentColumn

                width: scroll.width
                spacing: Metrics.spacing(16)

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 168
                    radius: Metrics.radius("large")
                    color: MaterialColors.colors.surface_container_low
                    border.color: MaterialColors.colors.outline_variant
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Metrics.margin("large")
                        spacing: Metrics.spacing(18)

                        Rectangle {
                            Layout.preferredWidth: 96
                            Layout.preferredHeight: 96
                            radius: Metrics.radius("large")
                            color: root.tintForType(root.featuredItem.packageType)

                            MaterialSymbol {
                                anchors.centerIn: parent
                                icon: root.iconForType(root.featuredItem.packageType)
                                iconSize: 46
                                color: root.onTintForType(root.featuredItem.packageType)
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Metrics.spacing(8)

                            RowLayout {
                                spacing: Metrics.spacing(8)

                                StorePill {
                                    label: "Featured"
                                }

                                StorePill {
                                    label: root.labelForType(root.featuredItem.packageType)
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: root.featuredItem.name || "HypeStore"
                                font.pixelSize: Metrics.fontSize("hugeass")
                                font.weight: Font.Black
                                color: MaterialColors.colors.on_surface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: root.featuredItem.description || "Browse installable packages for HypeShell."
                                font.pixelSize: Metrics.fontSize("normal")
                                color: MaterialColors.colors.on_surface_variant
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }

                        StyledButton {
                            Layout.preferredWidth: 132
                            text: root.featuredItem.packageType === "HYPETHEME" && root.featuredItem.installed
                                ? "Apply"
                                : (root.featuredItem.installed ? "Installed" : "Get")
                            icon: root.featuredItem.packageType === "HYPETHEME" && root.featuredItem.installed
                                ? "palette"
                                : (root.featuredItem.installed ? "check" : "download")
                            secondary: root.featuredItem.installed
                            enabled: (root.featuredItem.packageType === "HYPETHEME" || !root.featuredItem.installed) && !root.busy
                            onClicked: root.runPackageAction(root.featuredItem)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacing(12)

                    StoreStat {
                        label: "Catalog"
                        value: String(root.catalog.length)
                    }
                    StoreStat {
                        label: "Installed"
                        value: String(root.installedCount())
                    }
                    StoreStat {
                        label: "Showing"
                        value: String(root.filteredCatalog.length)
                    }
                    Item { Layout.fillWidth: true }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: root.width > 940 ? 2 : 1
                    columnSpacing: Metrics.spacing(14)
                    rowSpacing: Metrics.spacing(14)

                    Repeater {
                        model: root.filteredCatalog

                        delegate: StorePackageCard {
                            Layout.fillWidth: true
                            itemData: modelData
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 118
                    radius: Metrics.radius("large")
                    color: MaterialColors.colors.surface_container
                    visible: !root.loading && root.filteredCatalog.length === 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Metrics.margin("large")
                        spacing: Metrics.spacing(14)

                        MaterialSymbol {
                            icon: "travel_explore"
                            iconSize: 34
                            color: MaterialColors.colors.on_surface_variant
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: root.searchQuery.length > 0 ? "No matching packages" : "Catalog is empty"
                                font.pixelSize: Metrics.fontSize("large")
                                font.bold: true
                                color: MaterialColors.colors.on_surface
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: root.searchQuery.length > 0
                                    ? "Try a different search term or category."
                                    : "Refresh the catalog after adding a source in ~/.config/hype/store/sources.json."
                                color: MaterialColors.colors.on_surface_variant
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }

    component StorePill: Rectangle {
        property string label: ""

        implicitWidth: pillText.implicitWidth + 20
        implicitHeight: 26
        radius: 13
        color: MaterialColors.colors.surface_container_high

        StyledText {
            id: pillText
            anchors.centerIn: parent
            text: label
            font.pixelSize: Metrics.fontSize("smaller")
            color: MaterialColors.colors.on_surface_variant
        }
    }

    component StoreStat: Rectangle {
        property string label: ""
        property string value: ""

        Layout.preferredWidth: 150
        Layout.preferredHeight: 62
        radius: Metrics.radius("normal")
        color: MaterialColors.colors.surface_container

        RowLayout {
            anchors.fill: parent
            anchors.margins: Metrics.margin("small")
            spacing: Metrics.spacing(8)

            StyledText {
                text: value
                font.pixelSize: Metrics.fontSize("huge")
                font.weight: Font.Black
                color: MaterialColors.colors.on_surface
            }

            StyledText {
                text: label
                font.pixelSize: Metrics.fontSize("small")
                color: MaterialColors.colors.on_surface_variant
            }
        }
    }

    component StorePackageCard: Rectangle {
        property var itemData: ({})

        Layout.preferredHeight: 160
        radius: Metrics.radius("large")
        color: MaterialColors.colors.surface_container_low
        border.color: MaterialColors.colors.outline_variant
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: Metrics.margin("normal")
            spacing: Metrics.spacing(14)

            Rectangle {
                Layout.preferredWidth: 62
                Layout.preferredHeight: 62
                Layout.alignment: Qt.AlignTop
                radius: Metrics.radius("normal")
                color: root.tintForType(itemData.packageType)

                MaterialSymbol {
                    anchors.centerIn: parent
                    icon: root.iconForType(itemData.packageType)
                    iconSize: 30
                    color: root.onTintForType(itemData.packageType)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Metrics.spacing(5)

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        Layout.fillWidth: true
                        text: itemData.name || itemData.id
                        font.bold: true
                        font.pixelSize: Metrics.fontSize("large")
                        color: MaterialColors.colors.on_surface
                        elide: Text.ElideRight
                    }

                    StorePill {
                        label: root.labelForType(itemData.packageType)
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: itemData.description || "No description provided."
                    font.pixelSize: Metrics.fontSize("small")
                    color: MaterialColors.colors.on_surface_variant
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
                        text: (itemData.author || "Unknown") + " / " + (itemData.sourceName || "Catalog")
                        font.pixelSize: Metrics.fontSize("smaller")
                        color: MaterialColors.colors.on_surface_variant
                        elide: Text.ElideRight
                    }

                    StyledButton {
                        Layout.preferredWidth: 116
                        text: itemData.packageType === "HYPETHEME" && itemData.installed
                            ? "Apply"
                            : (itemData.installed ? "Remove" : "Install")
                        icon: itemData.packageType === "HYPETHEME" && itemData.installed
                            ? "palette"
                            : (itemData.installed ? "delete" : "download")
                        secondary: itemData.installed
                        enabled: !root.busy
                        onClicked: root.runPackageAction(itemData)
                    }
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
