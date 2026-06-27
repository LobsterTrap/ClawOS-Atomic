# MVP 5: Managed Workstation Mode

## Goal

Add enterprise governance for identity, policy, model providers, remote
execution, DLP, audit export, and offline enforcement while preserving the
same OpenShell, portal, and policy-center architecture.

## Deliverables

- SSSD/PAM/IdP group mapping to local users, tenants, roles, and profiles.
- Managed policy sync into `/etc/claw/policy.d/managed/`.
- Model provider and remote execution allowlists.
- DLP label ingestion, classification, enforcement, and audit.
- SIEM-friendly audit export.
- Offline cached-policy enforcement.

## Implementation Changes

- Add enterprise schemas under `schemas/enterprise/` for IdP mapping, managed
  policy source, model providers, remote execution zones, DLP labels, export
  sinks, and offline enforcement.
- Add policy-center sync code that writes managed policy revisions into
  `/etc/claw/policy.d/managed/` and activates them atomically.
- Add provider policy integration for model routing, OpenClaw tool policy,
  OpenShell network policy, portal policy, credential relay, and DLP checks.
- Add audit export pipeline from journald/auditd and structured
  `claw-policy-center` events to SIEM-friendly JSON.
- Add emergency kill switches for model providers, remote execution,
  credential relay, capture/OCR export, and sandbox egress.

## Interfaces And State

- Managed policy path: `/etc/claw/policy.d/managed/`.
- Cached active managed policy path:
  `/var/lib/claw-policy-center/managed/active/`.
- Enterprise identity maps IdP groups to local users, tenants, policy roles,
  OpenShell profiles, model zones, remote execution permissions, and DLP
  posture.
- Provider policy defines approved provider IDs, model IDs, model zones
  (`local`, `enterprise`, `public_cloud`), allowed data classes, retention
  limits, logging constraints, redaction requirements, and offline behavior.
- Remote execution policy defines approved OpenShell gateways, accounts,
  regions, profiles, data classes, GPU permission, internet permission, and
  credential relay permission.
- Audit export events include tenant, local user, agent, skill/plugin,
  operation ID, audit ID, source, destination, policy decision, approval, data
  labels, and enforcement result.

## Security Requirements

- Default enterprise posture is local or enterprise-approved model providers
  only; public-cloud models are disabled unless explicitly allowed.
- Remote OpenShell execution is disabled unless explicitly allowed.
- Screenshots, OCR, accessibility data, browser data, and protected app context
  cannot leave the device unless policy explicitly allows it.
- If classification is uncertain for sensitive sources, require approval or
  deny by default.
- Cached managed policy continues enforcing offline. New broad grants
  default-deny while management is unavailable.
- Emergency kill switches must take effect without waiting for a full policy
  resync.

## Test Plan

- IdP group mapping assigns expected tenants, profiles, and provider zones.
- Managed policy sync activates a complete revision and rejects partial or
  invalid revisions.
- Public-cloud model use is blocked by default in enterprise mode.
- Remote execution is blocked by default and allowed only for approved
  gateway/account/region/profile combinations.
- DLP labels propagate from source objects to summaries, patches, memory
  entries, tool outputs, model context, and export artifacts.
- DLP blocks disallowed model context, portal export, sandbox egress, and
  credential relay.
- Audit export emits SIEM-friendly events with operation and audit IDs.
- Offline mode continues enforcing cached policy and denies new broad grants.

## Acceptance Criteria

- Admin policy can restrict models, remote execution, DLP, capture export, and
  sandbox egress.
- Enterprise audit events can be exported with enough attribution for SIEM
  ingestion.
- Managed workstations remain enforceable while offline.
- User policy and agent sessions cannot weaken managed policy.

## Implementation Risks

- Enterprise IdP and MDM integrations vary; keep sync adapters separate from
  the policy model.
- DLP detector quality should not be treated as the only enforcement layer.
- Audit export schema should remain append-compatible after MVP 5.
