# ClawOS Atomic

## Designing an Agentic Fedora Atomic / Universal Blue–Style Operating System Integrated with OpenClaw and OpenShell

### Revision note

This revision incorporates a clear separation between three responsibilities:

1. **OpenClaw** as the agent-facing user interface, gateway, runtime, skills/plugins system, memory layer, and task orchestration surface.
2. **OpenShell** as the default sandboxed execution substrate for agent command execution, coding tasks, data work, and untrusted automation.
3. **`claw-portals`** and **`claw-policy-center`** as Fedora/Linux-native OS integration layers for safe host mutation, permission management, audit, rollback, and user/admin control.

---

## Core thesis

This should **not** be designed as “Fedora plus an AI assistant.”

It should be designed as an **image-based, rollbackable, policy-mediated personal appliance where the primary shell is OpenClaw**.

> The OS is immutable and boring. 
> The agent is expressive and helpful. 
> The execution environment is sandboxed. 
> The host control plane is typed, audited, permissioned, and reversible.

That last sentence is the whole product.

The refined product thesis is:

> **ClawOS Atomic is a Fedora Atomic-derived, bootable-container desktop where OpenClaw is the primary user interface, OpenShell is the default agent execution substrate, and every meaningful host action flows through typed Fedora-native portals governed by a user-visible policy center.**

---

## Grounding assumptions

Fedora Atomic Desktop gives us the model of an image-based desktop with atomic updates and rollback semantics. rpm-ostree’s documentation describes transactional image-based upgrades, OS rollback, and client-side package layering, while also noting that future bootable-container work is shifting toward bootc and related tooling.

Universal Blue gives us the practical delivery pattern: Fedora Atomic-derived base images, enhanced hardware support, OCI images, signed images, rollback archives, container-focused workflows, and GitHub/Containerfile-style derivation.

bootc gives the next-generation substrate: transactional in-place OS updates using OCI/Docker container images, where the bootable image includes the kernel and systemd still runs as PID 1 on the host.

OpenClaw, as documented today, is a self-hosted gateway that connects chat/channel surfaces to agent runtimes, sessions, tools, memory, plugins, and multi-agent routing. It already treats tools, skills, plugins, channels, and agent workspaces as first-class concepts.

OpenShell provides the sandboxed execution substrate. It should be treated as the safe execution data plane for agents: a managed sandbox layer with policy controls over file access, network access, credentials, and runtime isolation.

So the deliverable should be:

> A Fedora Atomic / bootc-derived desktop image where OpenClaw is the default user interface, OpenShell is the default execution substrate, and every meaningful host action flows through OS-native capability brokers instead of raw shell access.

---

# 1. Product vision

The first boot experience would not ask:

> “Which apps do you want installed?”

It would ask:

> **“What do you want this computer to help you do?”**

The user would pick modes:

- Personal productivity
- Software development
- Creative work
- Home lab / infrastructure
- Gaming
- Research
- Accessibility-first computing
- Family/shared machine
- Enterprise-managed workstation

From that, OpenClaw configures the environment:

- Apps
- Flatpaks
- Dev containers
- OpenShell sandbox profiles
- OpenShell workspace policy
- Channels
- Model providers
- Skill packs
- Update policy
- Privacy posture
- Automation rules
- `claw-portals` host capability grants
- `claw-policy-center` approval defaults

The desktop would still have GNOME/KDE apps, a browser, terminal, files, settings, and accessibility tools. But the **primary interaction surface** would be OpenClaw:

- A persistent command bar: **Ask / Do / Find / Change**
- A side panel with current tasks
- A canvas for plans, files, diffs, screenshots, and approvals
- Action cards instead of raw chat bubbles
- A system tray presence indicator:
  - Idle
  - Observing
  - Planning
  - Waiting for approval
  - Acting in OpenShell
  - Acting through `claw-portals`
  - Blocked by policy
- Voice and mobile chat channels as equal peers to the desktop UI

The goal is not to replace the GUI. The goal is to make the GUI and the operating system **agent-addressable without making the agent all-powerful**.

---

# 2. Architecture

The system should be split into eight layers.

```text
┌────────────────────────────────────────────────────┐
│ User surfaces                                      │
│ Claw Shell, chat, voice, web UI, mobile            │
├────────────────────────────────────────────────────┤
│ OpenClaw user runtime                              │
│ agents, sessions, memory, skills, tools, plugins   │
├────────────────────────────────────────────────────┤
│ claw-policy-center                                 │
│ approvals, permissions, audit, admin policy, UX    │
├────────────────────────────────────────────────────┤
│ Host capability layer: claw-portals                │
│ D-Bus, portals, PolicyKit, systemd, audit, rollback│
├────────────────────────────────────────────────────┤
│ Sandboxed execution substrate: OpenShell           │
│ agent sandboxes, workspace policy, network policy  │
├────────────────────────────────────────────────────┤
│ Desktop/app integration layer                      │
│ Flatpak, xdg portals, app intents, accessibility   │
├────────────────────────────────────────────────────┤
│ Atomic host layer                                  │
│ Fedora Atomic, bootc/rpm-ostree, systemd, SELinux  │
├────────────────────────────────────────────────────┤
│ Signed OCI image delivery                          │
│ CI, SBOM, signatures, staged rollout               │
└────────────────────────────────────────────────────┘
```

The core architectural separation is:

