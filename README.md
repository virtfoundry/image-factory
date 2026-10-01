# VirtFoundry vks-image-factory

Build and publish **KubeVirt containerDisk** images for VirtFoundry (IaaS guests and **VKS worker nodes**).

| | |
|--|--|
| **VKS Phase** | [1 — Image factory](https://github.com/orgs/virtfoundry/projects/5) |
| **Product** | Digests on `ghcr.io/virtfoundry/*` → Template allowlist → Instance |
| **Not this repo** | Cluster lifecycle (that is `virtfoundry/vks` + CAPI + Kamaji) |

## Images

| Path | Image | Purpose |
|------|-------|---------|
| `images/ubuntu-node/` | `ghcr.io/virtfoundry/node-ubuntu` | VKS worker: Ubuntu LTS + containerd + kubelet/kubeadm (pinned) |
| (later) `images/ubuntu-guest/` | guest OS only | Optional; today seed still uses `quay.io/containerdisks/ubuntu` |

## Tooling

### Required on CI (GitHub Actions `ubuntu-latest`)

| Tool | Role |
|------|------|
| Packer + QEMU plugin | Build qcow2 from Ubuntu cloud image |
| Docker Buildx | Pack qcow2 as containerDisk OCI (`/disk/*.qcow2`) |
| `qemu-img` | Convert/resize disk |
| `ghcr.io` login | Push digest (only after first green build) |

### Required on your Mac (this machine — audit 2026-10-01)

| Tool | Status | Notes |
|------|--------|-------|
| Docker Desktop | **OK** (start app if daemon down) | Context `desktop-linux` |
| `qemu-img` (Homebrew) | **OK** | Convert/inspect |
| Packer | **Installed** via `brew install hashicorp/tap/packer` | Local builds optional; prefer CI |
| `gh` | **OK** (use keyring; unset bad `GH_TOKEN`) | Org `virtfoundry` |
| `kubectl` / `helm` | OK | Homelab smoke after Template seed |
| mkosi / virt-builder / libguestfs | Not required for v1 | Packer path only |

**Do not use Kind** for VirtFoundry smoke — homelab only.

### One-time setup

```bash
# Docker Desktop running
open -a Docker

# Avoid broken env token shadowing keyring
unset GH_TOKEN
gh auth status

# Packer plugins (once)
packer init images/ubuntu-node/
```

## Build flow

```
Ubuntu cloud img
  → Packer (QEMU) + scripts/install-k8s.sh
  → ubuntu-node.qcow2
  → containerdisk/Dockerfile (COPY → /disk/)
  → ghcr.io/virtfoundry/node-ubuntu:<k8s>@sha256:…
  → VirtFoundry Template + allowlist prefix ghcr.io/virtfoundry/
```

### Local (optional, slow on macOS)

```bash
make build-ubuntu-node          # packer → out/*.qcow2
make containerdisk-ubuntu-node  # docker build (no push)
```

### CI

- `workflow_dispatch` and pushes to `main` / tags `node-ubuntu-*`
- Push to GHCR only when `PUSH=true` (manual) or on tag — default is **build artifact only** until we trust the pipeline

## Pin policy

See **[VERSIONS.md](./VERSIONS.md)** for the live evaluation checklist and snapshot.

**Always re-evaluate** Kubernetes + CAPI + Kamaji before changing defaults. Homelab today is **1.36.x**; do not pin ancient minors.

- Default node image: **1.36.5** (2026-10-01)
- Publish by **digest**; no `:latest`
- Allowlist: `ghcr.io/virtfoundry/` in chart/operator values

## Homelab smoke (after first digest)

1. PR allowlist + seed Template (core/helm) pointing at digest  
2. Deploy Instance with that Template + SSH key  
3. SSH in → `kubelet --version` / `kubectl version --client`  
4. **No** `kubeadm join` yet (that is VKS Phase 2+)

## Layout

```
images/ubuntu-node/     Packer HCL + cloud-init + install script
containerdisk/          Dockerfile template for /disk/*.qcow2
.github/workflows/      build-ubuntu-node.yaml
Makefile
```

## License

Apache-2.0 (same as VirtFoundry core).
