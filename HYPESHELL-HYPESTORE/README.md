# HYPESHELL-HYPESTORE

Catalog folder for installable HypeShell packages.

HypeStore records can point to package folders in this monorepo or to external package repositories.

Catalog arrays and package types:

- `hypeModules`: `HYPEMODULE` records for shell modules that extend HypeShell UI or behavior.
- `hypeGadgets`: `HYPEGADGET` records for desktop gadgets rendered by HypeShell.
- `hypeThemes`: `HYPETHEME` records for theme packs, wallpapers, and style assets.

## External Developer Flow

1. Create a public package repository.
2. Add a `manifest.json` at the repo root or package subfolder.
3. Open a PR against this repo that adds a record to `index.json`.
4. HypeShell users can install it after the catalog PR is merged.

## Catalog Record

```json
{
  "id": "developer-package-id",
  "packageType": "HYPEMODULE",
  "name": "Developer Package",
  "version": "0.1.0",
  "author": "Developer Name",
  "description": "What this package adds to HypeShell.",
  "repo": "https://github.com/developer/developer-package.git",
  "branch": "main",
  "path": ".",
  "verified": false
}
```

`path` can point at a package subfolder when one repository contains multiple packages.
