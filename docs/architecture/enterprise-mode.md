# Enterprise Mode

## Purpose

Enterprise mode turns ClawOS into a managed workstation while preserving the
same core architecture: OpenShell for sandboxed execution, portals for host
mutation, and `claw-policy-center` for policy and audit.

## Identity And Device Management

ClawOS should integrate with existing Linux and enterprise identity paths:

- SSSD.
- PAM.
- Kerberos/OIDC where appropriate.
- Enterprise IdP mapping to local users and groups.

Device management should:

- Sync managed policy into `/etc/claw/policy.d/managed/`.
- Control bootc image channels and rollout policy.
- Integrate with rpm-ostree/bootc update controls.
- Expose MDM hooks where available.
- Continue enforcing cached policy while offline.
- Default-deny new broad grants while management is unavailable.

## Trust And Secrets

Enterprise trust should use existing system facilities:

- System trust store.
- TPM/FIDO2.
- Kernel keyring/libsecret.
- Enterprise CA policy.
- Managed certificate distribution.

## Audit Export

Audit export should integrate with:

- journald.
- auditd.
- Structured `claw-policy-center` event export.
- SIEM-friendly output formats.

Events should include tenant, local user, agent, skill/plugin, operation ID,
audit ID, source, destination, policy decision, approval, and enforcement
result where relevant.

## Model Providers And Remote Execution

Admin policy should restrict model providers and remote execution through
explicit allowlists, data classes, and execution zones.

Admins should control:

- Approved model providers and model IDs.
- Local-only, enterprise-hosted, and public-cloud model zones.
- Data classes each provider/model may receive.
- Whether screenshots/OCR/accessibility/browser data can leave the device.
- Whether remote OpenShell execution is allowed.
- Approved remote OpenShell gateways, accounts, and regions.
- Which profiles may use remote execution, GPU, internet, or credential relay.
- Maximum context retention/logging settings.
- Mandatory redaction rules.
- Emergency kill switches.

Default enterprise posture:

- Local or enterprise-approved providers only.
- Public-cloud models disabled unless explicitly allowed.
- Remote execution disabled unless explicitly allowed.

## DLP Policy

DLP means Data Loss Prevention. It answers:

```text
Is this data allowed to leave this boundary through this tool, model, portal,
or network destination for this user, tenant, and profile?
```

Evaluation flow:

1. Classify data by explicit labels, source, path/workspace policy, portal
   metadata, tool provenance, detectors, or local classifier suggestions.
2. Build a policy input with tenant, profile, agent, action, data classes,
   source, destination, tool/model, and risk.
3. Evaluate in `claw-policy-center` using OPA/Rego.
4. Enforce through OpenClaw tool policy, model routing, portal policy,
   credential relay, and OpenShell network policy.
5. Audit whether the data was allowed, redacted, approved, blocked, or
   transmitted.

If classification is uncertain for sensitive sources, enterprise mode should
require approval or deny by default.

## Open Design Work

- Define IdP group/role to tenant/profile mapping.
- Define managed policy sync mechanism.
- Define SIEM export schemas.
- Define provider and remote execution policy schema.
- Define DLP label ingestion from enterprise systems.
- Define offline enforcement behavior.
