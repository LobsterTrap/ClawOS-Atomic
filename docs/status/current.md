# Current Project Status

Last updated: 2026-06-29

This file is the handoff note for resuming ClawOS Atomic work in a fresh Codex
session. The canonical plans remain under `docs/implementation/`; this file
records the current checkpoint, verified state, and next actions.

## Current Checkpoint

- This status handoff is committed on top of
  `55c8f07 build: add MVP 0 bootc image scaffold`.
- Worktree should be clean after the status handoff commit.
- The repo has moved from architecture-only docs to a committed MVP 0 image
  scaffold.
- MVP 0 is not complete yet. The local image can build and pass a container
  smoke check, but VM boot, rollback, SBOM, signing, and CI promotion are not
  implemented.

## Baseline Commits

```text
55c8f07 build: add MVP 0 bootc image scaffold
2126e9b chore: add repo skeleton
63971d2 docs: add implementation plans
27be389 docs: split architecture docs from README
c55ef7b docs: resolve section 12 design questions
```

## Durable Repo State

- `docs/implementation/` contains the MVP 0 through MVP 5 implementation
  plans and cross-cutting verification matrix.
- `images/host/Containerfile` builds the MVP 0 developer preview image.
- The top-level `Makefile` provides:
  - `make image-base-inspect`
  - `make image-build`
  - `make image-inspect`
  - `make verify`
- `images/host/rootfs/` contains placeholder recovery and service executables.
- `packaging/` contains initial D-Bus, PolicyKit, systemd, and tmpfiles assets.
- `packages/*/*.manifest` records placeholder package ownership for MVP 0.
- The placeholder services are installed into the image but intentionally not
  enabled by default.

## Local-Only State

The local Podman store had a built image at the time this status was written:

```text
tag: localhost/clawos-atomic:dev
id: 3729ef62194a05954715d36f3893ab811b2fab9d6d246fa8b311b3096ba71fd9
digest: sha256:0a9a2b5999581370afc105fee8ff4b2701b5b141c25a6366b85fc0bf25777aa0
containers.bootc: 1
ostree.bootable: true
org.clawos.mvp: 0
org.opencontainers.image.version: mvp0-dev
```

This image is not Git state. Rebuild it with `make image-build` if it is
missing in a future session.

## Verification Evidence

Commands run successfully before this status was written:

```sh
git status --short
git log --oneline -5
podman image exists localhost/clawos-atomic:dev
podman image inspect localhost/clawos-atomic:dev --format '...'
podman run --rm --entrypoint /usr/bin/bash localhost/clawos-atomic:dev -lc '...'
```

The image smoke check output was:

```text
mvp0 image smoke ok: 5 package manifests
```

Earlier MVP 0 verification also confirmed:

- `make image-build` built `localhost/clawos-atomic:dev`.
- `make image-inspect` showed `containers.bootc=1`,
  `ostree.bootable=true`, and `org.clawos.mvp=0`.
- `make verify` exited successfully.

## Known Gaps

- No VM boot validation exists yet.
- No rollback validation exists yet.
- No SBOM or signing targets exist yet.
- No CI pipeline exists yet.
- No real OpenClaw, OpenShell, `claw-portals`, or `claw-policy-center`
  implementations exist yet; current units are placeholders.
- The Fedora bootc base currently defaults to
  `quay.io/fedora/fedora-bootc:latest`; pinning strategy is not settled.

## Recommended Next Actions

1. Add VM boot validation for `localhost/clawos-atomic:dev`.
2. Document or automate the bootc-to-VM conversion path in `tests/vm/`.
3. Add rollback validation once the VM boot path works.
4. Add SBOM and signing targets after the local boot path is proven.
5. Decide whether to pin the Fedora bootc base by release tag or digest for CI.

## Resume Prompt

Use this prompt in a fresh Codex session if needed:

```text
Read README.md, docs/status/current.md, and docs/implementation/mvp-0-developer-preview-image.md.
Continue ClawOS Atomic MVP 0 from the current status checkpoint. Prioritize VM boot validation for the locally built bootc image before adding SBOM/signing/CI.
```
