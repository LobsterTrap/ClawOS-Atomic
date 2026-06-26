# Desktop Integration

## Purpose

ClawOS should make the desktop agent-addressable without giving the agent
ambient access to pixels, clipboard data, browser contents, accessibility
trees, or UI control.

## FreeDesktop First

ClawOS should be FreeDesktop-first, not FreeDesktop-only.

The portable baseline should use:

- xdg-desktop-portal.
- Flatpak permission and document portal patterns.
- Screenshot and ScreenCast portals.
- RemoteDesktop portal where control is explicitly granted.
- Camera, USB, secrets, notifications, settings, printing, and network portals
  where available.
- PipeWire streams for capture.
- Document handles and file descriptors instead of broad filesystem paths.

## GNOME/KDE Adapters

ClawOS should add desktop adapters for context that does not yet have an
adequate shared portal.

Initial adapters:

- GNOME Shell.
- KDE Plasma.

Possible later adapters:

- wlroots-based desktops.
- COSMIC.

Adapter-provided context may include:

- Focused app state.
- Private-window state.
- App-declared actions.
- Shell overview/task state.
- Notification semantics.
- App intent discovery.

## Context Levels

Default structured context should be low-sensitivity metadata only.

```text
Level 0: presence
  active app identity, system health, pending updates, active tasks

Level 1: metadata
  window class/title when not private, document URI handle, app actions

Level 2: selected content
  selected text/file/image, clipboard item after approval

Level 3: pixels and accessibility tree
  screenshot, OCR, accessibility tree, screen reader-visible content

Level 4: control
  click, type, drag, app automation, remote desktop style actions
```

Every context item passed to an agent should carry provenance, sensitivity
level, source app, timestamp, and grant ID.

## Accessibility Boundary

Accessibility APIs are sensitive observation and control surfaces, not ambient
context.

- Widget metadata is low to medium sensitivity.
- Reading accessible text/content requires source/app-scoped grants.
- Accessibility actions are control capabilities and require approval or a
  durable scoped grant.
- Password fields, private windows, secure prompts, lock screens, and other
  users' sessions are blocked.
- Enterprise policy can disable or restrict accessibility-tree access.
- Accessibility should not be used when a safer portal, document handle, or
  app-declared action exists.

## Screen Capture And OCR

Screen capture and OCR should be explicit, visible, source-scoped, and
retention-limited.

- Prefer window/app/region capture over whole-screen capture.
- Show a persistent visible indicator while capture/OCR is active.
- OCR inherits the permission scope of the captured source.
- Raw pixels and OCR text have short retention by default.
- Saving screenshots/OCR into memory requires separate consent.
- Private windows, password fields, lock screens, secure prompts, and protected
  enterprise apps are excluded or redacted.
- Grants distinguish one-shot, session, app-scoped, and durable automation.

## Flatpak Integration

Flatpak apps should remain protected by their normal sandbox and bubblewrap
permission model. ClawOS should observe or control Flatpak apps through portals,
document handles, file descriptors, PipeWire streams, and explicit user grants.
It should not grant broad home, session-bus, or system-bus access merely to
make automation easier.

## App Intents

ClawOS can standardize app intents as a convention layered on existing desktop
standards, then upstream useful pieces.

Use existing mechanisms first:

- Desktop files.
- MIME handlers.
- xdg portals.
- Document portal handles.
- D-Bus activatable services.
- Flatpak metadata.
- URL schemes.
- App actions where available.

Initial app intents may include:

- Open document.
- Summarize selected content.
- Export or share.
- Convert file.
- Start meeting/call.
- Compose message.
- Create task/event.
- Run project command.
- Reveal file/object.
- Explain current state.

Intents should declare required permissions, input/output types, whether they
are read-only or mutating, expected approval behavior, and rollback/undo
behavior when relevant.

## Open Design Work

- Define adapter API between desktop extensions and OpenClaw.
- Define context item schema and provenance fields.
- Define app-intents metadata format.
- Define capture indicator UX across GNOME and KDE.
- Define enterprise redaction hooks for protected apps.
