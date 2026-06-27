# MVP 2: Agent Portals

## Goal

Replace shell-based host mutation with typed portal operations. OpenClaw and
OpenShell should see one stable D-Bus service namespace, and risky host
actions should produce dry-run, approval, audit, and rollback metadata.

## Deliverables

- Front-door D-Bus service `org.claw.Portals`.
- Initial typed interfaces: Apps, Network, Power, Update, Rollback, Secrets,
  Audit, and Workspaces.
- Common operation envelope schema and state machine.
- Rollback plan schema.
- Dry-run and approval routing into `claw-policy-center`.
- Native backend adapters for the first useful host actions.

## Implementation Changes

- Add `services/claw-portals/` with a front broker that owns request
  normalization, caller identity, policy lookup, approval routing, audit
  correlation, dry-run contracts, and backend dispatch.
- Add D-Bus XML under `packaging/dbus/interfaces/` and service activation
  files under `packaging/dbus/services/`.
- Add PolicyKit actions under `packaging/polkit/org.claw.portals.policy`.
- Add schemas under `schemas/portals/operation-envelope.schema.json` and
  `schemas/portals/rollback-plan.schema.json`.
- Add backend helpers only where privilege separation is required. Initial
  helpers should wrap native Fedora/Linux APIs rather than replace them:
  systemd, NetworkManager, PackageKit/Flatpak, bootc/rpm-ostree, Podman,
  PolicyKit, journald/auditd, udisks, and secret service/libsecret.

## Interfaces And State

- D-Bus service namespace: `org.claw.Portals`.
- Object path root: `/org/claw/Portals`.
- Initial interfaces:
  - `org.claw.Portals.Apps`
  - `org.claw.Portals.Network`
  - `org.claw.Portals.Power`
  - `org.claw.Portals.Update`
  - `org.claw.Portals.Rollback`
  - `org.claw.Portals.Secrets`
  - `org.claw.Portals.Audit`
  - `org.claw.Portals.Workspaces`
- Mutating methods return or update an operation envelope with
  `operation_id`, requester identity, tenant, agent, skill/plugin, capability,
  portal interface, native backend, risk class, scope, state, dry-run support,
  dry-run result, approval ID, audit ID, rollback support, and rollback ID.
- Operation states: `created`, `dry_run_pending`, `approval_pending`,
  `approved`, `executing`, `succeeded`, `failed`, `denied`, `cancelled`, and
  `rolled_back`.
- Rollback kinds: `native`, `snapshot`, `compensating`, `manual`, and `none`.
- Store operation records under `/var/lib/claw-policy-center/operations/` and
  audit correlation records under `/var/lib/claw-policy-center/audit/`.

## Security Requirements

- High-risk host mutation requires dry-run unless the backend cannot support
  it; unsupported dry-run must be explicit in the envelope.
- Known portal-covered host changes must not be bypassed by raw shell
  execution from OpenClaw.
- Privileged backend helpers use narrow identities and PolicyKit actions.
- Rollback plans are structured recovery contracts, not free-form scripts.
- Large native artifacts stay in native systems; rollback records store typed
  references.

## Test Plan

- OpenClaw requests a typed host action and receives an operation ID.
- User-visible approval card shows risk, dry-run result, backend, scope, and
  recovery summary.
- Denied policy decisions prevent native backend execution.
- Approved update, app install, network change, and workspace export calls
  produce audit records with operation ID and policy decision.
- Failed backend execution records failure state and rollback availability.
- Rollback-capable operations can be inspected and invoked through the portal
  and recovery CLI.
- Direct attempts to perform a portal-covered host mutation through normal
  agent execution are blocked or routed back to a portal proposal.

## Acceptance Criteria

- `org.claw.Portals` is the only normal host mutation path exposed to
  OpenClaw.
- Initial native backend adapters can perform at least one useful action each
  for updates, apps, network, and workspaces.
- Every mutating operation has policy, approval, audit, and rollback metadata,
  including explicit `none` rollback declarations.

## Implementation Risks

- PackageKit, Flatpak, bootc, and rpm-ostree dry-run semantics differ; the
  envelope must record backend-specific limits without hiding risk.
- Some portal methods may require split helpers earlier than expected to keep
  privileges narrow.
- User-facing approval UI can be minimal in MVP 2 if the CLI and audit path are
  complete.
