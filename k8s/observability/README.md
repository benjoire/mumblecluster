# MumbleCluster Observability

This lane provides Prometheus and Grafana for MumbleCluster health visibility.

## Current layout

Regular lane:

- Namespace: `mc-observability`
- Prometheus release: `mc-prometheus-wg`
- Grafana release: `mc-grafana-wg`
- StorageClass: `mc-pvcstore-wg`

Sandbox lane:

- Namespace: `mc-observability-sandbox`
- Prometheus release: `mc-prometheus`
- Grafana release: `mc-grafana`
- StorageClass: `local-path`

## Doctrine

- No blind in-place Helm upgrades.
- Observability work is sandboxed first.
- Stable lane stays boring.
- Sandbox lane absorbs upgrade curiosity.
- Dump current values before touching releases.
- Prepare rollback path before install or upgrade.
- Prefer parallel sandbox releases over production mutation.

## Notes

The regular Prometheus release disables its own node-exporter to avoid duplicate HostPort `9100` conflicts with the sandbox exporter fleet.
