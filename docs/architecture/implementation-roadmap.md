# Implementation Roadmap

## Purpose

This roadmap keeps implementation sequencing aligned with the architecture. It
is not a release promise. Each MVP should produce working software, tests, and
clear acceptance criteria before moving to the next layer.

## MVP 0: Developer Preview Image

Goal: bootable ClawOS-derived image with the basic host shape.

Deliverables:

- Fedora Atomic / bootc-derived image.
- Signed image build pipeline.
- OpenClaw packaged and started for the user.
- OpenShell integration package present.
- Basic recovery tools.
- Initial docs and architecture tree.

Acceptance criteria:

- Image boots on target hardware/VM.
- User can open normal desktop session.
- User can run OpenClaw.
- Host rollback path is documented and tested.

## MVP 1: OpenShell-First Execution

Goal: agent command execution defaults to OpenShell.

Deliverables:

- Dedicated non-root `openshell` system user.
- Rootless Podman backend.
- Tenant mapping in `claw-policy-center`.
- Initial OpenShell profiles.
- Persistent workspace with disposable compute.
- Curated baseline sandbox images.

Acceptance criteria:

- Agent runs build/test workflow inside OpenShell.
- Host shell is not used for normal execution.
- Workspace persists across disposable runtime recreation.
- Sandbox events appear in audit records.

## MVP 2: Agent Portals

Goal: typed host actions replace shell-based host mutation.

Deliverables:

- `org.claw.Portals` broker.
- Initial apps/update/network/systemd/workspace portals.
- Operation envelope schema.
- Dry-run and approval flow.
- Rollback plan schema.

Acceptance criteria:

- OpenClaw can request a typed host action.
- User sees action card with risk, dry-run, and recovery information.
- Portal delegates to native Fedora/Linux backend.
- Audit record includes operation ID and policy decision.

## MVP 3: Policy Center

Goal: user/admin policy becomes visible and enforceable.

Deliverables:

- `claw-policy-center` UI and CLI.
- OPA/Rego policy bundle.
- Layered policy directories.
- Grant inspection and revocation.
- Admin ceiling/user preference merge.
- Policy conflict explanations.

Acceptance criteria:

- User can inspect active grants and sandboxes.
- Admin policy can block user policy from weakening controls.
- Policy decisions show contributing rules.
- Recovery CLI can inspect grants if UI is unavailable.

## MVP 4: Desktop Integration

Goal: structured desktop context and app actions without broad ambient capture.

Deliverables:

- FreeDesktop portal integration.
- GNOME Shell adapter.
- KDE Plasma adapter.
- Context item schema.
- Capture/OCR permission model.
- Accessibility boundary enforcement.
- Initial app-intents convention.

Acceptance criteria:

- Agent can use low-sensitivity desktop metadata by default.
- Selected content, screenshots, OCR, and UI control require grants.
- Capture has visible indicator and audit records.
- Flatpak apps remain sandboxed.

## MVP 5: Managed Workstation Mode

Goal: enterprise governance for identity, policy, models, remote execution, and
DLP.

Deliverables:

- SSSD/PAM/IdP group mapping.
- Managed policy sync.
- Model provider allowlists.
- Remote OpenShell execution controls.
- DLP classification and enforcement.
- SIEM export.

Acceptance criteria:

- Admin policy restricts model providers and remote execution.
- DLP blocks disallowed exports and sandbox egress.
- Audit events export to enterprise pipeline.
- Cached policy continues enforcing offline.

## Cross-Cutting Test Areas

- Sandbox escape and host mutation bypass attempts.
- Portal dry-run/rollback correctness.
- Policy merge and conflict handling.
- Audit completeness.
- Desktop capture privacy.
- DLP label inheritance.
- Recovery and break-glass behavior.
