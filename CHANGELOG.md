# 🧬 Changelog

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
