# Contributing to VKS Image Factory

Thank you for helping grow VirtFoundry. This repository lives under the [virtfoundry](https://github.com/virtfoundry) organization.

This repository builds the Kubernetes node containerDisk images (Packer + QEMU) that VKS worker Instances boot from.

## Before you start

- Read the project [governance](GOVERNANCE.md) and [code of conduct](CODE_OF_CONDUCT.md)
- Search [existing issues](https://github.com/virtfoundry/vks-image-factory/issues) before opening a duplicate

## Language

- **Commits**: English only, [Conventional Commits](https://www.conventionalcommits.org/), subject under 72 characters, no trailing period
- **Documentation** and PR descriptions: English

### Commit examples

```
fix(containerdisk): pin good 1.36.5 digest and gate OCI layout
ci(ubuntu-node): wait for cloud-init before apt
docs(vks): official node/template compatibility matrix
```

## Development setup

```bash
# Needs packer with the qemu plugin, qemu-system and xorriso.
# Local builds are slow on macOS; prefer the CI workflow for a first green build.
make build-ubuntu-node
```

## Branch workflow

**Do not commit directly to `main`.** Use:

1. Branch from `main`: `feat/<name>`, `fix/<name>`, `docs/<name>`, or `chore/<name>`
2. Open a PR against `main` with a Summary and a Test plan
3. Wait for CI (`build-ubuntu-node`) before merge; squash merge after approval

## Reporting security issues

Do not open a public issue. See [SECURITY.md](SECURITY.md).
