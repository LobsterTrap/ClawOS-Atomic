# Security Model

## Purpose

ClawOS should be tightly integrated but loosely trusted. The agent can operate
the system coherently, but it does not receive ambient authority over the host,
desktop, secrets, or user data.

## Principles

### No Ambient Authority

OpenClaw, skills, plugins, channels, memory, and model providers should not
gain broad access merely by existing. Authority is granted, scoped, recorded,
and revocable.

### One Trust Boundary Per Gateway Identity

The OpenShell gateway runs as a dedicated `openshell` service user. Portal
helpers and privileged host brokers should have narrow identities and use
native authorization mechanisms.

### OpenShell For Execution, Portals For Host Mutation

OpenShell handles sandboxed code execution. `claw-portals` handle host changes.
Known portal-covered host changes should not be bypassed through raw shell
commands.

### Capability Tiers

Suggested tiers:

```text
Observe metadata
Observe content
Run sandboxed code
Mutate workspace
Mutate host through portal
Access credentials
Control UI
Change policy
Break-glass human repair
```

Each tier needs explicit policy, audit, and user/admin visibility.

### Human-Readable Plans Before Risky Actions

Risky actions should be represented as action cards with:

- What will happen.
- Why the agent proposes it.
- What subsystem will act.
- What data or authority is involved.
- Dry-run summary.
- Rollback/recovery summary.
- Approval options.

### Sandboxed Execution By Default

The default path for shell-heavy work is OpenShell, not host shell. Host shell
execution should be rare, explicit, logged, revocable, policy-gated, and
visually distinct.

### Classify Reversibility Before Acting

Actions should be classified as:

- Natively rollbackable.
- Snapshot rollbackable.
- Compensating-action rollbackable.
- Manual recovery only.
- Not rollbackable.

### Audit Must Distinguish Sandbox Activity From Host Mutation

Audit records should clearly separate:

- Actions inside OpenShell.
- Portal host actions.
- Policy decisions.
- Model/data routing decisions.
- Human break-glass sessions.

## Prohibited Actions

Agents should be prohibited from:

- Obtaining unrestricted root shell as a normal workflow.
- Bypassing `claw-portals` for portal-covered host changes.
- Disabling SELinux, audit, PolicyKit, `claw-policy-center`, or portal
  enforcement.
- Modifying audit logs or rollback records.
- Silently reading secrets, clipboard contents, screenshots, browser data,
  accessibility trees, or another user's files.
- Creating hidden autostart or systemd persistence.
- Installing unsigned or untrusted kernel modules or privileged drivers.
- Weakening secure boot, image verification, or update signing.
- Exfiltrating data after a DLP denial.
- Using host network namespaces or device access outside profile grants.
- Granting themselves new lasting permissions.
- Changing enterprise/admin policy from a user agent.
- Performing destructive actions without typed dry-run and approval when
  dry-run is feasible.

## Break-Glass Host Shell

Break-glass host shell is for humans, not agent automation.

It should be:

- Human-only.
- Explicit.
- Authenticated.
- Time-bound or session-bound.
- Logged on open and close.
- Visually distinct from OpenShell.
- Hidden from normal agent tool access.
- Disabled for agent observation/control by default.

It should provide recovery commands for rollback, grant revocation, stopping
OpenClaw/OpenShell services, inspecting audit records, and restoring policy
defaults.

## Open Design Work

- Define audit event schema and retention.
- Define prohibited action enforcement tests.
- Define break-glass UI and CLI.
- Define rollback classification policy.
- Define threat model for local malicious plugins and compromised agents.
