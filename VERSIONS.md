# Versions — evaluated 2026-10-01

Do **not** copy old pins blindly. Re-run this checklist before changing defaults.

## Checklist

1. `curl -fsSL https://dl.k8s.io/release/stable.txt`
2. Latest patch per minor: GitHub `kubernetes/kubernetes` releases
3. Homelab management: `kubectl version` (server)
4. CAPI release notes — management + workload ranges
5. Kamaji `internal/upgrade/kubeadm_version.go` (`KubeadmVersion` = max TCP)
6. CAPCP Kamaji + CAPK (or our Instance adapter) release notes

## Snapshot (2026-10-01)

| Component | Version | Notes |
|-----------|---------|--------|
| Kubernetes **stable** | **v1.37.1** | `dl.k8s.io/release/stable.txt` |
| Kubernetes **1.36 latest** | **v1.36.5** | |
| Homelab management cluster | **v1.36.3** | server |
| **VKS node image default** | **1.36.5** | Same minor as host; ≤ Kamaji max |
| **Published containerDisk** | `ghcr.io/virtfoundry/node-ubuntu:1.36.5@sha256:f7aeb6ee99dfebac922d3c64d443dd01e961deb1eff3446389bd4cd014b2d229` | CI run 36887643801 (2026-10-01) |
| Cluster API | **v1.14.2** | Mgmt `v1.33–v1.37`, Workload `v1.31–v1.37` |
| Kamaji (edge) | **26.9.5-edge** | Code: `KubeadmVersion = v1.37.0` |
| CAPCP Kamaji | **v0.21.0** | `clusterctl init --control-plane kamaji` |
| CAPK (optional path) | **v0.11.2** | If Machines via KubeVirt provider |
| k0smotron (alt CP) | **v2.2.0** | Only if we switch off Kamaji |

### Why not pin 1.37.1 on nodes yet?

Kamaji webhook rejects TCP `> KubeadmVersion` (**v1.37.0**). Prefer **1.36.5** (aligns with homelab **1.36.3**) or at most **1.37.0** until Kamaji bumps the constant.

### Why not 1.34.x?

Stale relative to host (1.36) and ecosystem; CAPI already supports through 1.37.

## Update this file

When you bump pins, edit the snapshot table and the date in the title.
