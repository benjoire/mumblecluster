# 🧬 Changelog

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

---
