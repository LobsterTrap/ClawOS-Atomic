# ClawOS Atomic

ClawOS Atomic is a Fedora Atomic-derived desktop concept where OpenClaw is
the primary user interface, OpenShell is the default sandboxed execution
substrate, and host changes flow through typed, policy-controlled portals.

The operating system should feel like a personal appliance:

> The OS is immutable and boring.
> The agent is expressive and helpful.
> Execution is sandboxed.
> Host control is typed, audited, permissioned, and reversible.

## Value Proposition

ClawOS is not "Fedora plus an AI assistant." It is an agent-addressable
desktop that keeps the agent away from ambient root authority.

It is designed to provide:

- **Safe agent execution:** agent commands run in OpenShell sandboxes by
  default, not on the host shell.
- **Typed host mutation:** OS updates, app installs, network changes, secrets,
  devices, screen capture, and policy changes go through `claw-portals`.
- **User-visible control:** `claw-policy-center` shows grants, denials,
  approvals, audit records, rollback options, and active sandboxes.
- **Rollback-aware operations:** mutating host actions carry dry-run,
  approval, audit, and recovery metadata.
- **Local-first personal computing:** basic sandboxed tasks work without a
  remote execution account or cloud model dependency.
- **Enterprise-ready governance:** model providers, remote execution, DLP,
  audit export, SSO, and managed policy can be centrally controlled.

## System Overview

```text
User surfaces
  Claw Shell, command bar, desktop panel, chat, voice, web, mobile
        |
OpenClaw user runtime
  agents, sessions, tools, skills, plugins, memory, model routing
        |
claw-policy-center
  grants, approvals, tenants, profile assignment, audit, admin policy
        |
+--------------------------+---------------------------+
| OpenShell                | claw-portals              |
| sandboxed execution     | typed host capabilities   |
| workspaces, profiles    | updates, apps, network,   |
| network, credentials    | secrets, devices, desktop |
+--------------------------+---------------------------+
        |
Fedora Atomic / bootc host
  signed image, systemd, SELinux, PolicyKit, Flatpak, rollback
```

The core split is:

```text
OpenClaw = user interaction and agent control plane
OpenShell = sandboxed execution data plane
claw-portals = typed host capability brokers
claw-policy-center = user/admin policy, approval, audit, and tenant mapping
Fedora Atomic / bootc = immutable, rollbackable host substrate
```

## Trust Boundaries

ClawOS separates "run code" from "change the computer."

If the task is to run code, build software, analyze data, browse untrusted
content, or produce files inside an approved workspace, it should happen inside
OpenShell.

If the task changes host state, grants new authority, observes protected
desktop data, touches devices, exports data, affects another user, or needs
OS-level privileges, it must go through `claw-portals` and
`claw-policy-center`.

The agent should not obtain unrestricted host shell access as a normal
workflow. Human-owner/admin break-glass access can exist, but it must be
explicit, authenticated, logged, visually distinct, and outside the normal
agent tool surface.

## Primary Components

### OpenClaw

OpenClaw is the primary user-facing shell and agent runtime. It owns sessions,
plans, tool calls, skills, plugins, model routing, memory, and the desktop
interaction model.

The desktop experience centers on an `Ask / Do / Find / Change` command bar,
task cards, approval cards, audit visibility, and clear state indicators such
as "Acting in OpenShell" or "Waiting for portal approval."

### OpenShell

OpenShell is the default execution environment for agent commands. ClawOS
should run a system-level OpenShell gateway as a dedicated non-root `openshell`
system user, backed by rootless Podman and mapped to local users through
OpenShell tenants managed by `claw-policy-center`.

Project sandboxes use persistent workspaces with disposable compute by default:
workspace state persists, while runtime containers are recreated from known
profiles and images.

### `claw-portals`

`claw-portals` expose host capabilities as typed D-Bus APIs. They should follow
the xdg-desktop-portal pattern for request mediation while following Cockpit's
discipline of wrapping native Fedora/Linux APIs instead of replacing them.