```text
OpenClaw = agent control plane and user interaction layer
OpenShell = sandboxed command execution substrate
claw-portals = typed OS host capability brokers
claw-policy-center = user/admin policy, audit, and approval UX
Fedora Atomic / bootc = immutable, rollbackable host substrate
```

---

## Layer 1: Atomic host

The base OS should be small, predictable, and hard to drift.

Start from a Fedora bootc / Fedora Atomic Desktop-style image, then derive the product image the Universal Blue way:

- Containerfile-based builds
- CI
- Signed OCI images
- Reproducible image promotion
- Rebase-friendly delivery
- Staged rollout channels
- Rollback archive strategy

Host contents should include only things that must be on the host:

- Kernel, firmware, drivers
- systemd
- SELinux
- NetworkManager
- PipeWire
- xdg-desktop-portal
- Desktop shell integration
- OpenClaw system integration packages
- OpenShell CLI/service integration
- `claw-portals`
- `claw-policy-center`
- Podman / bootc / rpm-ostree tooling
- Hardware enablement
- Accessibility stack
- Recovery tools
- TPM/FIDO2/keyring integration

Everything else should be one of:

- Flatpak
- OpenShell sandbox
- Container
- Dev container
- OpenClaw skill/plugin/extension
- User-space package

The atomic host should be boring by design. The host is not the place for agent improvisation.

---

## Layer 2: OpenClaw as the primary shell

OpenClaw would run in two forms.

### `openclawd-system`

A privileged-but-small system daemon.

It does **not** run arbitrary agent logic.

It exposes narrow host capabilities over D-Bus and coordinates with `claw-portals`, PolicyKit, systemd, and the audit layer.

Examples:

```text
org.claw.OS.Update
org.claw.OS.Rebase
org.claw.OS.Rollback
org.claw.Apps.Install
org.claw.Network.Configure
org.claw.Power.Suspend
org.claw.Secrets.Resolve
org.claw.Audit.Log
org.claw.Policy.Query
org.claw.Policy.RequestGrant
org.claw.OpenShell.CreateSandbox
org.claw.OpenShell.ApplyPolicy
```

### `openclawd-user`

A per-user systemd service.

This runs:

- The OpenClaw gateway
- User agents
- Sessions
- Personal memory
- Desktop UI
- Channels
- Skills
- Plugins
- Tool schemas
- Model routing
- User-level automation

The agent runtime should live in user space. The system daemon should be a boring broker, not the brain.

---

## Layer 3: OpenShell as the sandboxed execution substrate

OpenShell should be the default execution environment for agent commands.

This replaces the earlier speculative `claw-exec` idea.

Do **not** invent a new execution substrate when OpenShell already provides the right conceptual layer:

- Managed agent sandboxes
- Policy-governed workspace access
- Network controls
- Credential protection
- Runtime isolation
- Local or remote execution options
- Agent-oriented sandbox lifecycle
- OpenClaw integration through the OpenShell sandbox plugin

The default execution path should be:

```text
User request
  ↓
OpenClaw plan
  ↓
OpenClaw tool policy
  ↓
OpenShell sandbox policy
  ↓
Sandboxed execution
  ↓
Result, diff, or proposed host action
```

OpenShell is the right place for:

- Coding tasks
- Data analysis
- Build/test loops
- Shell-heavy workflows
- Untrusted research
- Browser automation that should not touch the host directly
- Remote GPU workloads
- Long-running agent tasks
- Experimental skills
- Third-party tools

OpenShell is **not** the right abstraction for every host change. The agent should not update the host OS, mutate NetworkManager, install Flatpaks, or edit system policy by running arbitrary shell commands whenever a typed host capability exists.

The design rule should be:

> If the task is “run code,” use OpenShell.
> If the task is “change the OS,” use `claw-portals`.
> If the task is risky, `claw-policy-center` must make the permission and rollback story visible.

### Default OpenShell profiles

ClawOS should ship curated OpenShell profiles:

```text
personal-safe
  - read approved folders only
  - no host secrets
  - network ask/allowlist
  - ephemeral by default

developer
  - ~/Projects read/write
  - package registries allowed
  - Git remotes allowed
  - persistent workspace optional

developer-gpu
  - developer profile plus GPU access
  - explicit hardware/resource visibility

untrusted-research
  - no home directory access
  - no local network
  - internet allowlist or deny-by-default
  - disposable sandbox

airgapped-local
  - no external network
  - local model only
  - local docs/indexes only

enterprise-managed
  - centrally managed policy
  - audit export
  - restricted model providers
  - approved tools/skills only
```

### Example OpenClaw sandbox default

Conceptually, ClawOS should configure OpenClaw so sandboxing is the default, not an advanced option.

```json
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "all",
        "backend": "openshell",
        "scope": "session",
        "workspaceAccess": "rw"
      }
    }
  }
}
```

The exact schema should follow OpenClaw’s current configuration model, but the product stance is clear: OpenShell should be the normal place where agent execution happens.

---

## Layer 4: `claw-portals` for typed host capabilities

This is the most important OS-specific design element.

Do **not** let the agent’s default path to host mutation be:

```text
LLM → shell → host
```

Instead:

```text
LLM → OpenClaw tool schema → claw-policy-center → claw-portals → host API → audited result
```

`claw-portals` are Fedora/Linux-native host capability brokers. They expose typed operations for actions that should be mediated by the OS rather than improvised through shell commands.

Flatpak portals are the design precedent: applications do not get broad host access by default; they request mediated access to files, devices, screen capture, notifications, and other resources. `claw-portals` apply the same idea to agents.

