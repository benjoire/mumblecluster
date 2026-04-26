[![PoC](https://img.shields.io/badge/PoC-live-green)](https://proof-random.mumblehighlife.de/)
![Status](https://img.shields.io/badge/status-active%20prototype-brightgreen)
![Quorum](https://img.shields.io/badge/control--plane-3--node-blue)
![Ingress](https://img.shields.io/badge/ingress-Traefik-blueviolet)
![Networking](https://img.shields.io/badge/network-Cilium%20eBPF-green)
![Mesh](https://img.shields.io/badge/mesh-WireGuard-purple)
![Architecture](https://img.shields.io/badge/arch-ARM%20%7C%20AMD64-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

# MumbleCluster

MumbleCluster is a heterogeneous Kubernetes runtime that links LAN and WAN machines into one operational cluster across mixed hardware, mixed networks, and mixed CPU architectures.

The current platform combines:

- **RKE2 / Kubernetes**
- **Cilium eBPF**
- **WireGuard underlay**
- **Traefik ingress**
- **HEX22 NGINX public edge**
- **Mixed AMD64 and ARM infrastructure**

The project is not just about “running Kubernetes on multiple boxes.”  
It is about building a modular distributed runtime that can absorb different machines, networks, and service roles into one coherent operational fabric.

---

## Current Cluster Topology

### Control plane
- **BENQ** — control-plane, etcd, transit hub
- **MinisONE** — control-plane, etcd
- **MinisTWO** — control-plane, etcd

### Workers
- **HEX22** — WAN worker, Traefik node, public edge companion
- **BELL** — LAN worker

This means the cluster now runs with a **3-node control-plane quorum** instead of a single-controller baseline.

---

## What changed recently

### Quorum expansion
The control plane was expanded from **1 → 3 controllers**, turning the cluster from a single sacred controller model into a real quorum-backed control plane.

That materially improves:

- controller survivability
- etcd durability
- maintenance flexibility
- cluster-state continuity during single-node loss or restart

### Ingress transition
The Kubernetes ingress layer was normalized to **Traefik-only**.

That means:

- **Traefik** is now the active cluster ingress controller
- old packaged **ingress-nginx** was retired
- **HEX22 NGINX** remains the public upstream edge in front of the cluster lane

This gives the project a cleaner edge model:

**Internet → HEX22 NGINX → Traefik → Service → Pod**

---

## Live lanes and service direction

### 1. Proof lanes
Public proof pages currently validate the live edge-to-cluster path:

- **https://proof-random.mumblehighlife.de/**

These prove that traffic can cross:

- public edge
- ingress
- service routing
- pod delivery
- mixed-node execution paths

### 2. Selkies / Webtop lane
The cluster currently carries a browser-based desktop lane through Selkies-style webtop services.

The current preferred path is the **Debian / Traefik lane**.

This lane is now front-gated through **Traefik BasicAuth** and is intentionally not disclosed in detail in the public README.

It is the active replacement direction for the older nginx-bound desktop exposure.

### 3. Coder lane
The cluster also carries a code-server / Coder-style development lane as part of its service fabric and operator workflow.

This matters because MumbleCluster is not only a networking experiment; it is becoming an actual platform for developer-facing workloads.

### 4. HOTPIPE / MC-Inspector lane
A separate but connected service lane links ChatGPT-side tooling to cluster-adjacent execution paths through:

- **MC-Inspector**
- **HOTPIPE**
- **broker / dispatcher logic**
- **QEMU-backed execution**

This lane is important because it demonstrates controlled remote execution and tool mediation beyond ordinary web service hosting.

In practical terms, the project is already moving toward a model where MumbleCluster can host not only websites and PoCs, but also mediated execution paths, inspection lanes, and operator tooling.

---

## Networking doctrine

MumbleCluster uses a **WireGuard + Cilium** model with a clean operational distinction:

### WireGuard
WireGuard acts as the **underlay identity and transport fabric**.

The cluster currently follows a **/32 identity model** with BENQ acting as the practical transit hub for routed peer reachability.

### Cilium
Cilium provides the Kubernetes dataplane and service fabric.

The important result is:

- **L3/L4 delivery is proven**
- **cross-metal / cross-network / cross-arch delivery is proven**
- L7 pathing is no longer vague theory; it is now being shaped through the Traefik + edge model

---

## Repository structure

`docs/`  
Architecture notes, operational doctrine, and PoC writeups.

`cluster_snapshots/`  
Public-safe and internal cluster state captures.

`tools/`  
Operational tooling, wrappers, sweep scripts, sealing logic, and sync helpers.

`state/`  
Generated health and state artifacts.

`core/`  
Project logic and evolving runtime material.

---

The current public-safe baseline is represented through the **GHSAFE** snapshot lane and the `LKG-LATEST` pointer.

---

## Current operational picture

MumbleCluster now stands on four real foundations:

1. **3-node control-plane quorum**
2. **Traefik-only Kubernetes ingress**
3. **HEX22 NGINX edge mediation**
4. **service lanes beyond static PoCs**, including:
   - proof pages
   - Selkies desktop
   - Coder / code-server
   - HOTPIPE / MC-Inspector / QEMU execution path

That combination is what turns the project from a cluster experiment into an early distributed runtime platform.

---

## Project direction

The near-term direction is clear:

- stabilize the Traefik-only ingress lane
- audit and normalize cluster services
- freeze blueprint-grade configuration and documentation
- publish GitHub-safe state and architecture artifacts
- continue evolving MumbleCluster as a modular distributed runtime

The long-term direction remains broader:
to assimilate heterogeneous compute, network edge, service logic, and execution tooling into one unified orchestration environment.

---

## Collaboration

Questions, ideas, and collaboration proposals are welcome.

Please open a **GitHub Issue** or **Discussion** in this repository.

Project maintainer: **@benjoire**

## Storage-backed workload landing and hot-plug doctrine

MumbleCluster now includes a validated storage-backed application lane for remote worker execution over the WG-safe MC-PVC path.

### What was proven

- manual storage-host handover across Quorum-3 controller nodes
- WG-safe validation lane for remote worker storage consumption
- repeated canary validation on `hetzner-cx22`
- real workload validation with `webtop-a2g-debian` on `hetzner-cx22`

This moved the storage story from PVC smoke tests to a real application proof.

### Operational rule

After a storage-host identity switch, the validation PVC/PV lane must be refreshed before trusting the WG-safe canary again.

Reason:
existing PV objects can retain the previous NFS server identity even after the active storage host and provisioner target have changed.

### Real workload proof

The `webtop-a2g-debian` workload in namespace `app-desk` was restored to `Running` on `hetzner-cx22`, with live service endpoints re-established and both storage-backed mounts active from the current NFS host. A real `CERTSHOT` CSV was then accessed inside the workload from `/data/certshot_latest.csv`, proving end-to-end remote workload consumption on the MC-PVC storage lane.

### Tooling

A repo-ready helper was added under:

- `tools/storage-host-claim/`

Current model:

- local validation on the node physically holding the storage device:
  - `--check`
  - `--facts`
- remote cluster mutation from a kubectl-capable controller:
  - `--claim-remote`

Included examples:

- WG-safe provisioner seed manifest
- WG-safe StorageClass
- canary PVC and pod manifests
- sanitized example env profile

### Current limitation

The combined refresh automation still needs hardening around:

- provisioner bring-up ordering
- stale PV cleanup timing
- manifest-path validation on all controller nodes

Until then, treat the helper as repo-worthy and operationally useful, but not yet fully final in its one-shot mode.
