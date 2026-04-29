pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire


Singleton {
    PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSource,
            Pipewire.defaultAudioSink,
            Pipewire.nodes,
            Pipewire.links
        ]
    }

    property var sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)
    property var defaultSink: Pipewire.defaultAudioSink ?? (sinks.length > 0 ? sinks[0] : null)

    property var sources: Pipewire.nodes.values.filter(node => !node.isSink && !node.isStream && node.audio)
    property var defaultSource: Pipewire.defaultAudioSource ?? (sources.length > 0 ? sources[0] : null)

    property real volume: clamp01(defaultSink?.audio?.volume, 0)
    property bool muted: Boolean(defaultSink?.audio?.muted ?? false)

    function clamp01(value: real, fallback: real): real {
        const n = Number(value)
        const f = Number(fallback)
        if (isNaN(n))
            return isNaN(f) ? 0 : Math.max(0, Math.min(1, f))
        return Math.max(0, Math.min(1, n))
    }

    function isMuted(node): bool {
        return Boolean(node?.audio?.muted ?? false)
    }

    function nodeVolume(node): real {
        return clamp01(node?.audio?.volume, 0)
    }

    function setVolume(to: real): void {
        if (defaultSink?.ready && defaultSink?.audio) {
            defaultSink.audio.muted = false;
            defaultSink.audio.volume = clamp01(to, 0);
        }
    }

    function setSourceVolume(to: real): void {
        if (defaultSource?.ready && defaultSource?.audio) {
            defaultSource.audio.muted = false;
            defaultSource.audio.volume = clamp01(to, 0);
        }
    }

    function toggleMuted(node): void {
        if (node?.ready && node?.audio)
            node.audio.muted = !Boolean(node.audio.muted)
    }

    function setDefaultSink(sink: PwNode): void {
        Pipewire.preferredDefaultAudioSink = sink;
    }

    function setDefaultSource(source: PwNode): void {
        Pipewire.preferredDefaultAudioSource = source;
    }

    function init() {
    }
}
