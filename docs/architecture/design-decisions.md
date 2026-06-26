# Design Decisions

This file records the settled direction from the initial architecture pass. It
is not a full ADR log yet, but each item can become one.

## OpenShell Integration

- ClawOS ships a system-level OpenShell gateway running as a dedicated non-root
  `openshell` system user.
- The gateway uses rootless Podman.
- Local Linux users map to OpenShell tenants through `claw-policy-center`.
- OpenShell profiles map to SELinux labels/categories, systemd resource
  controls, rootless Podman containers, and audit attribution.
- Project sandboxes use persistent workspaces with disposable compute by
  default.
- ClawOS ships curated trusted sandbox images and uses Project Hummingbird as
  the preferred base catalog or direct runtime source where appropriate.

## Portal API

- `claw-portals` use D-Bus APIs modeled after xdg-desktop-portal.
- Portals wrap native system APIs in the Cockpit style instead of replacing
  them.
- OpenClaw/OpenShell see one front-door portal broker with multiple typed
  interfaces.
- High-risk work may run in split backend helpers.
- Mutating portal methods use a common operation envelope with dry-run,
  approval, rollback, and audit metadata.
- Rollback plans are structured recovery contracts with backend references.

## Policy

- `claw-policy-center` is the source of policy intent and grants.
- OpenShell policy is the sandbox enforcement target.
- PolicyKit remains the native host privilege boundary.
- ClawOS uses OPA/Rego for canonical policy evaluation.
- YAML/JSON are schema-validated policy data and backend configuration, not a
  custom ClawOS policy language.
- OpenShell and portal policy share common ClawOS vocabulary while keeping
  backend-specific schemas.
- Admin policy sets ceilings. User policy sets preferences and narrower grants.
- Policy files use layered Linux-style locations.

## Host Mutation

- Actions changing host state outside an authorized OpenShell workspace require
  a portal.
- Workspace lifecycle and host-boundary operations require a workspace portal.
- Sandbox-local, workspace-scoped actions covered by the active OpenShell
  profile may happen inside OpenShell.
- Actions that defeat policy, audit, sandbox, rollback, or consent are
  prohibited.
- Break-glass host shell is human-only, authenticated, logged, time-bound, and
  visually distinct.

## Desktop Integration

- ClawOS is FreeDesktop-first, not FreeDesktop-only.
- GNOME Shell and KDE Plasma adapters fill gaps where shared portals do not
  expose enough structured context.
- Flatpak apps remain protected by their normal sandbox and bubblewrap model.
- Accessibility APIs are sensitive observation/control surfaces.
- Screen capture and OCR are explicit, visible, source-scoped, and
  retention-limited.
- App intents start as a ClawOS convention layered on existing desktop
  standards.

## Enterprise

- Enterprise mode uses existing Linux identity, management, trust, and audit
  paths.
- Admin policy restricts model providers and remote execution through
  allowlists, data classes, and execution zones.
- DLP classifies data before boundary crossing and enforces through OpenClaw
  tool policy, model routing, portal policy, credential relay, and OpenShell
  network policy.

## ADR Follow-Up

Convert these into ADRs when implementation begins:

- ADR: OpenShell gateway identity and rootless Podman backend.
- ADR: Workspace persistence and workspace portal.
- ADR: Portal broker topology and operation envelope.
- ADR: Policy evaluation with OPA/Rego.
- ADR: Desktop adapter API and context provenance.
- ADR: DLP label model and enforcement points.
