# VKS node image & template compatibility

Official mapping between **published node containerDisk images**, **VirtFoundry Template seeds**, and the **Kubernetes / Kamaji** versions they were validated against.

Pin source of truth for component evaluation: **[VERSIONS.md](./VERSIONS.md)**. Update this matrix whenever you publish a new `node-ubuntu` digest or bump Template seed defaults in `virtfoundry/core`.

## Matrix

| Product / Date | node-ubuntu tag + digest | Template seed name | kubernetes_version | Kamaji max | Notes (core / helm / TF) |
|----------------|--------------------------|--------------------|--------------------|------------|---------------------------|
| **2026-10-01** — layout fix republish | `ghcr.io/virtfoundry/node-ubuntu:1.36.5@sha256:0189707919212fe3a104d64fa31b88d1752c39eb94c3044bce1a3242da8a0c02` | `ubuntu-node-1-36-5` | `v1.36.5` | **v1.37.0** | **Use this.** `/disk/disk.img` regular file. CI: [36903066723](https://github.com/virtfoundry/vks-image-factory/actions/runs/36903066723) after [#10](https://github.com/virtfoundry/vks-image-factory/pull/10). |
| **2026-10-01** — first `1.36.5` publish (**broken**) | `…@sha256:f7aeb6ee99dfebac922d3c64d443dd01e961deb1eff3446389bd4cd014b2d229` | `ubuntu-node-1-36-5` | `v1.36.5` | **v1.37.0** | **Do not use.** OCI has `/disk/ubuntu-node.qcow2/` directory → KubeVirt qemu-img SyncFailed. CI: [36887643801](https://github.com/virtfoundry/vks-image-factory/actions/runs/36887643801). |

## How to add a row

1. Publish digest via CI (`node-ubuntu-*` tag or manual `PUSH=true`).
2. Copy tag + `@sha256:…` from GHCR or **VERSIONS.md** snapshot.
3. Add or update Template seed in **core** (name pattern `ubuntu-node-1-XX-Y` ↔ `v1.XX.Y`).
4. Re-check Kamaji `KubeadmVersion` and CAPI workload range in **VERSIONS.md**.
5. Append a row here with homelab-tested **core / helm / TF** pins (or “not yet validated”).

## Related repos

| Repo | Role |
|------|------|
| [virtfoundry/vks-image-factory](https://github.com/virtfoundry/vks-image-factory) | Build & push `node-ubuntu` |
| [virtfoundry/core](https://github.com/virtfoundry/core) | Template seed + VKS API |
| [virtfoundry/helm-charts](https://github.com/virtfoundry/helm-charts) | Chart defaults & allowlist |
| [virtfoundry/terraform-provider-virtfoundry](https://github.com/virtfoundry/terraform-provider-virtfoundry) | IaS + (future) VKS TF resources |
