# Model, Memory, And Skills

## Purpose

OpenClaw provides model routing, memory, skills, plugins, tools, channels, and
agent workspaces. ClawOS turns those into OS-integrated capabilities with
policy, provenance, and local-first defaults.

## Model Routing

Model routing decides which model may see which context. It is not the primary
enforcement layer.

Model routing should account for:

- Local vs remote model providers.
- Enterprise-approved vs public-cloud providers.
- Data classes and DLP rules.
- Redaction requirements.
- User/admin consent.
- Offline availability.
- Cost, latency, and hardware capability.

Enforcement remains in:

- OpenShell sandbox and network policy.
- `claw-portals`.
- `claw-policy-center`.
- OpenClaw tool policy.
- SELinux, PolicyKit, systemd, Flatpak, and desktop portals.

## Personal Context Store

Memory should be an inspectable OS feature, not a hidden vector database.

Candidate layout:

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

- Local-first unless explicitly configured otherwise.
- Every memory item has provenance.
- Sensitive sources are opt-in.
- Deleting source data can invalidate derived memory.
- Users can inspect why the agent knows something.
- Users can forget data by source, folder, app, project, or time range.
- OpenShell execution history and portal host actions are separate event
  streams.

## Data Labels And DLP

Labels should attach to data objects and provenance, not only raw files.

Data labels may attach to:

- Workspace objects.
- Document handles.
- Clipboard captures.
- Screen/OCR captures.
- Selected text.
- Browser snippets.
- Memory entries.
- Tool inputs/outputs.
- Model context chunks.
- Export artifacts.

Classification priority:

```text
explicit labels
  > source-derived labels
  > admin/user rules
  > pattern detectors
  > local classifier suggestions
  > unknown
```

Derived summaries, patches, reports, embeddings, and memory entries inherit
labels from their inputs unless policy explicitly permits downgrading. When
data is combined, labels usually union and the highest-risk label drives
enforcement.

## Skills And Plugins

Skills and plugins are not authority. They are packages that may request
authority.

A skill should declare:

- Required OpenShell profile.
- Workspace access needs.
- Network destinations.
- Credential classes.
- Portal capabilities.
- Model/context requirements.
- Data handling expectations.
- Audit expectations.

`claw-policy-center` grants, records, displays, and revokes lasting authority.
No skill, plugin, model provider, channel, or agent session should be able to
create lasting authority on its own.

## Open Design Work

- Define personal context store schema.
- Define memory provenance and deletion behavior.
- Define data label schema and inheritance rules.
- Define skill/plugin permission manifest schema.
- Define model routing policy input/output.
- Define redaction and consent UX.
