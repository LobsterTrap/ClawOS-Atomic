# MVP 4: Desktop Integration

## Goal

Make desktop context and app actions agent-addressable without granting
ambient access to pixels, clipboard data, browser contents, accessibility
trees, or UI control.

## Deliverables

- FreeDesktop portal integration for document handles, screenshots,
  screencast, remote desktop, secrets, notifications, settings, printing, and
  device requests where available.
- GNOME Shell and KDE Plasma adapters for structured context gaps.
- Context item schema with provenance, sensitivity, source, timestamp, grant,
  retention, and DLP labels.
- Capture/OCR permission model with visible indicators.
- Accessibility boundary enforcement.
- Initial app-intents metadata convention.

## Implementation Changes

- Add `services/desktop-adapters/` with shared adapter protocol code and
  separate GNOME/KDE implementations.
- Add schemas under `schemas/desktop/context-item.schema.json` and
  `schemas/desktop/app-intent.schema.json`.
- Add packaging under `packages/desktop/` and shell-specific assets under
  `packaging/desktop/`.
- Add policy-center integration so context access, capture, OCR,
  accessibility, and control grants are evaluated, displayed, audited, and
  revocable.
- Add OpenClaw context ingestion that accepts structured context items only
  with provenance and grant metadata.

## Interfaces And State

- Context sensitivity levels:
  - Level 0 `presence`: active app identity, system health, pending updates,
    active tasks.
  - Level 1 `metadata`: window class/title when not private, document URI
    handle, app actions.
  - Level 2 `selected_content`: selected text/file/image and clipboard item
    after approval.
  - Level 3 `pixels_accessibility`: screenshot, OCR, accessibility tree, and
    screen reader-visible content.
  - Level 4 `control`: click, type, drag, app automation, and remote desktop
    actions.
- Every context item includes `context_id`, `source`, `source_app`,
  `sensitivity_level`, `provenance`, `timestamp`, `grant_id`, `tenant`,
  `retention`, `labels`, and `redactions`.
- App intents declare required permissions, input/output types, read-only or
  mutating behavior, approval behavior, and rollback/undo behavior when
  relevant.
- Capture/OCR grants distinguish one-shot, session, app-scoped, and durable
  automation.
- Raw pixels and OCR text use short retention by default. Saving them to memory
  requires a separate memory grant.

## Security Requirements

- Default desktop context is low-sensitivity metadata only.
- Private windows, password fields, secure prompts, lock screens, protected
  enterprise apps, and other users' sessions are blocked or redacted.
- Accessibility text/content access requires source/app-scoped grants.
- Accessibility actions are control capabilities and require approval or a
  durable scoped grant.
- Prefer safer portals, document handles, or app-declared actions before using
  accessibility APIs.
- Flatpak apps remain sandboxed; do not grant broad home, session-bus, or
  system-bus access to simplify automation.

## Test Plan

- Level 0 and Level 1 context is available by default where policy permits.
- Selected content, clipboard, screenshots, OCR, accessibility tree, and UI
  control require grants.
- Screen capture and OCR show a visible indicator while active.
- Capture/OCR audit records include source, sensitivity, grant, retention, and
  redaction details.
- Private windows, password fields, lock screens, and protected apps are
  excluded or redacted.
- Flatpak apps are observed or controlled only through portals, document
  handles, PipeWire streams, file descriptors, or explicit grants.
- GNOME and KDE adapters emit the same context schema for equivalent events.

## Acceptance Criteria

- OpenClaw can use structured desktop metadata without ambient capture.
- Higher-sensitivity content and UI control are gated, visible, auditable, and
  revocable.
- App intents provide a typed path for common actions without raw UI control.
- Enterprise redaction hooks can block protected app context.

## Implementation Risks

- GNOME and KDE capabilities will not be identical; normalize output while
  preserving source-specific limitations.
- Capture indicators may require shell-specific code and separate UX review.
- Accessibility boundaries need adversarial tests before broad automation is
  enabled.
