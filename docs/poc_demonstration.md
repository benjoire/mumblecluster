## Proof-of-Concept Endpoint

Public PoC service:
https://proof.mumblehighlife.de/

The endpoint demonstrates:

• ingress routing from WAN
• Cilium service routing across cluster nodes
• mixed architecture scheduling
• Kubernetes workload exposure through the ingress controller

Traffic path:

Internet
  → HEX22 ingress-nginx
  → Kubernetes service
  → selected cluster node
