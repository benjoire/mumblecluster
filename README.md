[![PoC](https://img.shields.io/badge/PoC-live-green)](https://proof.mumblehighlife.de/)
![Status](https://img.shields.io/badge/status-experimental-orange)
![Architecture](https://img.shields.io/badge/arch-ARM%20%7C%20AMD64-blue)
![Networking](https://img.shields.io/badge/network-Cilium%20eBPF-green)
![Mesh](https://img.shields.io/badge/mesh-WireGuard-purple)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

# MumbleCluster

MumbleCluster explores how heterogeneous machines across LAN and WAN can be assimilated into a unified Kubernetes runtime.

The cluster currently spans:

- BENQ — control plane
- HEX22 — WAN worker / ingress node
- BELL — LAN worker

Networking is provided through WireGuard and Cilium eBPF, allowing workloads to route transparently across nodes and networks.

The platform integrates:

- Kubernetes (RKE2)
- Cilium eBPF networking
- WireGuard overlay networking
- Mixed CPU architectures (ARM / AMD64)
- Cross-network orchestration across LAN and WAN nodes

The project explores how independent machines can be assimilated into a coherent distributed runtime capable of orchestrating compute workloads across networks, architectures, and hardware generations.

---

## Repository Structure

`docs/`  
Architecture documentation and Proof-of-Concept records.

`cluster_snapshots/`  
Historical captures of cluster state used for debugging, reproducibility, and infrastructure archaeology.

`scripts/`  
Operational tooling for cluster maintenance and automation.

`syncstream/`  
Protocol-driven coordination layer for operations scheduling, telemetry, and orchestration metadata.

---

## Cluster Status

Active branch: `main`

**Controller node**
- BENQ

**Worker nodes**
- HEX22 — WAN worker
- BELL — LAN worker

Ingress entrypoint is currently anchored on **HEX22**.

---

## Live Demonstration

A running Proof-of-Concept instance of the cluster is publicly accessible:

**[https://proof.mumblehighlife.de/](https://proof-random.mumblehighlife.de/)**

This page is served through the MumbleCluster ingress layer and demonstrates live traffic flowing through the cluster infrastructure.

---

## Networking Findings

One of the most important outcomes of the current PoC phase was a correction in how the datapath was being interpreted.

### What the PoC has already proven

The current stable lane demonstrates:

- cross-metal traffic
- cross-network traffic
- cross-architecture traffic
- Kubernetes service abstraction across heterogeneous nodes
- Cilium eBPF datapath operation across tunneled infrastructure

In practical terms, the cluster currently proves **L3/L4 delivery over Cilium eBPF VXLAN traffic**, while the broader node-to-node mesh is carried across networks through **WireGuard encapsulation**.

This means the project has already established a working and reproducible baseline for:

**cross-metal | cross-network | cross-arch**

### Misdiagnosis corrected

Earlier debugging language described the issue as:

> VXLAN reverse-path syndrome

That wording is no longer considered accurate.

A better interpretation is:

- **L7-over-overlay path ambiguity**
- **Envoy/tunnel observability distortion under stacked encapsulation**

The important distinction is that the base **L3/L4 datapath was not fundamentally broken**.  
What became difficult to reason about was the moment **L7 proxying, Envoy behavior, overlay routing, and stacked encapsulation** all entered the same traffic path.

So the current conclusion is:

- **L3/L4 baseline:** proven
- **L7 behavior:** still under active construction

---

## Dual-Lane Networking Model

At the current stage, MumbleCluster is best understood as operating with two separate networking lanes.

### 1. Secured fallback lane

This is the current known-good baseline and the operational safety lane.

**Cilium ConfigMap profile**
```yaml
routing-mode: tunnel
auto-direct-node-routes: "false"
```

This lane prioritizes:

- stable L3/L4 behavior
- tunneled overlay transport
- reproducible cross-node routing
- reliable fallback for proof preservation and cluster continuity

This is the lane that currently backs the validated PoC baseline.

### 2. L7 toggle lane

This is the active development and construction lane for ingress-path refinement.

**Cilium ConfigMap profile**
```yaml
routing-mode: native
auto-direct-node-routes: "true"
```

This lane is intended to:

- reduce overlay ambiguity
- simplify path reasoning
- support deterministic ingress → service → pod behavior
- improve the signal quality of L7 observability

This path remains **experimental** until deterministic L7 behavior is fully established.

---

## Current Position

The project now explicitly distinguishes between:

- a **known-good L3/L4 fallback lane**
- an **L7 development lane under active construction**

That distinction is intentional.

MumbleCluster has already proven that it can move traffic correctly across heterogeneous infrastructure using Cilium eBPF, VXLAN, WireGuard, and mixed CPU architectures.

The remaining task is not to prove basic delivery again, but to finalize **deterministic L7 behavior**, with clean ingress, service routing, and observability semantics.

Until that work is complete, the repository will treat L3/L4 stability and L7 experimentation as two distinct operational states.

---

## Project Direction

MumbleCluster aims to evolve into a modular distributed runtime capable of assimilating heterogeneous compute nodes into a unified orchestration system.

The platform serves as a foundation for experimental infrastructure research involving distributed compute, networking, and automation.

The current emphasis is on turning the already-proven multi-node L3/L4 datapath into a fully deterministic L7-capable service fabric.

---

## Collaboration

Questions, ideas, or collaboration proposals are welcome.

Please open a **GitHub Issue** or **Discussion** in this repository.

Project maintainer: **@benjoire**

---

## 🔒 Security & Snapshot Policy

MumbleCluster uses a structured LKG (Last Known Good) snapshot system for observability and reproducibility.

**Important:**
- Snapshots intentionally exclude:
  - credentials (VPN, WireGuard, tokens)
  - control-plane secrets
  - node authentication material
- Only cluster topology, state, and observability data are included.

All snapshots are:
- deterministic
- hashed (sha256)
- cryptographically signed (GPG)

If you believe sensitive data is exposed, please report it immediately.
