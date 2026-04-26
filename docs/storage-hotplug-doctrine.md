# Storage Hot-Plug Doctrine

## Scope

This document describes the current manual storage-host handover doctrine for the MC_PVCSTORE lane in MumbleCluster.

## Proven workflow

- manual storage-host handover between Quorum-3 controller nodes
- WG-safe validation lane for remote worker consumption
- HEX22 used as decisive validation lane
- real storage-backed workload landing verified with webtop-a2g-debian

## Operational rule

After any storage-host identity switch, validation PVC/PV objects must be refreshed before trusting the WG-safe validation lane again.

Reason:
existing PV objects retain the previous NFS server identity.

## Live unplug sequence

1. freeze validation lane
2. unexport
3. sync
4. unmount
5. unplug only after mount is gone
6. attach and mount on target host
7. run local facts
8. run remote claim
9. refresh validation lane
10. verify HEX22 landing

## Tooling

See `tools/storage-host-claim/`.

