# HypeStore Contract

`HYPESHELL-HYPESTORE` is a catalog. It does not need to contain package code.

Each catalog record points to a package repository. That repository can be maintained by HypeShell or by an external developer.

## Catalog Shape

`index.json` uses HypeShell package arrays only:

- `hypeModules`
- `hypeGadgets`
- `hypeThemes`

## Record Shape

```json
{
  "id": "package-id",
  "packageType": "HYPEMODULE",
  "name": "Package Name",
  "version": "0.1.0",
  "author": "Developer Name",
  "description": "What this package adds.",
  "repo": "https://github.com/developer/package.git",
  "branch": "main",
  "path": ".",
  "verified": false
}
```

`path` may point at a subfolder when a repo contains multiple packages.

## Package Manifest

Each installable package must include a `manifest.json`.

HypeShell uses the manifest to render settings controls in the Modules and Gadgets panels.
