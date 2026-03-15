[![PoC](https://img.shields.io/badge/PoC-live-green)](https://proof.mumblehighlife.de/)
![Status](https://img.shields.io/badge/status-experimental-orange)
![Architecture](https://img.shields.io/badge/arch-ARM%20%7C%20AMD64-blue)
![Networking](https://img.shields.io/badge/network-Cilium%20eBPF-green)
![Mesh](https://img.shields.io/badge/mesh-WireGuard-purple)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

# MumbleCluster

MumbleCluster explores how heterogeneous machines across LAN and WAN can be assimilated into a unified Kubernetes runtime.

The cluster currently spans:

• BENQ — control plane
• HEX22 — WAN worker / ingress node
• BELL — LAN worker

Networking is provided through WireGuard and Cilium eBPF,
allowing workloads to route transparently across nodes and networks.

The platform integrates:

- Kubernetes (RKE2)
- Cilium eBPF networking
- WireGuard overlay networking
- Mixed CPU architectures (ARM / AMD64)
- Cross-network orchestration across LAN and WAN nodes

The project explores how independent machines can be assimilated into a coherent distributed runtime capable of orchestrating compute workloads across networks, architectures, and hardware generations.

---

## Repository Structure

docs/
: Architecture documentation and Proof-of-Concept records.

cluster_snapshots/
: Historical captures of cluster state used for debugging, reproducibility, and infrastructure archaeology.

scripts/
: Operational tooling for cluster maintenance and automation.

syncstream/
: Protocol-driven coordination layer for operations scheduling, telemetry, and orchestration metadata.

---

## Cluster Status

Active branch: `main`

**Controller node**
- BENQ

**Worker nodes**
- HEX22 — WAN worker
- BELL — LAN worker

Ingress entrypoint currently anchored on **HEX22**.

---

## Project Direction

MumbleCluster aims to evolve into a modular distributed runtime capable of assimilating heterogeneous compute nodes into a unified orchestration system.

The platform serves as a foundation for experimental infrastructure research involving distributed compute, networking, and automation.

---

## Collaboration

Questions, ideas, or collaboration proposals are welcome.

Please open a **GitHub Issue** or **Discussion** in this repository.

Project maintainer: **@benjoire**

---

## Live demonstration

A running Proof-of-Concept instance of the cluster is publicly accessible.

PoC endpoint:

https://proof.mumblehighlife.de/

This page is served through the MumbleCluster ingress layer and demonstrates
cross-node routing through the cluster infrastructure.
