# Changelog

Short public notes on recent MumbleCluster development. This changelog keeps the architectural achievements, but avoids internal procedures, raw paths, private routes, and operational tooling details.

## Recent developments

### Heterogeneous runtime fabric

MumbleCluster does become the final heterogeneous runtime fabric we envisioned: mixed machines, mixed service roles, and mixed network positions working as one coherent project surface.

We narrowed the public story around that goal. The project is presented as a living cluster fabric, not a collection of separate experiments.

### Quorum-backed cluster direction

The control-plane direction moved from single-controller thinking toward a quorum-backed model.

For the public story, the important point is resilience: MumbleCluster is meant to keep growing beyond a single sacred machine and toward a distributed runtime that can absorb different participants safely.

### Public edge and ingress routing

The public edge model has been cleaned up around HEX22 NGINX, Traefik, and NodePort service exposure.

The public explanation stays simple: selected service lanes can be placed behind a high-speed edge while private runtime operations remain separated from visitors.

### MC-Edge fiber lane

The public surfaces are served through a high-speed NGINX edge on HEX22, connected into the MC-Edge fiber lane.

This gives the project a fast public entry point while still keeping the deeper runtime fabric behind controlled service boundaries.

### Pure VM-worker lane

We now have a clear pure VM-worker role in QEMU-MCW.

It acts as a focused worker lane for service experimentation and project packaging without turning the public repository into an operations manual.

### Database-driven live pages

We moved the public page model toward reviewed database-backed content.

MC-MariaDB can hold approved public summaries, project cards, and release notes. MC-Dash is the public presentation layer for those approved entries. MC-Dash carries the richer live story as the project evolves, while GitHub stays for the broader community.

### MC-Dash and GitHub split

GitHub remains the clean community package: overview, changelog, license, and public concept notes.

MC-Dash carries the richer live story: approved summaries, proof notes, selected service descriptions, and dashboard-style project presentation.

### Service-pod direction

We have begun shaping public language around service-pod surfaces such as the CODER service-pod and the LibreOffice service-pod.

These are examples of service-lane thinking: user-facing workspaces and tools that can live inside the cluster fabric without exposing internal operations.

### Monitoring surface direction

Prometheus and Grafana remain part of the visibility direction around the project.

Public wording describes them as monitoring and dashboard concepts, not as a map of internal runtime details.

### Public-safe snapshots

The project keeps a public-safe snapshot direction for architectural proof and continuity.

These snapshots should explain what was proven without carrying secrets, private topology, raw manifests, or operationally sensitive material.

### First public proof page

The first basic proof-of-concept surface is:

- https://proof-random.mumblehighlife.de/

It shows the project crossing from architecture planning into a reachable public surface: a MC-Service-Pod as the serving Endpoint.

## Current public focus

- explain the cluster-fabric idea clearly
- keep GitHub readable and non-operational
- use MC-Dash for approved live public pages
- show selected service-pod concepts without exposing internals
- describe Prometheus and Grafana as observability surfaces only
- keep private routing, raw paths, manifests, and operations detail out of the public repository
