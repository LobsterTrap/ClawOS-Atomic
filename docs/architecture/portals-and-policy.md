# Portals And Policy

## Purpose

`claw-portals` and `claw-policy-center` are the OS integration layers that keep
host mutation typed, permissioned, audited, and rollback-aware.

## Portal API Shape

`claw-portals` should expose D-Bus APIs modeled after xdg-desktop-portal while
following Cockpit's discipline of wrapping native system APIs instead of
replacing them.

The portal layer should:

- Provide stable, typed, request-oriented interfaces.
- Use request handles and user-visible mediation.
- Delegate to native Fedora/Linux APIs where possible.
- Add agent-specific provenance, dry-run, rollback, approval, audit, and risk
  metadata.

Native backends may include:

- systemd.
- NetworkManager.
- PackageKit.
- Flatpak portals.
- Podman.
- bootc/rpm-ostree.
- PolicyKit.
- journald/auditd.
- udisks.

## Broker Topology

OpenClaw and OpenShell should see one stable D-Bus service namespace, such as
`org.claw.Portals`, with multiple typed interfaces:

- `org.claw.Portals.Apps`.
- `org.claw.Portals.Network`.
- `org.claw.Portals.Power`.
- `org.claw.Portals.Update`.
- `org.claw.Portals.Rollback`.
- `org.claw.Portals.Secrets`.
- `org.claw.Portals.Audit`.
- `org.claw.Portals.Workspaces`.

The front broker owns request normalization, caller identity, policy lookup,
approval routing, audit correlation, dry-run contracts, and dispatch.
High-risk or subsystem-specific work may run in narrower backend helpers.

## Operation Envelope

Every mutating portal method should return or update a common operation
envelope containing:

- `operation_id`.
- Requester identity, tenant, agent, skill/plugin.
- Capability and portal interface.
- Native backend.
- Risk class and scope.
- State.
- Dry-run support and dry-run result.
- Approval ID.
- Audit ID.
- Rollback support and rollback ID.

Dry-run should be mandatory for high-risk host mutation unless the backend
genuinely cannot support it.

## Rollback Plan

Rollback support must be a structured recovery contract, not a free-form script
or promise.

A rollback plan should include:

- `rollback_kind`: `native`, `snapshot`, `compensating`, `manual`, or `none`.
- Confidence.
- Expiry.
- Pre-state references.
- Typed backend steps.
- Data-loss risk.
- Reboot requirements.
- User-visible recovery summary.

`claw-portals` should capture the plan during dry-run or immediately before
execution. Large backend-owned artifacts remain in native systems; the rollback
plan stores references to them.

## Policy Model

`claw-policy-center` is the source of policy intent and grants. OpenShell
policy is the sandbox enforcement target. PolicyKit remains the native host
privilege boundary.

ClawOS should use:

```text
OPA/Rego
  canonical policy evaluation layer

YAML/JSON
  schema-validated policy data and backend configuration, not a custom DSL

OpenShell YAML/API updates
  generated enforcement target for sandbox policy

PolicyKit
  native authorization boundary for privileged host operations
```

Policy data should be layered:

```text
/usr/share/claw/policy.d/
  vendor defaults

/etc/claw/policy.d/
  machine/admin policy

~/.config/claw/policy.d/
  user policy and preferences

/var/lib/claw-policy-center/
  generated state, compiled bundles, grants, audit database, active revisions
```

Admin policy sets ceilings. User policy sets preferences, narrower grants, and
personal defaults within those ceilings. User policy cannot weaken admin
policy.

## Common Vocabulary

OpenShell and portal policy should share ClawOS intent vocabulary:

- tenant, principal, local user.
- agent, skill/plugin.
- capability, resource, scope.
- risk class, grant, approval.
- credential class, network destination, workspace.
- operation ID and audit ID.

Backend-specific schemas remain separate. OpenShell keeps execution terms such
as filesystem policy, network policy, process identity, container image,
Landlock, cgroups, devices, and sandbox lifetime. Portals keep host-mutation
terms such as native backend, dry-run result, PolicyKit action, rollback kind,
pre-state references, reboot requirement, data-loss risk, and recovery status.

## Open Design Work

- Define D-Bus interface XML for the first portal set.
- Define operation envelope schema and state machine.
- Define rollback plan schema.
- Define OPA input/output schema.
- Define policy merge and conflict reporting UX.
- Define CLI recovery commands for policy inspection and grant revocation.
