# Observability Access Policy

Default access mode:

- No public exposure.
- Admin access via `kubectl port-forward` from a trusted workstation.

Preferred future access mode:

Internet
→ HEX22 NGINX edge
→ gated authentication
→ Traefik ingress
→ `mc-grafana-wg`
→ `mc-prometheus-wg`

Rules:

- Do not expose Grafana directly to the public internet.
- Do not expose Prometheus publicly.
- HEX22-gated authentication is required before external access.
- Runtime Helm dumps, raw manifests, generated secrets, and live values remain private.