### Portal families

```text
claw-portal-files
claw-portal-apps
claw-portal-updates
claw-portal-secrets
claw-portal-network
claw-portal-containers
claw-portal-systemd
claw-portal-desktop
claw-portal-hardware
claw-portal-audit
claw-portal-recovery
```

### Example capabilities

| User asks | OpenClaw tool | Portal | Broker behavior |
|---|---|---|---|
| “Update my system tonight” | `os.update.schedule` | `claw-portal-updates` | stages bootc/rpm-ostree update, checks calendar, asks approval for reboot |
| “Install Blender” | `apps.install` | `claw-portal-apps` | prefers Flatpak, shows source and permissions |
| “Clean up downloads” | `files.organize` | `claw-portal-files` | works in user-approved folders only, produces preview diff |
| “Set up a Python dev environment” | `devcontainer.create` | `claw-portal-containers` + OpenShell | creates toolbox/devcontainer/OpenShell profile, not host mutation |
| “Share this file with Sarah” | `share.send` | `claw-portal-files` + channel tool | requires identity, destination, and final approval |
| “Turn on the VPN” | `network.vpn.activate` | `claw-portal-network` | calls NetworkManager through policy |
| “Rollback that bad update” | `os.rollback` | `claw-portal-recovery` | exposes previous deployments and rollback plan |
| “Create a background task” | `systemd.user_service.create` | `claw-portal-systemd` | creates a user service with reviewable unit file and audit entry |
| “Explain why Wi-Fi keeps dropping” | `diagnostics.network.read` | `claw-portal-network` | reads relevant logs/settings without write permission |

### Why not just use OpenShell for these?

OpenShell answers:

> “Where can the agent safely execute commands?”

`claw-portals` answers:

> “How can the agent safely change the host operating system?”

These should be different layers.

Instead of this:

```text
agent → exec("rpm-ostree upgrade")
agent → exec("flatpak install org.blender.Blender")
agent → exec("nmcli connection modify ...")
agent → exec("systemctl --user enable ...")
```

Prefer this:

```text
agent → os.update.stage()
agent → apps.flatpak.install(app_id="org.blender.Blender")
agent → network.vpn.activate(connection="Work VPN")
agent → systemd.user_service.create(unit=...)
```

Typed host capabilities can have:

- Structured arguments
- Predictable side effects
- PolicyKit integration
- Dry-run previews
- Human-readable plans
- Audit events
- Rollback metadata
- Admin policy enforcement
- Better UI affordances
- Safer failure behavior

OpenShell can still be used underneath when the work is genuinely execution-heavy, but not every OS action should be reduced to shell execution.

---

## Layer 5: `claw-policy-center` as the permission, audit, and approval UX

`claw-policy-center` is the user-facing and admin-facing control plane for what OpenClaw, OpenShell, skills, plugins, and portals are allowed to do.

For normal users, settings become less about toggles and more about this question:

> “What am I comfortable letting the agent do?”

For administrators, the question becomes:

> “What classes of agent action are permitted on this fleet, under which identities, through which models, against which data?”

### Policy center surfaces

The policy center should include:

- Current OpenClaw status
- Active agents
- Active OpenShell sandboxes
- Installed skills/plugins
- Granted file scopes
- Granted app scopes
- Model provider policy
- Network policy
- Secret access policy
- External action policy
- Host capability policy
- Approval history
- Audit log
- Rollback/undo center
- Enterprise policy status

### Example permission view

```text
OpenClaw can:
✓ Read ~/Projects
✓ Create OpenShell sandboxes
✓ Run commands inside OpenShell developer profile
✓ Install Flatpaks after approval
✓ Stage OS updates after approval
✓ Draft email
✗ Send email without final approval
✗ Access SSH private keys
✗ Run host shell
✗ Read browser cookies
✗ Access local network from untrusted-research profile
```

### Example active sandbox view

```text
Sandbox: rust-project-agent
Profile: developer
Workspace: ~/Projects/my-rust-app
Filesystem: ~/Projects/my-rust-app rw, ~/Downloads ro, ~/.ssh denied
Network: crates.io allowed, github.com allowed, local network denied
Secrets: none
GPU: no
Lifetime: persistent until project close
Audit: 17 commands, 3 file edits, 0 policy denials
Actions: [Pause] [Inspect] [Revoke network] [Destroy]
```

### Example host action approval card

```text
Action: Stage OS update
Portal: claw-portal-updates
Requested by: OpenClaw system-maintenance skill
Host changes:
- Pull new bootc image
- Stage deployment for next boot
- Pin current deployment for rollback
- Schedule reboot after work hours

Will not:
- Reboot now
- Remove user data
- Change model provider

Risk: Medium
Rollback: Boot previous deployment from boot menu or click Roll Back
Approval: [Allow once] [Always allow maintenance window updates] [Deny]
```

### Policy should span both execution and host mutation

The policy center must make it clear which path the agent is using:

```text
OpenShell path:
  agent runs code in a sandbox
  policy controls filesystem, network, credentials, lifetime, resources

claw-portals path:
  agent requests typed host actions
  policy controls OS mutation, approvals, rollback, audit, admin constraints
```

This distinction should be visible to the user. “Acting in sandbox” and “changing the host” are categorically different states.

---

## Layer 6: OpenClaw-native desktop UX

The desktop should expose state to the agent in structured form.

Not screenshots first. Structured state first.

Likely this will be a GNOME Shell extension or a small set of extensions.

The shell should provide:

