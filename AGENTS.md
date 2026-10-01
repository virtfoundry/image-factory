# VirtFoundry image-factory — Cursor / agents

- Homelab for smoke; never Kind.
- Conventional Commits: `feat(ubuntu-node)`, `ci(ubuntu-node)`, `docs`.
- Prefer CI Packer on `ubuntu-latest` over local macOS QEMU for first green build.
- Do not push `:latest`. Pin Kubernetes patch in image tag + digest in VF Template.
- Allowlist: `ghcr.io/virtfoundry/` must be added in helm/operator values before deploy.
- VKS join/bootstrap is **out of scope** here (Phase 2+).
