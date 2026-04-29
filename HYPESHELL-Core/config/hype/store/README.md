# HypeStore Sources

HypeShell reads `sources.json` to discover module and gadget registries.

The default source points at:

```text
https://raw.githubusercontent.com/acarlton5/HYPESHELL/main/HYPESHELL-HYPESTORE/index.json
```

Each source URL should return a JSON object with `hypeModules`, `hypeGadgets`, and `hypeThemes` arrays.
Entries can install a whole repository or a subfolder from a repository.
