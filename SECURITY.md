# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| `main` branch | yes |
| tagged releases | best effort |

## Reporting a vulnerability

**Do not open public GitHub issues for security vulnerabilities.**

Report via a **private GitHub security advisory** on this repository or [virtfoundry/core](https://github.com/virtfoundry/core/security/advisories). Primary contact: **Matheus Thurler** ([@Matheus-Thurler](https://github.com/Matheus-Thurler)) — see [MAINTAINERS.md](MAINTAINERS.md).

Include the affected component (the image build definitions, the published containerDisk images, and the build workflows), impact, reproduction steps, and a suggested fix if any.

We aim to acknowledge within **7 days**.

## Secure deployment

- Pin images by digest (`ghcr.io/virtfoundry/node-ubuntu:<k8s-version>@sha256:...`); never publish or deploy `:latest`.
- Before changing a Kubernetes pin, re-check `VERSIONS.md` and `COMPATIBILITY.md`.
