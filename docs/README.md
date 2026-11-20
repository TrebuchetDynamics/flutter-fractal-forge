# Flutter Fractal Forge docs

Start with the [current product contract](../PRD.md), [workflow queues and history](#queues-and-history), or [development setup](engineering/development/DEVELOPMENT.md) depending on the task. The root PRD owns current product decisions; planning snapshots do not supersede it or establish current qualification.

The documentation tree is organized by responsibility:

- `planning/` — historical PRDs, roadmap, launch ladder, pipeline snapshots, and status notes.
- `engineering/` — development setup, renderer decisions, performance, GPU/emulator, and build-size notes, grouped by responsibility.
- [`engineering/release/`](engineering/release/) — release runbooks, evidence, handoff, manifest artifacts, SBOM, checksums, and provenance.
- `analysis/` — fractal technique, Giulia, and open-source renderer research.
- `qa/` — accessibility, playtesting, gestures, and UI/UX capture artifacts.
- `deployment/` — deployment runbooks for website/web-preview hosting.
- `store_listing/` — Play Store metadata, checklists, privacy policy, and screenshots.
- `catalog/` — fractal registry source data.
- `opensource_audits/` — harvested formula/audit packs.
- `superpowers/` — pipeline plans and specs.

## Queues and history

These are distinct workflows, not one shared queue:

- **GitHub issues / Orbi delivery:** use [repository issues](https://github.com/TrebuchetDynamics/flutter-fractal-forge/issues) for issue scope, decisions and acceptance; Orbi delivers that issue through its task branch and PR. An issue delivery does not change Autowork task eligibility.
- **Scoped Autowork work:** use [task items](../tasks/items/) and [goals](../tasks/goals/) for that workflow's contracts, status and ownership. Follow the [queue handoff runbook](engineering/runbook.md#queue-and-retained-check-handoff); read current records and source-bound evidence rather than infer admission from a documentation link.
- **Historical archive:** [todo.archive.md](../todo.archive.md) preserves dated task bodies and provenance. It is not an execution queue and does not establish current eligibility. Literal `TODO.md` / `goals.json` references in retained history name the former files; do not recreate them or treat them as today's queue.

## Dated planning and other entry points

- [Historical readiness PRD](planning/PRD.md) — February 2026 audit with dated later annotations, not the current product contract.
- [Pipeline state — 2026-04-12](planning/PIPELINE_STATE.md) — the 357-renderable / 370-entry inventory is historical, not today's catalog count.
- [Launch ladder](planning/LAUNCH_LADDER.md) — planning context, not a passing release gate.
- [Web preview hosting](deployment/WEB_PREVIEW_GITHUB_PAGES.md) — deployment guidance, not publication authority.
