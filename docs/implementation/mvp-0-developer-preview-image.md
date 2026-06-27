# MVP 0: Developer Preview Image

## Goal

Produce a bootable ClawOS-derived Fedora Atomic / bootc image that establishes
the host shape, packaging boundaries, release pipeline, and recovery path.
This MVP does not need complete agent execution or portal mutation, but the
image must reserve the correct service identities and integration points.

## Deliverables

- Fedora Atomic / bootc-derived host image built from `images/host/`.
- CI image pipeline with build, SBOM, signature, and promotion gates.
- Host integration packages for OpenClaw launch, OpenShell service presence,
  `claw-portals`, `claw-policy-center`, recovery tools, and desktop glue.
- Initial channel names: `dev`, `testing`, and `stable`.
- Rollback documentation and a VM-tested rollback path.
- Developer preview install/rebase instructions.

## Implementation Changes

- Add `images/host/Containerfile` with a Fedora Atomic / bootc base and only
  host-required packages: systemd, SELinux, PolicyKit, NetworkManager,
  PipeWire, Flatpak, xdg-desktop-portal, Podman, bootc/rpm-ostree tooling,
  OpenClaw integration, OpenShell integration, `claw-portals`,
  `claw-policy-center`, TPM/FIDO2/keyring support, accessibility stack, and
  recovery utilities.
- Add packaging stubs under `packages/` and installable assets under
  `packaging/` for D-Bus service files, PolicyKit actions, systemd units,
  tmpfiles rules, SELinux labels, and desktop autostart/session integration.
- Add CI under the repo's chosen forge workflow directory with jobs for image
  build, SBOM generation, signing, smoke boot, and channel promotion.
- Add recovery commands exposed through a CLI package named `claw-recovery`
  for rollback inspection, service stop/start, policy reset, audit inspection,
  and break-glass guidance.

## Interfaces And State

- Image reference format: `clawos/atomic:<channel>` where `<channel>` is
  `dev`, `testing`, or `stable`.
- Host package names should use the `claw-` prefix for ClawOS-owned packages:
  `claw-host-integration`, `claw-portals`, `claw-policy-center`,
  `claw-openshell-integration`, `claw-desktop-integration`, and
  `claw-recovery`.
- System integration must reserve the non-root `openshell` system user but
  leave tenant/profile activation to MVP 1.
- Initial service names should be `claw-portals.service`,
  `claw-policy-center.service`, `claw-openshell-gateway.service`, and
  `claw-firstboot.service`.
- Recovery documentation must map bootc/rpm-ostree deployments to a
  user-visible rollback summary.

## Security Requirements

- The preview image must not grant OpenClaw ambient root access.
- Break-glass host shell is human-only and outside the normal agent tool
  surface.
- CI artifacts must include SBOM and signature metadata before promotion out
  of `dev`.
- Package inclusion must prefer Flatpak, OpenShell images, or user-space
  packages unless a component must run on the host.

## Test Plan

- VM boots into a normal desktop session.
- OpenClaw can be launched by the user.
- `systemctl status` shows ClawOS service units installed, even if later MVP
  services are placeholders.
- Rebase or update creates a second deployment and rollback returns to the
  previous deployment.
- SBOM and image signature artifacts are produced in CI.
- Recovery CLI can display current deployment, previous deployment, and basic
  rollback instructions.

## Acceptance Criteria

- A developer can build and boot the image in a VM from repo instructions.
- The desktop remains usable if OpenClaw or ClawOS services are unavailable.
- Rollback is documented, tested, and visible from `claw-recovery`.
- Host package boundaries match the architecture: apps and tools are not
  installed into the image unless they are host integration dependencies.

## Implementation Risks

- The exact Fedora Atomic base image and signing infrastructure must be chosen
  during CI setup.
- Hardware enablement may require channel-specific package overlays.
- Recovery UI beyond CLI can be deferred, but the CLI path must work in MVP 0.
