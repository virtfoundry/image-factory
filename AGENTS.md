# VirtFoundry vks-image-factory — Cursor / agents

- Smoke no **homelab Linux** (cluster real ou Kind/Linux com KubeVirt). **Não** Kind no macOS — KubeVirt não roda aí.
- Conventional Commits: `feat(ubuntu-node)`, `ci(ubuntu-node)`, `docs`.
- Prefer CI Packer on `ubuntu-latest` over local macOS QEMU for first green build.
- Do not push `:latest`. Pin Kubernetes patch in image tag + digest in VF Template.
- **Version discipline:** before every pin (especially Kubernetes), re-check
  `VERSIONS.md` / `stable.txt` / CAPI release notes / Kamaji `KubeadmVersion`.
  Homelab is on **1.36.x** — defaults must stay current with that reality.
  Do not keep stale minors (e.g. 1.31/1.34) out of habit.
- Allowlist: `ghcr.io/virtfoundry/` must be added in helm/operator values before deploy.
- VKS join/bootstrap is **out of scope** here (Phase 2+).
