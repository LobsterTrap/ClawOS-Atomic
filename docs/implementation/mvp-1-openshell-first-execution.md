# MVP 1: OpenShell-First Execution

## Goal

Make OpenShell the default agent execution substrate. OpenClaw command
execution should run in OpenShell sandboxes through tenant/profile policy,
with persistent workspaces and disposable compute.

## Deliverables

- Dedicated non-root `openshell` system user and rootless Podman backend.
- Local-user to OpenShell tenant mapping owned by `claw-policy-center`.
- Initial OpenShell profiles: `personal-safe`, `developer`,
  `developer-gpu`, `untrusted-research`, `airgapped-local`, and
  `enterprise-managed`.
- Persistent workspace storage with disposable runtime containers.
- Curated baseline sandbox image catalog.
- Sandbox lifecycle audit events.

## Implementation Changes

- Add `services/openshell-gateway/` integration code that starts the local
  OpenShell gateway as the `openshell` user and manages rootless Podman
  execution.
- Add `schemas/openshell/tenant.schema.json`,
  `schemas/openshell/profile.schema.json`, and
  `schemas/openshell/workspace.schema.json`.
- Add `images/sandboxes/` definitions for the initial trusted profiles. Use
  Project Hummingbird images directly when they satisfy a profile; build thin
  ClawOS-derived images only for entrypoints, CA policy, GPU hooks, workspace
  mounts, or agent integration glue.
- Add `packaging/systemd/claw-openshell-gateway.service` and a matching
  systemd slice template for tenant resource attribution.
- Add an OpenClaw integration path that blocks execution if OpenShell is
  unavailable instead of falling back to host shell.

## Interfaces And State

- Tenant IDs must be stable and derived from local account identity, not only
  username. Store the registry under
  `/var/lib/claw-policy-center/openshell/tenants.json`.
- Workspaces live under `/var/lib/claw/openshell/workspaces/` or rootless
  Podman volumes owned by the `openshell` service identity.
- Generated OpenShell policy lives under
  `/var/lib/claw-policy-center/generated/openshell/`.
- Each tenant record includes local UID/GID attribution, profile list, SELinux
  category mapping, systemd slice/scope mapping, and audit identity.
- Workspace lifecycle operations are mediated through the future
  `org.claw.Portals.Workspaces` interface; MVP 1 may provide a local internal
  API, but it must match the planned portal vocabulary.

## Security Requirements

- No broad direct bind mount of the user's home directory by default.
- Ordinary writes inside an authorized workspace do not require a portal per
  write.
- Host-boundary operations, workspace import/export, profile changes,
  credential relay, host port exposure, devices, GPU, and local network access
  require policy decisions.
- Sandbox-local package installation is allowed only inside the active
  disposable runtime or workspace scope.
- Credential relay must bind to tenant, profile, binary, destination, and
  credential class.

## Test Plan

- OpenClaw runs a build/test workflow inside an OpenShell sandbox.
- Killing or disabling OpenShell causes execution requests to fail closed.
- Workspace files persist after runtime container recreation.
- The `developer` profile can reach approved package registries and Git
  remotes; `airgapped-local` cannot reach external networks.
- The `untrusted-research` profile has no home access and no local network
  access.
- Sandbox create, start, stop, destroy, import, export, and profile denial
  events produce audit records.
- Rootless Podman containers are owned by `openshell` but audit attribution
  maps back to the local user and tenant.

## Acceptance Criteria

- Agent command execution defaults to OpenShell for normal workflows.
- Host shell is not used as a fallback path.
- Tenants, profiles, workspaces, and audit records are visible through
  `claw-policy-center` storage and CLI inspection.
- At least one trusted sandbox image supports a developer build/test loop.

## Implementation Risks

- OpenShell upstream multitenancy details may change; keep the ClawOS tenant
  registry isolated behind a narrow adapter.
- SELinux category mapping and rootless Podman ownership need early VM tests.
- GPU support can land after the base developer and safe profiles if driver
  integration blocks progress.
