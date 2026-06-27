# Cross-Cutting Verification

## Purpose

This matrix defines the tests that protect the ClawOS trust boundaries across
all MVPs. Each subsystem can add its own tests, but these scenarios must remain
visible because they catch architectural regressions.

## Required Test Areas

### Execution Boundary

- Normal agent command execution runs in OpenShell.
- OpenShell unavailable means execution fails closed.
- Agent attempts to request host shell fallback are denied or routed to a
  human-only break-glass path.
- OpenShell profile restrictions apply to filesystem, network, credentials,
  devices, GPU, local services, and workspace lifetime.
- Workspace persistence survives disposable runtime recreation.

### Host Mutation Boundary

- Portal-covered host changes cannot be performed through normal agent shell
  execution.
- Mutating portal operations include operation ID, policy decision, approval
  state, audit ID, dry-run result, and rollback metadata.
- High-risk host mutation without dry-run support is explicitly recorded and
  requires policy approval.
- Backend failures preserve operation state and recovery metadata.
- Rollback operations are typed and auditable.

### Policy And Grants

- Vendor, admin, user, and generated policy layers merge deterministically.
- Admin ceilings cannot be weakened by user policy.
- Skills, plugins, model providers, channels, and agent sessions cannot create
  durable authority without `claw-policy-center`.
- Grants can be inspected, explained, revoked, expired, and audited.
- Corrupt or invalid policy data is rejected before activation.

### Audit

- Audit distinguishes OpenShell activity, portal host actions, policy
  decisions, model/data routing decisions, desktop capture/control, and
  break-glass sessions.
- Events include tenant, local user, agent, skill/plugin, operation ID, audit
  ID, source, destination, decision, approval, and enforcement result where
  relevant.
- Agents cannot modify audit logs or rollback records.
- Recovery CLI can inspect audit state if the UI is unavailable.

### Desktop Privacy

- Default context is Level 0 or Level 1 metadata only.
- Clipboard, selected content, pixels, OCR, accessibility trees, and UI
  control require scoped grants.
- Capture/OCR has a persistent visible indicator while active.
- Private windows, password fields, secure prompts, lock screens, protected
  enterprise apps, and other users' sessions are blocked or redacted.
- Raw pixels and OCR text obey retention limits.

### DLP And Model Routing

- Data labels attach to sources, derived objects, memory, tool inputs/outputs,
  model context, and export artifacts.
- Derived summaries, patches, reports, embeddings, and memory entries inherit
  labels from inputs unless policy explicitly permits downgrading.
- Model routing enforces provider allowlists and redaction requirements, but
  enforcement also occurs in OpenShell, portals, tool policy, and credential
  relay.
- Disallowed exports, sandbox egress, model context sends, and credential
  relay attempts are blocked and audited.

### Recovery And Break-Glass

- Host rollback can be inspected and invoked from recovery tooling.
- Grants can be revoked from CLI when the policy UI is unavailable.
- Break-glass host shell is human-only, authenticated, logged, visually
  distinct, and hidden from normal agent tools.
- Starting and ending break-glass sessions creates audit records.
- Recovery commands can stop OpenClaw/OpenShell services and restore policy
  defaults.

## Minimum Gates By MVP

| MVP | Required verification gate |
|---|---|
| MVP 0 | VM boot, OpenClaw launch, rollback, recovery CLI, image SBOM/signature |
| MVP 1 | OpenShell execution default, fail-closed behavior, workspace persistence, sandbox audit |
| MVP 2 | Portal operation envelope, dry-run, approval, rollback, host mutation bypass prevention |
| MVP 3 | Policy merge, admin ceiling enforcement, grant lifecycle, recovery CLI, generated enforcement |
| MVP 4 | Context sensitivity gating, capture indicators, redaction, Flatpak boundary preservation |
| MVP 5 | Managed policy sync, provider restrictions, DLP enforcement, audit export, offline enforcement |