```text
current_window
focused_app
open_documents
recent_files
selected_text
clipboard_summary
available_actions
notification_queue
system_health
pending_updates
network_state
active_sandboxes
pending_portal_requests
policy_denials
```

Then the agent can say:

> “You have a LibreOffice document open with unsaved changes. I can summarize it, reformat it, export it, or share it.”

The UI should use **action cards**:

```text
Action: Install OBS Studio
Path: claw-portals → apps.install
Source: Flathub
Permissions: camera, microphone, screen capture
Reason: Needed for your streaming setup
Risk: Medium
Approval: [Allow once] [Always allow from this skill] [Deny]
Rollback: remove Flatpak + revoke portal grants
```

And execution cards:

```text
Action: Run test suite
Path: OpenShell → developer sandbox
Workspace: ~/Projects/my-rust-app
Network: github.com, crates.io
Host changes: none
Approval: not required under current developer profile
```

This is how you make agentic computing comprehensible.

---

## Layer 7: Memory and personal context

OpenClaw already has concepts for:

- Memory search
- Active memory
- Agent workspaces
- Per-agent state
- Multi-agent routing

For an OS, elevate this into a **Personal Context Store**:

```text
~/.local/share/claw/context/
  documents.index
  apps.index
  browser.optin.index
  shell-events.index
  openshell-events.index
  portal-events.index
  tasks.sqlite
  decisions.log
  automations/
  memory/
```

Rules:

- Everything is local-first unless explicitly configured otherwise.
- Everything has provenance.
- Every memory item knows where it came from.
- Sensitive sources are opt-in.
- Deleting source data can invalidate derived memory.
- The user can ask: “Why do you know that?”
- The user can say: “Forget everything from this folder.”
- OpenShell execution history and portal host actions are recorded as separate event streams.

Memory should not be “a magic vector database somewhere.” It should be an inspectable OS feature.

---

## Layer 8: Skills and plugins as packages

OpenClaw already distinguishes tools, skills, and plugins:

- **Tools** are typed actions.
- **Skills** are instruction packs.
- **Plugins** add runtime capabilities such as tools, providers, channels, hooks, and packaged skills.

On this OS, skills/plugins should be treated like installable software.

Each skill/plugin should declare:

```json
{
  "id": "fedora-dev-environment",
  "requires": [
    "files.read:~/Projects",
    "openshell.profile:developer",
    "containers.create",
    "apps.install",
    "network.fetch"
  ],
  "risk": "medium",
  "maintainer": "fedora-claw-sig",
  "signature": "...",
  "sbom": "...",
  "policy": {
    "host_exec": "never",
    "execution": "openshell",
    "openshell_profile": "developer",
    "host_capabilities": [
      "apps.flatpak.install",
      "containers.devcontainer.create"
    ],
    "network": "allowlist",
    "secrets": "none"
  }
}
```

OpenClaw’s plugin manifest model already points in this direction. For the OS, make that stricter:

- Signed plugin bundles
- Capability manifests
- SBOMs
- Reproducible builds where possible
- Separate trust levels:
  - Fedora curated
  - Community
  - Local/dev
- No plugin gets host exec merely by being installed
- No plugin gets OpenShell network access merely by being installed
- No plugin gets `claw-portals` host capabilities merely by being installed

Skills should describe not just what they know how to do, but what they are allowed to touch.

---

## Layer 9: Model routing

The OS should support multiple model modes:

1. **Local tiny model** for command parsing, offline help, and privacy-sensitive classification.
2. **Local capable model** when hardware supports it.
3. **Remote frontier model** for complex work, explicitly configured.
4. **Enterprise model gateway** for managed deployments.

The OS should expose model choice as policy:

```text
Private files: local-only by default
OpenShell execution: local plan + remote reasoning allowed only with redaction
Portal actions: local policy evaluation always required
Email/calendar: user-configurable
Enterprise: admin policy
```

The agent should be able to say:

> “This task requires sending the document contents to your configured remote model. Continue?”

The model layer must not be the enforcement layer. Enforcement belongs to OpenShell, `claw-portals`, and `claw-policy-center`.

Out of the box, we will target Ramalama by default for local model inference.

---

# 3. Security model

This is where an Agentic OS succeeds or fails.

OpenClaw’s security documentation calls out risks around:

- Exec approval drift
- Network exposure
- Browser control exposure
- Local disk hygiene
- Plugins
- Sandbox misconfiguration
- Permissive tool policy

Its secrets documentation also makes a crucial point: SecretRefs help prevent credentials from being persisted in supported config/model surfaces, but they are **not** a process-isolation boundary. Readable plaintext credentials remain readable to an agent with file or shell access.

OpenClaw’s sandbox/tool-policy/elevated model is also an important warning: sandboxing determines where tools run, tool policy determines which tools exist, and elevated mode is an exec escape hatch. Tool policy does not inspect arbitrary side effects inside `exec`.

So the OS security model should be built around seven principles.

---

## Principle 1: No ambient authority

The agent gets no broad ambient access merely because the user is logged in.

It sees:

- A summary of system state
- Approved folders
- Approved apps
- Approved channels
- Approved tools
- Approved memories
- Approved OpenShell profiles
- Approved portal capabilities

It does not automatically get:

- Full home directory
- Browser cookies
- SSH keys
- Password store
- Shell access to the host
- Email send permission
- Calendar write permission
- Root actions
- Local network access
- Arbitrary portal calls

---

## Principle 2: OpenShell for execution, portals for host mutation

