# System Architecture

## Purpose

ClawOS Atomic is an agent-addressable desktop built around strict separation of
responsibilities. The host should be stable and rollbackable, agents should be
useful but constrained, and host mutation should be explicit, typed, audited,
and reversible where possible.

## Layer Model

```text
User surfaces
  Claw Shell, command bar, side panel, chat, voice, web, mobile

OpenClaw user runtime
  agents, sessions, tools, skills, plugins, memory, model routing

Model routing and context filtering
  local/remote models, redaction, consent, DLP, routing policy

claw-policy-center
  approvals, grants, tenants, profiles, audit, admin/user policy

claw-portals
  D-Bus host capability brokers, dry-run, rollback, native APIs

OpenShell
  sandboxed execution, workspaces, network policy, credentials, resources

Desktop/app integration
  xdg-desktop-portal, Flatpak, GNOME/KDE adapters, app intents

Atomic host
  Fedora Atomic / bootc, systemd, SELinux, PolicyKit, Flatpak, Podman

Signed image delivery
  CI, SBOM, signatures, staged rollout, rollback archives
```

## Responsibility Split

```text
OpenClaw
  User interaction and agent control plane.

OpenShell
  Sandboxed command execution and disposable compute.

claw-portals
  Typed host capability brokers over native Fedora/Linux APIs.

claw-policy-center
  User/admin policy, approval, audit, tenant mapping, and enforcement outputs.

Fedora Atomic / bootc
  Immutable host substrate, rollback, system services, and image delivery.
```

## Default Request Paths

Sandboxed execution:

```text
User request
  -> OpenClaw plan
  -> OpenClaw tool policy
  -> claw-policy-center decision
  -> OpenShell profile and sandbox policy
  -> sandboxed execution
  -> result, diff, artifact, or proposed host action
```

Host mutation:

```text
User request
  -> OpenClaw plan
  -> claw-policy-center decision
  -> claw-portals operation envelope
  -> native Fedora/Linux API
  -> audited result and rollback metadata
```

## Core Design Rules

- If the task is "run code," use OpenShell.
- If the task is "change the OS," use `claw-portals`.
- If the task is risky, `claw-policy-center` must make permission, audit, and
  recovery visible.
- If OpenShell is unavailable, sandboxed execution is blocked rather than
  falling back to host shell.
- If `claw-portals` are unavailable, host mutation through OpenClaw is blocked
  rather than rerouted through raw `exec`.
- Model routing is not the enforcement layer. Enforcement belongs to
  OpenShell, `claw-portals`, `claw-policy-center`, SELinux, PolicyKit, systemd,
  and the desktop portal stack.

## Implementation Handoff

Implementation designs should define:

- D-Bus service names, methods, request handles, and error codes.
- OpenShell tenant/profile mapping and lifecycle APIs.
- Policy input/output schemas for OPA/Rego evaluation.
- Audit event schemas and retention behavior.
- Recovery commands for CLI and login/boot recovery surfaces.
