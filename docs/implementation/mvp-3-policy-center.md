# MVP 3: Policy Center

## Goal

Make user/admin policy visible, enforceable, explainable, and recoverable.
`claw-policy-center` becomes the source of policy intent and grants while
generating enforcement state for OpenShell, portals, model routing, and DLP.

## Deliverables

- `claw-policy-center` service, CLI, and initial UI.
- OPA/Rego policy bundle and schema-validated YAML/JSON policy data.
- Layered policy directories for vendor, machine/admin, user, and generated
  state.
- Grant inspection, approval history, revocation, and conflict explanation.
- Tenant/profile registry and generated OpenShell enforcement output.
- Recovery CLI support when the UI is unavailable.

## Implementation Changes

- Add `services/claw-policy-center/` with an API service, policy evaluator,
  storage layer, CLI, and UI entrypoint.
- Add OPA/Rego defaults under `policy/vendor/` and examples under
  `policy/examples/`.
- Add schemas under `schemas/policy/` for policy input, policy decision,
  grant, approval, conflict, generated state, and tenant/profile assignment.
- Add `packaging/systemd/claw-policy-center.service`,
  `packaging/tmpfiles/claw-policy-center.conf`, and recovery CLI packaging.
- Add generated enforcement writers for OpenShell profiles, portal grants,
  model routing constraints, DLP labels, and credential relay policy.

## Interfaces And State

- Policy data locations:
  - `/usr/share/claw/policy.d/` for vendor defaults.
  - `/etc/claw/policy.d/` for machine/admin policy.
  - `~/.config/claw/policy.d/` for user policy and preferences.
  - `/var/lib/claw-policy-center/` for generated state, compiled bundles,
    grants, audit database, operations, and active revisions.
- Admin policy sets ceilings. User policy sets preferences and narrower grants
  inside those ceilings. User policy cannot weaken admin policy.
- Policy decision output includes `decision`, `reason`, `risk_class`,
  `required_approvals`, `grant_id`, `audit_id`, `conflicts`, and contributing
  rule references.
- CLI command group: `claw-policy`. Required subcommands:
  `status`, `tenants`, `profiles`, `grants`, `approve`, `deny`, `revoke`,
  `explain`, `audit`, `recover`, and `doctor`.
- Shared policy vocabulary includes tenant, principal, local user, agent,
  skill/plugin, capability, resource, scope, risk class, grant, approval,
  credential class, network destination, workspace, operation ID, and audit ID.

## Security Requirements

- Policy decisions are auditable and include contributing rule references.
- Durable grants are revocable and cannot be created by skills, plugins,
  models, channels, or agent sessions without policy-center mediation.
- Admin ceilings cannot be weakened by user preferences.
- Recovery commands must allow inspection and revocation without the UI.
- Policy bundle corruption or unavailable management state must fail closed for
  new broad grants.

## Test Plan

- Vendor, admin, and user policy layers merge deterministically.
- User policy cannot allow a capability denied by admin policy.
- Conflict explanations identify the policy file and rule causing the denial.
- Grant creation, approval, revocation, and expiry are reflected in generated
  enforcement state.
- OpenShell tenant/profile changes are written to the generated output and
  produce audit records.
- Recovery CLI can list grants, revoke a grant, inspect tenants, and show
  policy health while the UI is stopped.
- Invalid policy data is rejected by schema validation before activation.

## Acceptance Criteria

- A user can inspect active grants, denials, approvals, sandboxes, and policy
  conflicts.
- Admin policy reliably blocks user attempts to weaken controls.
- Policy decisions are explainable enough for action cards, audit records, and
  recovery CLI output.
- Generated enforcement state is the source consumed by OpenShell and portal
  integration.

## Implementation Risks

- UI scope should stay narrow until policy merge, CLI, and generated
  enforcement are reliable.
- OPA bundle lifecycle and policy revision activation must avoid partial
  updates.
- Audit database format should be stable enough for MVP 5 export without
  locking in every SIEM detail.
