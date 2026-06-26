# OpenShell Execution

## Purpose

OpenShell is the default execution substrate for agent command execution,
coding tasks, data work, browser automation, untrusted research, and
long-running jobs. ClawOS should not invent a second execution substrate when
OpenShell provides the right conceptual layer.

## Deployment Model

ClawOS should ship a system-level OpenShell gateway, but the gateway must run
as a dedicated non-root `openshell` system user.

The gateway should:

- Use rootless Podman as the backend.
- Own the OpenShell service domain without running as root.
- Isolate actual execution per OpenShell tenant.
- Support local users mapped into OpenShell tenants by `claw-policy-center`.
- Align with OpenShell upstream multitenancy direction.

## Tenant And Profile Mapping

`claw-policy-center` owns the tenant registry. It maps local Linux users to
OpenShell tenants and assigns profiles.

Each tenant should have:

- Stable tenant ID derived from local account identity, not just username.
- Local Linux user identity for audit attribution.
- One or more profiles such as `default`, `developer`, `network-limited`,
  `gpu`, or `high-risk`.
- SELinux label/category mapping.
- systemd slice/scope assignment for CPU, memory, IO, and process limits.
- Rootless Podman containers owned by the `openshell` service account but
  attributed back to the tenant.

## Workspace Model

Project sandboxes should use persistent workspaces with disposable compute.

```text
OpenShell runtime
  Disposable container/process state.

OpenShell workspace
  Persistent tenant/project storage managed by ClawOS/OpenShell.

Host system
  OS, user home, apps, devices, network, policy, and other users.
```

Ordinary writes inside an already-authorized workspace do not require a portal
per write. Workspace lifecycle and host-boundary operations do require
mediation.

Workspace portal operations should include:

- Create project workspace.
- Bind workspace to tenant/project/profile.
- Attach workspace to a sandbox.
- Import from host folder or document portal handle.
- Export selected changes back to host.
- Snapshot/checkpoint workspace.
- Delete/archive workspace.
- Show diff/provenance/audit history.

By default, project persistence should live in ClawOS/OpenShell-managed
workspace storage or rootless Podman volumes owned by the `openshell` service
identity. Broad direct bind mounts from the user's home directory should not be
the default persistence model.

## Allowed Inside OpenShell

Sandbox-local, workspace-scoped actions covered by the active OpenShell profile
may happen inside OpenShell without a host portal:

- Editing files inside the authorized workspace.
- Running build/test/lint/format commands.
- Performing data analysis over approved input files.
- Installing packages inside the sandbox or disposable runtime.
- Fetching dependencies from allowed network destinations.
- Running sandboxed browser automation.
- Using approved credential relay for specific tools such as `git`.
- Generating files, patches, reports, and build artifacts.
- Running local dev services bound only to sandbox/private ports.
- Cloning repositories into the workspace when policy allows it.

Actions cross into portal territory when they alter the host, expose services
to the host or LAN, persist new authority, touch files/devices outside the
workspace grant, or require broader storage access.

## Default Profiles

Initial profiles should include:

- `personal-safe`: approved folders only, no host secrets, network
  ask/allowlist.
- `developer`: project workspace read/write, package registries, Git remotes.
- `developer-gpu`: developer plus explicit GPU visibility.
- `untrusted-research`: no home access, no local network, disposable storage.
- `airgapped-local`: no external network, local models/docs only.
- `enterprise-managed`: centrally managed policy and audit export.

## Open Design Work

- Define the tenant registry schema in `claw-policy-center`.
- Define workspace storage paths and rootless Podman volume ownership.
- Define OpenShell profile schema and generation process.
- Define credential relay binding to profile, binary, destination, and tenant.
- Define how sandbox lifecycle events become audit events.
