# ClawOS Architecture

This directory holds the deeper architecture material for ClawOS Atomic. The
top-level README is intentionally short; these documents are the working space
for implementation detail, subsystem design, and handoff-ready technical plans.

## Document Map

| Document | Purpose |
|---|---|
| [system-architecture.md](system-architecture.md) | Overall layer model, trust boundaries, and data paths |
| [host-image-release.md](host-image-release.md) | Fedora Atomic / bootc image design, release, rollback, and sandbox images |
| [openshell-execution.md](openshell-execution.md) | OpenShell gateway, tenants, profiles, workspaces, and execution boundaries |
| [portals-and-policy.md](portals-and-policy.md) | `claw-portals`, `claw-policy-center`, OPA/Rego, PolicyKit, and rollback envelopes |
| [desktop-integration.md](desktop-integration.md) | FreeDesktop, Flatpak, GNOME/KDE adapters, app intents, accessibility, OCR |
| [model-memory-skills.md](model-memory-skills.md) | Model routing, memory, personal context, skills, plugins, and trust packaging |
| [security-model.md](security-model.md) | Security principles, prohibited actions, audit, rollback, and break-glass |
| [enterprise-mode.md](enterprise-mode.md) | SSO, managed policy, provider restrictions, DLP, audit export |
| [implementation-roadmap.md](implementation-roadmap.md) | MVP path and implementation sequencing |
| [design-decisions.md](design-decisions.md) | Settled architectural decisions from the design pass |
| [source-links.md](source-links.md) | Source and reference links |

## Editing Guidance

- Keep product overview material in the top-level README.
- Put subsystem details, interface sketches, policy examples, and unresolved
  implementation questions in this directory.
- Prefer stable design decisions over speculative implementation churn.
- Mark open questions explicitly so they can be resolved into decisions later.
- When a subsystem becomes implementation-ready, add concrete interfaces,
  file paths, service names, policy schemas, and acceptance criteria.
