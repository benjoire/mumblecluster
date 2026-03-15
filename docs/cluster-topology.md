## Cluster topology

               Internet
                    │
            proof.mumblehighlife.de
                    │
               Ingress (HEX22)
                    │
            ┌──── Kubernetes ────┐
            │                    │
        BENQ (controller)    BELL (worker)
                │
            WireGuard mesh
                │
            HEX22 (WAN worker)