The design must preserve a hard conceptual distinction:

```text
OpenShell:
  safe place for agent command execution
  controls filesystem/network/secrets/runtime blast radius

claw-portals:
  safe path for host OS mutation
  controls updates/apps/network/systemd/secrets/recovery

claw-policy-center:
  user/admin visibility, approval, audit, rollback, policy
```

This avoids turning `exec` into the universal control surface.

The dangerous pattern is:

```text
agent → exec("sudo something")
agent → exec("flatpak install ...")
agent → exec("nmcli ...")
agent → exec("systemctl ...")
```

The safer pattern is:

```text
agent → OpenShell for sandboxed work
agent → claw-portals for typed host actions
agent → claw-policy-center for approval and audit
```

---

## Principle 3: Capability tiers

Every action belongs to a tier.

| Tier | Name | Example | Execution path | Approval |
|---|---|---|---|---|
| 0 | Observe | summarize open window | desktop state / portal read | no approval, if source already granted |
| 1 | Draft | write email draft | OpenClaw tool | no send permission |
| 2 | Sandboxed work | run tests, analyze data | OpenShell | profile-dependent |
| 3 | Local modify | rename files in approved folder | portal or OpenShell workspace | scoped approval / preview |
| 4 | External effect | send email, post message, buy ticket | channel/tool portal | explicit approval |
| 5 | System effect | install app, update OS, change network | `claw-portals` | explicit approval |
| 6 | Privileged/destructive | delete many files, wipe disk, alter secrets | portal + strong policy | strong approval + delay |

---

## Principle 4: Human-readable plans before risky actions

For any Tier 4+ action, the agent must produce a plan:

```text
I will:
1. Install OBS Studio from Flathub.
2. Grant camera, microphone, and screen-capture permissions.
3. Create a "Streaming" workspace.
4. Add a launcher to the dock.

I will not:
- Install RPM packages on the host.
- Access your Documents folder.
- Start streaming automatically.

Execution path:
- Host action through claw-portal-apps.
- No OpenShell command execution required.
```

Then the user approves.

---

## Principle 5: Sandboxed execution by default

The default execution environments:

- OpenShell ephemeral sandbox for one-off shell work
- OpenShell persistent sandbox for project work
- OpenShell remote sandbox for heavy or GPU work
- Toolbox/devcontainer for developer workflows where appropriate
- MicroVM for highly untrusted automation
- Flatpak for GUI apps
- Host broker only for narrow OS capabilities

Host exec should be exceptional, logged, revocable, and ideally unnecessary for normal workflows.

---

## Principle 6: Rollback everything possible

The OS should make rollback a core UX feature:

- Roll back OS image
- Roll back app install
- Roll back Flatpak permissions
- Roll back file edits through snapshots/versioning
- Roll back OpenClaw config
- Roll back OpenShell profile changes
- Destroy or revert OpenShell sandboxes
- Roll back skills/plugins
- Roll back automations
- Roll back model/provider changes
- Roll back `claw-portals` grants

Atomic desktops already provide the mental model: the base OS can move between known deployments. An Agentic OS should extend that rollback concept upward into the user experience.

---

## Principle 7: Audit must distinguish sandbox activity from host mutation

The audit log should separate:

```text
OpenClaw reasoning/plans
OpenShell sandbox commands
OpenShell file changes
OpenShell network denials
Portal read requests
Portal write requests
Host mutations
External actions
User approvals
Admin policy decisions
Rollback events
```

A user or admin should be able to ask:

> “What changed on my host?”

and get a different answer from:

> “What did the agent do inside its sandbox?”

That distinction is fundamental.

---

# 4. User experience

## First boot

The installer finishes and boots into a minimal desktop.

Instead of a normal welcome app, the user sees:

> “Welcome to ClawOS Atomic. I can help set up this computer. I’ll ask before changing anything important.”

The setup flow:

1. Choose privacy mode:
   - Local-first
   - Balanced
   - Remote-capable
2. Choose model provider or local model.
3. Pair phone/chat channels, optional.
4. Choose skill packs.
5. Choose default OpenShell profile:
   - Personal safe
   - Developer
   - Untrusted research
   - Enterprise managed
6. Grant source access:
   - Documents
   - Downloads
   - Projects
   - Email
   - Calendar
   - Browser
   - GitHub/GitLab
   - Cloud storage
7. Configure host action policy:
   - App installs
   - OS updates
   - Network changes
   - Secret access
   - External actions
8. Generate first “computer profile”:
   - Preferred apps
   - Update policy
   - Work hours
   - Notification style
   - Automation boundaries
   - OpenShell sandbox lifetime defaults
   - Portal approval defaults

---

## Daily use

The user hits `Super+Space`:

> “Set up a Rust dev environment for my new project.”

OpenClaw responds with an action card:

```text
Plan:
- Create ~/Projects/my-rust-app
- Create an OpenShell developer sandbox bound to that project
- Add rustup, cargo-watch, rust-analyzer inside the sandbox
- Open the project in VS Code or GNOME Builder
- Keep toolchain changes outside the immutable host

Execution path:
- OpenShell developer profile
- claw-portal-files for project folder grant
- claw-portal-desktop to open the editor

Host changes:
- None, unless you approve adding a launcher or installing an editor

Approve?
```

Another example:

> “My Wi-Fi is flaky.”

OpenClaw can inspect logs through a read-only diagnostic broker, summarize likely causes, and offer:

