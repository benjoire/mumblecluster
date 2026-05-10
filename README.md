[![MC-Dash](https://img.shields.io/badge/MC--Dash-live-00c853)](https://desk.mumblehighlife.de/github/)
[![PoC](https://img.shields.io/badge/PoC-live-green)](https://proof-random.mumblehighlife.de/)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

# MumbleCluster

MumbleCluster is becoming the heterogeneous runtime fabric we set out to build: a joined project surface for mixed machines, mixed service roles, and mixed public/private responsibilities.

This public repository keeps the story readable and safe. It explains the direction without publishing operational code, private routes, raw topology, cluster manifests, credentials, or runtime procedures.

## What we are building

MumbleCluster is shaped as a living cluster fabric rather than a fixed box-by-box deployment.

At a high level, the project brings together:

- heterogeneous compute across different hardware profiles
- a quorum-backed control-plane direction
- pure VM-worker participation
- service-pod surfaces such as CODER and LibreOffice
- public service exposure through a high-speed NGINX edge on HEX22
- MC-Edge connectivity over the fiber lane
- ingress routing through Traefik and NodePort service exposure
- database-reviewed live pages through MC-MariaDB and MC-Dash
- visibility concepts around Prometheus and Grafana
- public proof surfaces and private runtime boundaries

HEX22 is the cloud machine serving as the public edge companion: a high-speed NGINX entry point in front of selected cluster-facing service lanes.

The architecture aims to stress connectivity to its edges and unify everything which can be absorbed into the unified runtime regime.

## Public surfaces

GitHub is the broader community package: overview, changelog, license, and public concept notes.

MC-Dash is the live public presentation layer for approved project summaries, proof notes, and collaboration updates:

- https://desk.mumblehighlife.de/github/

MC-Dash carries the richer live story as the project evolves, while GitHub stays clean and readable for the broader community.

The first basic proof page is:

- https://proof-random.mumblehighlife.de/

It demonstrates a simple public surface reachable from the internet, delivered through the project fabric: a MC-Service-Pod as the serving Endpoint.

## Service-lane examples

CODER and LibreOffice service-pods represent the user-facing side of the service-lane idea. They are examples of workspace-style and document-style surfaces that can live inside the cluster fabric while being presented through controlled entry points.

Prometheus and Grafana belong to the visibility side of the story. Public wording treats them as monitoring and dashboard concepts, not as a map of internal runtime details.

## Design principles

### Concepts over code bricks

Public material should describe intent, architecture, boundaries, and collaboration direction. Code, manifests, scripts, raw topology, private automation, and environment-specific procedures stay outside the public repository.

### Public explains. Runtime operates.

The repository should help visitors understand the project without exposing implementation handles that make the live environment easier to fingerprint or operate against.

### Database-reviewed publication

Reviewed project summaries can move into MC-MariaDB and then appear through MC-Dash. This keeps public pages current while preserving a clear approval boundary.

## Current public topics

- heterogeneous runtime fabric
- quorum-backed cluster direction
- Traefik and NodePort routing concepts
- HEX22 NGINX edge mediation
- MC-Edge fiber connectivity
- pure VM-worker participation
- CODER and LibreOffice service-pod surfaces
- Prometheus and Grafana visibility direction
- database-driven live pages
- live MC-Dash public surface
- MC-Dash and GitHub publication split
- proof and demonstration pages

## Repository shape

This public sweep is intentionally small:

- `README.md` — project overview and public direction
- `CHANGELOG.md` — recent public developments
- `LICENSE` — license
- `docs/` — public concept notes

Everything else is reviewed before publication and normally belongs either in MC-Dash, MC-MariaDB, private operator notes, internal staging, or archived safety material.

## Collaboration

Ideas, questions, and high-level collaboration proposals are welcome.

This card is meant for people who want to understand the whole idea in distributed systems, and seek to collaborate at the architecture level. The conversation uses generic language without exposing any code. No need to hack through pods in order to get recognized. Join the creativity involved when elaborating new development pathways.

Maintainer: @benjoire
