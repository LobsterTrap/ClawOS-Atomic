# Host Image And Release

## Purpose

The ClawOS host image should be small, predictable, signed, and rollbackable.
The host exists to provide hardware support, system services, policy,
integration points, and recovery. It is not where agents improvise.

## Base Strategy

ClawOS should derive from Fedora Atomic / bootc-style images and follow the
Universal Blue pattern:

- Containerfile-based image builds.
- Signed OCI images.
- CI-driven promotion.
- SBOM generation.
- Rebase-friendly delivery.
- Staged rollout channels.
- Rollback archive strategy.

## Host Contents

The host should include only components that must be on the host:

- Kernel, firmware, drivers, and hardware enablement.
- systemd, SELinux, NetworkManager, PipeWire, Flatpak, and xdg-desktop-portal.
- OpenClaw system integration.
- OpenShell service integration.
- `claw-portals`.
- `claw-policy-center`.
- Podman, bootc, rpm-ostree tooling as needed.
- TPM/FIDO2/keyring integration.
- Accessibility stack.
- Recovery tools.

Everything else should default to:

- Flatpak.
- OpenShell sandbox.
- Container.
- Dev container.
- OpenClaw skill/plugin/extension.
- User-space package.

## OpenShell Sandbox Images

ClawOS should build and ship a curated baseline set of OpenShell sandbox
images through the same CI, signing, SBOM, and release process as the OS image.

Project Hummingbird images should be the preferred base catalog or direct
runtime source when appropriate:

- Use Hummingbird images directly when they satisfy a profile.
- Pin and verify direct runtime images by digest and signature.
- Build thin ClawOS-derived images when OpenShell needs entrypoints, shell
  tooling, CA policy, GPU hooks, workspace mounts, or integration glue.
- Allow independent user/admin images only by policy, with provenance checks,
  explicit profile binding, and audit visibility.

Default trusted profiles should include:

- `default`.
- `developer`.
- `network-limited`.
- `gpu`.
- `high-risk` or `untrusted-research`.

## Update And Rollback UX

Host updates should be expressed as typed portal operations, not shell commands.
Each mutating update/rebase/rollback request needs:

- Dry-run result.
- Risk classification.
- User/admin approval state.
- Audit ID.
- Rollback plan or explicit "no rollback" declaration.
- Reboot requirement.
- User-visible summary.

## Open Design Work

- Define image channel names and promotion gates.
- Define SBOM/signature verification policy.
- Define the default Hummingbird-derived sandbox image catalog.
- Define bootc/rpm-ostree rollback metadata mapping into portal operation
  envelopes.
- Define recovery UI behavior when an image fails to boot.