```text
Possible issue: repeated disconnects from power-save mode.
I can try disabling Wi-Fi power saving for this connection.

Execution path:
- Read diagnostics through claw-portal-network
- Write setting through claw-portal-network if approved

Change:
NetworkManager connection setting:
802-11-wireless.powersave = 2

Risk: Low
Rollback: restore previous setting
```

Another example:

> “Update everything, but don’t break my meeting at 2.”

OpenClaw checks calendar, stages updates, delays reboot, and says:

```text
I staged the OS update and 14 Flatpak updates.
No reboot before 3:30 PM.
Rollback deployment will remain pinned for 7 days.

Execution path:
- claw-portal-updates
- claw-portal-apps
- calendar read grant

OpenShell used:
- No
```

Another example:

> “Clone this unfamiliar repo and tell me if it looks safe.”

OpenClaw responds:

```text
I will inspect the repository in an untrusted OpenShell sandbox.

Execution path:
- OpenShell untrusted-research profile

Sandbox policy:
- No home directory access
- No SSH keys
- No local network
- Internet access only to the Git remote and package metadata mirrors
- Disposable after the report

Host changes:
- None
```

---

## The terminal still exists

The agent-native OS should never trap power users.

The user can still open a terminal. But the system nudges toward safer patterns:

- `claw run`
- `claw explain-last-change`
- `claw undo`
- `claw doctor`
- `claw policy`
- `claw audit`
- `claw shell --openshell`
- `claw sandbox list`
- `claw portal list`
- `claw host-shell`

`claw host-shell` should require explicit warning and logging.

A possible CLI model:

```text
claw shell --openshell --profile developer --workspace ~/Projects/app
claw portal request apps.install org.blender.Blender
claw policy explain network.vpn.activate
claw audit host-changes --since yesterday
claw undo last
```

---

# 5. Build and release pipeline

The release pipeline should look more like cloud-native infrastructure than traditional desktop respin work.

```text
Fedora base image
   ↓
ClawOS Containerfile
   ↓
CI build
   ↓
unit/integration tests
   ↓
desktop smoke tests
   ↓
OpenClaw integration tests
   ↓
OpenShell sandbox tests
   ↓
claw-portals capability tests
   ↓
claw-policy-center approval/audit tests
   ↓
security policy tests
   ↓
upgrade and rollback tests
   ↓
SBOM + signature
   ↓
staging image
   ↓
canary users
   ↓
stable image
```

Artifacts:

- `quay.io/clawos/clawos-atomic:stable`
- `quay.io/clawos/clawos-atomic:gts`
- `quay.io/clawos/clawos-atomic:testing`
- `quay.io/clawos/clawos-atomic:nvidia`
- `quay.io/clawos/clawos-atomic:dev`

Editions:

1. **ClawOS Personal** — daily-driver desktop
2. **ClawOS Developer** — OpenShell/dev tools prewired
3. **ClawOS Workstation Managed** — enterprise policy, SSO, MDM hooks
4. **ClawOS Lab** — experimental skills/plugins, not for normal users
5. **ClawOS Recovery** — minimal rescue image with OpenClaw diagnostics and portal-based repair tools

---

# 6. What makes this different from “AI in GNOME” or “Copilot for Linux”?

The difference is that OpenClaw is not just a UI overlay.

It becomes:

- The setup assistant
- The help system
- The settings interface
- The automation engine
- The app launcher
- The system updater
- The troubleshooting interface
- The personal memory layer
- The workflow engine
- The policy explanation layer

But the OS still owns:

- Permissions
- Sandboxing
- Host mutation
- Rollback
- Updates
- Secrets
- Audit
- Identity
- Recovery

And OpenShell owns:

- Sandboxed agent execution
- Filesystem policy inside the sandbox
- Network policy inside the sandbox
- Credential containment
- Sandbox lifecycle
- Remote/local execution environment

The key separation is:

```text
OpenClaw asks and plans.
OpenShell executes untrusted commands.
claw-portals mutate the host through typed APIs.
claw-policy-center mediates trust.
Fedora Atomic makes the host recoverable.
```

That separation is the product.

---

# 7. MVP path

Do not start with “agent controls everything.”

Start with a narrow, excellent vertical slice.

---

## MVP 0: Developer preview image

Base:

- Fedora Atomic / bootc-derived image
- GNOME desktop
- OpenClaw preinstalled
- OpenShell preinstalled and configured
- OpenClaw OpenShell sandbox plugin enabled
- Claw Shell extension
- Per-user OpenClaw service
- Local Control UI
- `claw-policy-center` minimal UI
- Podman/toolbox/devcontainer integration
- Signed image updates
- Rollback exposed in UI

Agent capabilities:

- Read system state
- Explain installed image/version
- Create OpenShell sandboxes
- Run commands only in OpenShell by default
- Stage OS update through portal
- Roll back OS through portal
- Install/remove Flatpaks through portal
- Create dev containers/OpenShell project environments
- Search approved files
- Open apps/files
- Draft but not send messages

No default host shell. No default email sending. No default browser automation.

---

## MVP 1: OpenShell-first execution

Make OpenShell the default execution substrate.

Deliver:

- OpenShell installed in the base image
- OpenClaw OpenShell sandbox plugin configured
- Default profiles:
  - `personal-safe`
  - `developer`
  - `untrusted-research`
- Profile selection in first boot
- Active sandbox list in `claw-policy-center`
- Sandbox lifecycle controls:
  - create
  - pause
  - resume
  - destroy
  - inspect
