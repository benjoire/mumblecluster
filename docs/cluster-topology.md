# Cluster Topology — Public Concept

MumbleCluster is best understood as a fabric of roles, not a pile of machines.

The public topology story stays generic. It explains the shape of the system without publishing raw network maps, private routes, or implementation-specific manifests.

## Role model

We separate responsibilities into broad roles:

- control-plane responsibility
- pure VM-worker capacity on QEMU-MCW
- public edge mediation through the high-speed HEX22 NGINX edge
- ingress routing through Traefik and NodePort service exposure
- service-runtime execution
- CODER and LibreOffice service-pod surfaces
- dashboard and observability surfaces
- Prometheus and Grafana visibility concepts
- database-backed publication through MC-MariaDB and MC-Dash

This role model lets the project absorb different machines and networks without pretending they are identical.

## Fabric model

The fabric joins local and remote participants through a layered design:

- MC-Edge connectivity over the fiber lane
- public edge mediation
- cluster service routing
- runtime service lanes
- database-backed project summaries
- dashboard-based publication and visibility

The result is a project surface where public pages, proof pages, service-pod concepts, and approved live summaries can appear together without exposing the private runtime machinery.

## MC-Dash relationship

MC-Dash is the right place for richer public topology views. The GitHub repository stays conceptual; MC-Dash can render approved summaries from MC-MariaDB and present them as visitor-facing project pages.
