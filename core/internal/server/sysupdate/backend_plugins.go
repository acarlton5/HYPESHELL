package sysupdate

import (
	"context"
	"fmt"

	"github.com/acarlton5/HypeShell/core/internal/plugins"
)

func init() {
	RegisterOverlayBackend(func() Backend { return &pluginsBackend{} })
}

type pluginsBackend struct{}

func (pluginsBackend) ID() string           { return "plugins" }
func (pluginsBackend) DisplayName() string  { return "HypeShell Plugins" }
func (pluginsBackend) Repo() RepoKind       { return RepoPlugin }
func (pluginsBackend) NeedsAuth() bool      { return false }
func (pluginsBackend) RunsInTerminal() bool { return false }
func (pluginsBackend) IsAvailable(_ context.Context) bool {
	manager, err := plugins.NewManager()
	if err != nil {
		return false
	}
	installed, err := manager.ListInstalled()
	return err == nil && len(installed) > 0
}

func (pluginsBackend) CheckUpdates(ctx context.Context) ([]Package, error) {
	manager, err := plugins.NewManager()
	if err != nil {
		return nil, err
	}
	registry, err := plugins.NewRegistry()
	if err != nil {
		return nil, err
	}
	available, registryErr := registry.List()
	if registryErr != nil {
		available = nil
	}
	installed, err := manager.ListInstalled()
	if err != nil {
		return nil, err
	}

	byID := make(map[string]plugins.Plugin, len(available))
	for _, plugin := range available {
		byID[plugin.ID] = plugin
	}

	updates := make([]Package, 0)
	for _, id := range installed {
		if err := ctx.Err(); err != nil {
			return nil, err
		}
		plugin, known := byID[id]
		if !known {
			plugin = plugins.Plugin{ID: id, Name: id}
		}
		currentRevision, targetRevision, checkErr := manager.UpdateRevisions(id, plugin)
		if checkErr != nil && !known {
			continue
		}
		if currentRevision == targetRevision && checkErr == nil {
			continue
		}
		fromVersion := shortPluginRevision(currentRevision, "missing")
		toVersion := shortPluginRevision(targetRevision, "latest")
		name := plugin.Name
		if name == "" {
			name = id
		}
		updates = append(updates, Package{
			Name:        name,
			Repo:        RepoPlugin,
			Backend:     "plugins",
			FromVersion: fromVersion,
			ToVersion:   toVersion,
			Ref:         id,
		})
	}
	return updates, nil
}
func shortPluginRevision(revision string, fallback string) string {
	if revision == "" {
		return fallback
	}
	if len(revision) > 12 {
		return revision[:12]
	}
	return revision
}

func (pluginsBackend) Upgrade(ctx context.Context, opts UpgradeOptions, onLine func(string)) error {
	manager, err := plugins.NewManager()
	if err != nil {
		return err
	}
	registry, err := plugins.NewRegistry()
	if err != nil {
		return err
	}
	available, registryErr := registry.List()
	if registryErr != nil {
		available = nil
	}
	byID := make(map[string]plugins.Plugin, len(available))
	for _, plugin := range available {
		byID[plugin.ID] = plugin
	}

	for _, target := range opts.Targets {
		if target.Backend != "plugins" && target.Repo != RepoPlugin {
			continue
		}
		if err := ctx.Err(); err != nil {
			return err
		}
		id := target.Ref
		if id == "" {
			id = target.Name
		}
		if id == "" {
			continue
		}
		if opts.DryRun {
			if onLine != nil {
				onLine(fmt.Sprintf("Would update plugin: %s", id))
			}
			continue
		}
		if onLine != nil {
			onLine(fmt.Sprintf("Updating plugin: %s", id))
		}
		if plugin, ok := byID[id]; ok {
			if err := manager.Update(plugin); err != nil {
				return fmt.Errorf("update plugin %s: %w", id, err)
			}
			continue
		}
		if err := manager.UpdateByIDOrName(id); err != nil {
			return fmt.Errorf("update plugin %s: %w", id, err)
		}
	}
	return nil
}