- Execution audit events:
  - command run
  - file changed
  - network denied
  - secret denied

Success criterion:

> A user can ask OpenClaw to clone, inspect, build, and test a project without mutating the immutable host or exposing unrelated home-directory data.

---

## MVP 2: Agent portals

Build the OS broker layer:

```text
claw-portal-files
claw-portal-apps
claw-portal-updates
claw-portal-secrets
claw-portal-network
claw-portal-containers
claw-portal-systemd
claw-portal-desktop
claw-portal-audit
claw-portal-recovery
```

Expose them to OpenClaw as typed tools.

Success criterion:

> A user can install an app, stage an OS update, roll back a deployment, and change a safe network setting through explicit action cards without giving OpenClaw host shell access.

---

## MVP 3: Policy center

Build a real permissions center:

```text
OpenClaw can:
✓ Read ~/Projects
✓ Create OpenShell sandboxes
✓ Run commands inside OpenShell developer profile
✓ Install Flatpaks after approval
✓ Stage updates after approval
✗ Send email without final approval
✗ Access SSH keys
✗ Run host shell
✗ Read browser cookies
```

Include:

- Active sandbox view
- Portal grants view
- Skill/plugin permissions
- Model provider policy
- Approval history
- Audit log
- Undo/rollback center

Success criterion:

> A non-expert user can understand whether OpenClaw is acting inside a sandbox, changing the host, or waiting for approval.

---

## MVP 4: Skills marketplace

A curated catalog:

- Fedora developer setup
- Python data science
- Home lab assistant
- Podcast production
- Gaming setup
- Accessibility assistant
- Travel planning
- Family tech support
- Incident response workstation

Each skill declares:

- Required OpenShell profile
- Required portal capabilities
- Required data sources
- Required model policy
- External action permissions
- Risk level
- Maintainer
- Signature
- SBOM

Success criterion:

> Installing a skill feels like installing an app with a permission manifest, not like pasting arbitrary instructions into a chatbot.

---

## MVP 5: Managed workstation mode

For enterprise:

- Admin policy
- Fleet image pinning
- Model-provider restrictions
- OpenShell profile restrictions
- Portal capability restrictions
- Audit export
- DLP hooks
- Approved skill catalogs
- No remote models for classified data
- Break-glass recovery

Success criterion:

> An admin can say which agents, models, skills, sandboxes, networks, data sources, and host capabilities are allowed across a fleet.

---

# 8. Repository layout

```text
clawos/
  images/
    base/
      Containerfile
    personal/
      Containerfile
    developer/
      Containerfile
    managed/
      Containerfile

  packages/
    claw-shell/
    claw-control-center/
    claw-policy-center/
    claw-policy-agent/
    claw-portals/
      files/
      apps/
      updates/
      secrets/
      network/
      containers/
      systemd/
      desktop/
      hardware/
      audit/
      recovery/
    openshell-integration/
      profiles/
      policies/
      sandbox-images/
      openclaw-plugin-config/

  openclaw/
    default-config/
    skills/
    plugins/
    policies/
    model-profiles/
    tool-schemas/

  tests/
    os/
    desktop/
    openclaw/
    openshell/
    portals/
    policy/
    upgrade/
    rollback/
    security/

  docs/
    threat-model.md
    capability-model.md
    openshell-integration.md
    portal-design.md
    policy-center.md
    release-process.md
    user-guide.md
```

---

# 9. Biggest technical bets

## Bet 1: OpenShell should be the default execution substrate

Do not compete with OpenShell for sandboxed execution.

Use it.

Make it feel native:

- Preinstall it
- Configure it securely
- Expose it in the policy center
- Ship curated profiles
- Integrate it with OpenClaw skills
- Audit it separately from host mutation
- Make sandbox state visible in the shell

The OS should add value around OpenShell, not replace it.

---

## Bet 2: A typed action layer beats shell automation for host changes

The OS needs to make the safe path easier than `exec`.

OpenClaw tools should prefer:

```text
apps.flatpak.install()
os.update.stage()
os.rollback.preview()
containers.devcontainer.create()
files.patch_with_preview()
desktop.open_document()
network.vpn.activate()
secrets.request()
systemd.user_service.create()
```

over:

```text
run("sudo dnf install ...")
run("rpm-ostree upgrade")
run("flatpak install ...")
run("nmcli connection modify ...")
run("rm -rf ...")
run("curl | bash")
```

---

## Bet 3: The desktop must become introspectable

The agent needs structured desktop state.

That means deeper GNOME/KDE integration:

- Current app/window metadata
- Selected text
- Open document URIs
- Available app actions
- Notification state
- Screen context when explicitly granted
- Accessibility tree access under policy
- Active OpenShell sandboxes
- Pending portal requests
- Recent policy denials

---

## Bet 4: The policy engine is the real shell

For normal users, “settings” becomes:

> “What am I comfortable letting the agent do?”

The permissions center is as important as the app launcher.

The policy engine needs to cover both:

- OpenShell execution policy
- `claw-portals` host capability policy

Without that unified view, users will not understand what the agent can and cannot do.

---

## Bet 5: Rollback must be user-visible

Every action card should answer:

> “How do I undo this?”

If there is no undo path, the system should say so before acting.

Rollback should include:

- Atomic host deployments
- App installs
- Portal grants
- OpenShell sandboxes
- Skill/plugin installs
- OpenClaw configuration
- Automations
- Model/provider changes

---