Mutating portal operations use a common operation envelope with dry-run,
approval, audit, and rollback metadata.

### `claw-policy-center`

`claw-policy-center` is the policy and approval surface. It owns user/admin
grants, OpenShell tenant and profile mapping, approval state, OPA/Rego policy
evaluation, audit records, DLP decisions, and generated enforcement state.

Admin policy sets ceilings. User policy sets preferences and narrower grants
inside those ceilings.

### Atomic Host

The host should be small, signed, reproducible, and rollbackable. Host contents
are limited to the base OS, drivers, system services, OpenClaw/OpenShell
integration, `claw-portals`, `claw-policy-center`, recovery tools, and the
desktop integration layer. Apps and tools should live in Flatpaks, containers,
OpenShell sandboxes, or user-space packages unless they truly belong on the
host image.

## User Experience

First boot should ask:

> What do you want this computer to help you do?

The user chooses modes such as personal productivity, software development,
creative work, research, gaming, accessibility-first computing, family/shared
machine, home lab, or enterprise-managed workstation.

OpenClaw configures apps, Flatpaks, OpenShell profiles, model providers,
privacy posture, policy defaults, skill packs, and update behavior from that
intent.

The normal desktop still exists. GNOME/KDE apps, browser, files, settings,
terminal, and accessibility tools remain usable even when the agent stack is
unavailable.

## Delivery Model

ClawOS should be delivered as a Fedora Atomic / bootc-derived signed OCI image
with staged rollout channels, SBOMs, rollback archives, and rebase-friendly
delivery.

OpenShell sandbox images are ClawOS-curated trusted defaults. Project
Hummingbird images should be the preferred base catalog or direct runtime
source where appropriate, with thin ClawOS-derived images when OpenShell needs
agent-specific integration.

## Local Development

Use the top-level `Makefile` for early MVP 0 image tasks:

- `make image-base-inspect` inspects the configured Fedora bootc base image.
- `make image-build` builds the local developer preview image.
- `make image-inspect` inspects the locally built image.
- `make verify` runs lightweight repository checks.

## Architecture Docs

Detailed design work lives under [`docs/architecture/`](docs/architecture/):

- [Architecture index](docs/architecture/README.md)
- [System architecture](docs/architecture/system-architecture.md)
- [Host image and release](docs/architecture/host-image-release.md)
- [OpenShell execution](docs/architecture/openshell-execution.md)
- [Portals and policy](docs/architecture/portals-and-policy.md)
- [Desktop integration](docs/architecture/desktop-integration.md)
- [Model, memory, and skills](docs/architecture/model-memory-skills.md)
- [Security model](docs/architecture/security-model.md)
- [Enterprise mode](docs/architecture/enterprise-mode.md)
- [Implementation roadmap](docs/architecture/implementation-roadmap.md)
- [Design decisions](docs/architecture/design-decisions.md)
- [Source links](docs/architecture/source-links.md)

## Implementation Plans

Implementation-ready subsystem plans live under
[`docs/implementation/`](docs/implementation/):

- [Implementation index](docs/implementation/README.md)
- [MVP 0: Developer preview image](docs/implementation/mvp-0-developer-preview-image.md)
- [MVP 1: OpenShell-first execution](docs/implementation/mvp-1-openshell-first-execution.md)
- [MVP 2: Agent portals](docs/implementation/mvp-2-agent-portals.md)
- [MVP 3: Policy center](docs/implementation/mvp-3-policy-center.md)
- [MVP 4: Desktop integration](docs/implementation/mvp-4-desktop-integration.md)
- [MVP 5: Managed workstation mode](docs/implementation/mvp-5-managed-workstation-mode.md)
- [Cross-cutting verification](docs/implementation/cross-cutting-verification.md)

## Current Status

The resumable project handoff lives in
[`docs/status/current.md`](docs/status/current.md).

## Status

This repository currently captures the product and architecture direction for
ClawOS Atomic. The architecture docs define the target system, and the
implementation plans scaffold concrete subsystem work into MVP-sized handoffs.
