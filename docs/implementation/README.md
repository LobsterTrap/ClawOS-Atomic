# ClawOS Implementation Plans

This directory turns the architecture direction into implementation-ready
plans. Each MVP document describes the software to build, the repo shape to
introduce, the interfaces to stabilize, and the tests that must pass before
the next MVP is treated as ready.

## Plan Map

| Document | Purpose |
|---|---|
| [mvp-0-developer-preview-image.md](mvp-0-developer-preview-image.md) | Bootable Fedora Atomic / bootc developer preview image |
| [mvp-1-openshell-first-execution.md](mvp-1-openshell-first-execution.md) | OpenShell gateway, tenants, profiles, workspaces, and sandbox audit |
| [mvp-2-agent-portals.md](mvp-2-agent-portals.md) | `org.claw.Portals` D-Bus broker, operation envelope, dry-run, approval, rollback |
| [mvp-3-policy-center.md](mvp-3-policy-center.md) | `claw-policy-center` policy, grants, OPA/Rego, CLI, UI, recovery |
| [mvp-4-desktop-integration.md](mvp-4-desktop-integration.md) | FreeDesktop portals, GNOME/KDE adapters, context items, capture/OCR, app intents |
| [mvp-5-managed-workstation-mode.md](mvp-5-managed-workstation-mode.md) | Enterprise identity, managed policy, provider controls, DLP, audit export |
| [cross-cutting-verification.md](cross-cutting-verification.md) | Security, privacy, rollback, audit, and recovery verification matrix |

## Planned Repo Layout

The first implementation pass should introduce these top-level areas as they
become needed:

```text
images/
  host/                 Fedora Atomic / bootc image definitions
  sandboxes/            Curated OpenShell sandbox image definitions

packages/
  host-integration/     RPM specs and host package manifests
  openshell/            OpenShell gateway integration package
  portals/              claw-portals package metadata
  policy-center/        claw-policy-center package metadata
  desktop/              shell adapter package metadata

services/
  claw-portals/         D-Bus broker and backend helpers
  claw-policy-center/   policy API, CLI, UI, OPA integration
  openshell-gateway/    local OpenShell service integration
  desktop-adapters/     GNOME/KDE adapter services and extensions

schemas/
  audit/                audit event JSON schemas
  desktop/              context item and app-intent schemas
  enterprise/           managed policy, provider, and DLP schemas
  openshell/            tenant, profile, workspace schemas
  policy/               policy input/output and grant schemas
  portals/              operation envelope and rollback schemas
  skills/               skill/plugin authority manifest schemas

policy/
  vendor/               default OPA/Rego policy bundles
  examples/             machine, user, and enterprise policy examples

packaging/
  dbus/                 service and interface files
  polkit/               PolicyKit action definitions
  selinux/              SELinux policy modules and labels
  systemd/              services, sockets, timers, slices, presets
  tmpfiles/             systemd-tmpfiles rules

tests/
  integration/          service and API integration tests
  policy/               OPA/Rego and policy merge tests
  security/             bypass, sandbox, DLP, and prohibited action tests
  vm/                   boot, rollback, update, and recovery validation
```

## Shared Implementation Rules

- Shell-heavy work runs in OpenShell; normal agent execution must not fall
  back to the host shell.
- Host mutation goes through typed `claw-portals` operations, not raw shell
  commands.
- Mutating portal calls use the common operation envelope with dry-run,
  approval, audit, and rollback metadata.
- `claw-policy-center` owns policy intent, grants, tenant/profile mapping,
  OPA/Rego evaluation, generated enforcement state, and recovery inspection.
- PolicyKit, SELinux, systemd, Flatpak, xdg-desktop-portal, and rootless Podman
  remain enforcement boundaries, not optional implementation details.
- Every durable authority grant must be visible, attributable, auditable, and
  revocable.

## Implementation Order

Build the MVPs in order. Later MVPs may define schemas and package stubs early
when needed by an earlier MVP, but no later subsystem should become the normal
execution or mutation path until its security and recovery tests are present.