## Bet 6: Skills must be trustworthy artifacts

An agentic OS without signed, inspectable skills/plugins will become a supply-chain nightmare.

OpenClaw already has plugin manifests and security/audit concepts, but an OS deliverable should harden those into a distribution policy.

A skill should not merely say:

> “I know how to do Rust development.”

It should say:

> “I require the OpenShell developer profile, read/write access to selected project folders, network access to crates.io and GitHub, and optional access to `apps.install` if the editor is missing.”

---

## Bet 7: Host exec should become rare

The system should still have a break-glass host shell.

But host shell execution should be:

- Explicit
- Logged
- Revocable
- Policy-gated
- Unnecessary for common workflows
- Clearly distinguished from OpenShell execution

A healthy ClawOS system should be able to operate for weeks without OpenClaw ever needing host shell access.

---

# 10. Preferred design philosophy

Make the system **tightly integrated but loosely trusted**.

## Tightly integrated

- OpenClaw is everywhere.
- OpenShell is the default execution data plane.
- Every app/action is agent-addressable.
- The OS knows about tasks, plans, memory, sandboxes, portals, and automation.
- The agent can operate the system coherently.

## Loosely trusted

- OpenClaw does not get root by default.
- OpenShell sandboxes do not imply host trust.
- Plugins do not imply permission.
- Skills do not imply portal grants.
- Memory is inspectable.
- Secrets are isolated.
- Host actions require brokers.
- Risky actions require plans.
- Everything meaningful is logged.
- Most things are undoable.

That is the difference between an “agentic OS” and a “dangerous chatbot glued to sudo.”

---

# 11. Revised one-sentence pitch

**ClawOS Atomic is a Fedora Atomic-derived, bootable-container desktop where OpenClaw is the primary user interface, OpenShell is the default sandboxed execution substrate, and Fedora-native `claw-portals` expose host actions as typed, policy-controlled, rollback-aware capabilities governed by `claw-policy-center`.**

---

# 12. Open design questions

These are the areas that would need deeper design before implementation.

## 12.1 OpenShell integration depth

- Should OpenShell run purely as a user-level service, or should ClawOS ship a system-level OpenShell gateway with per-user isolation?
- How should OpenShell profiles map to Linux users, SELinux labels, cgroups, and resource limits?
- Should project sandboxes be disposable by default or persistent by default?
- Should OpenShell sandbox images be built as part of the ClawOS image pipeline or pulled independently?

## 12.2 Portal API design

- Should `claw-portals` use D-Bus APIs modeled after xdg-desktop-portal?
- Should each portal be a separate service or one broker with multiple interfaces?
- How much should portals rely on PolicyKit versus a ClawOS-specific policy engine?
- How should portals expose dry-run, rollback, and audit metadata consistently?

## 12.3 Policy model

- What is the canonical policy language?
- Can OpenShell policy and `claw-portals` policy share a common vocabulary?
- How should user policy and admin policy merge?
- Should policy be declarative and stored in `/etc/claw/policy.d/` plus `~/.config/claw/policy.d/`?

## 12.4 Host mutation boundaries

- Which actions require portals?
- Which actions may happen inside OpenShell?
- Which actions are prohibited entirely?
- How should break-glass host shell work?

## 12.5 Desktop integration

- How much structured context can GNOME/KDE expose safely?
- What is the accessibility boundary?
- How should screen capture and OCR be permissioned?
- Can app intents be standardized across Flatpak apps?

## 12.6 Enterprise mode

- How should the system integrate with SSO, device management, and audit pipelines?
- How should admins restrict model providers and remote execution?
- How should DLP policies interact with OpenShell network policy and OpenClaw tool policy?

---

# Source links

- Fedora rpm-ostree documentation: <https://coreos.github.io/rpm-ostree/>
- Universal Blue documentation: <https://universal-blue.org/>
- bootc documentation: <https://bootc.dev/bootc/>
- OpenClaw documentation: <https://docs.openclaw.ai/>
- OpenClaw tools documentation: <https://docs.openclaw.ai/tools>
- OpenClaw agent workspace concept: <https://docs.openclaw.ai/concepts/agent-workspace>
- OpenClaw active memory concept: <https://docs.openclaw.ai/concepts/active-memory>
- OpenClaw memory config reference: <https://docs.openclaw.ai/reference/memory-config>
- OpenClaw plugin manifest reference: <https://docs.openclaw.ai/plugins/manifest>
- OpenClaw security documentation: <https://docs.openclaw.ai/gateway/security>
- OpenClaw secrets documentation: <https://docs.openclaw.ai/gateway/secrets>
- OpenClaw sandboxing documentation: <https://docs.openclaw.ai/gateway/sandboxing>
- OpenClaw sandbox vs tool policy vs elevated: <https://docs.openclaw.ai/gateway/sandbox-vs-tool-policy-vs-elevated>
- OpenClaw OpenShell gateway documentation: <https://docs.openclaw.ai/gateway/openshell>
- OpenClaw OpenShell plugin reference: <https://docs.openclaw.ai/plugins/reference/openshell>
- NVIDIA OpenShell Developer Guide: <https://docs.nvidia.com/openshell/latest/index.html>
- NVIDIA OpenShell sandbox management: <https://docs.nvidia.com/openshell/sandboxes/manage-sandboxes>
- NVIDIA OpenShell sandbox policy documentation: <https://docs.nvidia.com/openshell/latest/sandboxes/policies.html>
- Flatpak document portal documentation: <https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Documents.html>
