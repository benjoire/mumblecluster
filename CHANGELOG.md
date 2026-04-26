# 🧬 Changelog

## 2026-04-26

### Added
- `tools/storage-host-claim/` helper layout with:
  - `storage-host-claim.sh`
  - `storage-host-claim.env.example`
  - WG-safe example manifests
- `docs/storage-hotplug-doctrine.md`

### Proven
- manual storage-host handover across controller nodes
- WG-safe validation lane recovery on `hetzner-cx22`
- restored MC-PVC-backed workload landing for `webtop-a2g-debian` on `hetzner-cx22`
- real file digestion through `/data/certshot_latest.csv` inside the running workload

### Learned
- validation PVC/PV objects must be refreshed after storage-host identity switches because existing PVs can retain the previous NFS server identity

### Notes
- WG-safe deploy example is a seed manifest only; active NFS server identity is runtime-patched by the storage-host claim workflow
- combined claim-and-refresh flow still needs hardening around provisioner and PVC/PV lifecycle timing

## [2026-04-19] — Quorum Expansion, Traefik-Only Ingress, GHSAFE LKG

### 🧠 Control Plane
- Expanded MumbleCluster control plane from **1 → 3 controllers**
- Active quorum now:
  - **BENQ** — control-plane, etcd, transit hub
  - **MinisONE** — control-plane, etcd
  - **MinisTWO** — control-plane, etcd
- Verified healthy 3-node control-plane footprint:
  - `etcd`
  - `kube-apiserver`
  - `kube-controller-manager`
  - `kube-scheduler`

### 🌐 Ingress / Edge
- Retired the old packaged **rke2-ingress-nginx** lane
- Normalized Kubernetes ingress to **Traefik-only**
- Confirmed only Traefik ingresses remain cluster-wide
- Preserved **HEX22 NGINX** as the public upstream edge in front of the cluster ingress path

### 🔧 Incident + Resolution
- Identified packaged `rke2-ingress-nginx` reconciliation as the cause of edge disruption on HEX22
- Observed unexpected fallback to the Kubernetes fake ingress certificate on local 80/443 testing
- Disabled packaged ingress-nginx and restored intended edge behavior:
  - proper domain certificates on HEX22
  - Traefik-backed proof lane recovery
  - correct vhost behavior for public-facing domains

### 🖥️ Service Lanes
- Confirmed active **Selkies / webtop Debian lane** through Traefik:
  - `a2g-debian.mumblehighlife.de`
  - Restored front-gate protection for the live Debian/Selkies lane through **Traefik BasicAuth**
  - Verified public access now returns `401 Unauthorized` until credentials are supplied
- Removed obsolete nginx-bound ingress objects:
  - `webtop-a2g`
  - `webtop-https`
  - `whoami-ingress`
- Preserved trajectory toward:
  - **Traefik ingress**
  - **HEX22 edge mediation**
  - service lanes for PoC, desktop, and tooling workloads

### 🤖 Tooling / Execution
- Confirmed architecture direction includes:
  - **Coder / code-server lane**
  - **MC-Inspector**
  - **HOTPIPE**
  - broker/dispatcher-mediated execution paths
  - QEMU-backed execution integration with MumbleCluster

### 📦 Public Snapshot / GitHub
- Created new **GHSAFE** public-safe snapshot lane
- Repointed `LKG-LATEST` to:
  - `GHSAFE-2026-04-19_18-00-13`
- Updated `LKG_STATUS.json` to the public-safe baseline
- Added sanitized node bundles for:
  - BENQ
  - MinisONE
  - MinisTWO
  - BELL
  - HEX22
- Normalized permissions/ownership for GitHub publication flow

### 📝 Documentation
- Refreshed README direction to reflect:
  - Quorum expansion
  - Traefik-only ingress
  - HEX22 NGINX edge
  - Selkies / Coder / HOTPIPE service lanes
- Removed explicit README links for:
  - `a2g-debian.mumblehighlife.de`
  - `https://proof.mumblehighlife.de/`
    
  because they are not the default public entry / not yet protected to the desired auth standard

## [2026-03-28] — Datapath Reframing, Dual-Lane Networking Model & Docs Update

### 🌐 Networking Findings
- Reframed the previously assumed **“VXLAN reverse-path syndrome”**
- Established a more accurate interpretation of the current behavior as:
  - **L7-over-overlay path ambiguity**
  - **Envoy/tunnel observability distortion under stacked encapsulation**
- Clarified that the validated PoC already proves:
  - cross-metal traffic
  - cross-network traffic
  - cross-architecture traffic
  - Kubernetes service abstraction across heterogeneous nodes
  - Cilium eBPF L3/L4 datapath operation over VXLAN with WireGuard-backed node interconnect

### 🛣️ Dual-Lane Model
- Formalized a two-lane networking interpretation for MumbleCluster:

**1. Secured fallback lane**
- Cilium ConfigMap profile:
  - `routing-mode: tunnel`
  - `auto-direct-node-routes: "false"`
- Purpose:
  - preserve known-good L3/L4 behavior
  - maintain reproducible fallback transport
  - anchor the currently validated PoC baseline

**2. L7 toggle lane**
- Cilium ConfigMap profile:
  - `routing-mode: native`
  - `auto-direct-node-routes: "true"`
- Purpose:
  - reduce overlay ambiguity
  - improve path clarity
  - support future deterministic ingress → service → pod behavior
- Status:
  - experimental / construction lane

### 📘 Documentation
- Prepared a README refresh to reflect the corrected datapath interpretation
- Added wording that distinguishes:
  - **proven L3/L4 baseline**
  - **unfinished deterministic L7 behavior**
- Public repository update intentionally held back until L7 behavior is finalized strongly enough to present as deterministic rather than provisional

### 🧠 Operational Interpretation
- Current conclusion:
  - L3/L4 delivery is proven
  - L7 remains the active engineering frontier
- The remaining objective is no longer to prove basic delivery again, but to finalize deterministic L7 semantics under ingress and observability pressure

---

## [2026-03-22] — Security Hardening & LKG Sanitization

### 🔒 Security
- Removed sensitive data from repository history:
  - `/etc/rancher` (RKE2 control-plane config)
  - `system/rke2_config`
  - `tunnel/` (WireGuard state)
  - VPN-related credentials (OpenVPN, login files)
- Rewrote Git history using `git-filter-repo`
- Force-pushed clean history to origin

### 🧬 LKG (Last Known Good)
- Redefined LKG boundary:
  - includes: cluster state, observability, topology
  - excludes: credentials, secrets, control-plane configs
- Introduced sanitized LKG structure

### ⚙️ MC Protocol
- MC v2 pipeline operational:
  - `mc` orchestrator
  - `mc_health`
  - `mc_snapshot`
  - `syncstream`

### 🛡️ Hardening
- Added `.gitignore` rules for sensitive paths
- Manual credential audit + cleanup
- Repository temporarily set to private during remediation

### 📌 Notes
- No evidence of active compromise
- Exposure window limited and contained quickly
- Preventive measures in place for future snapshots

### Known Quirk
- CoreDNS readiness on BenQ degraded due to mixed DNS sources
- Cluster DNS functionality unaffected

---
