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

## Artifact roles and evidence boundaries

Documentation is not limited to Markdown. These roles explain how to read the tree; they do not change task eligibility, licenses, captured results or release authority.

- **Current first-party guidance:** root guides, nested feature guides, [engineering](engineering/), [deployment](deployment/), [ADRs](adr/) and [store maintenance](store_listing/README.md). Resolve SDK versions through the [toolchain pin](../fdroid/flutter.version), commands/safety through the [root agent contract](../AGENTS.md), dependencies/assets through [pubspec.yaml](../pubspec.yaml) and its lockfile, and product/platform/UX status through the [current PRD](../PRD.md). A plan is not implementation; implementation is not target qualification or release inclusion.
- **Generated guidance and package/platform outputs:** generated directory inventories in nested agent files and [AI_RULES.md](../AI_RULES.md) retain old layout/count/API examples, not current instructions. Applicable manual safety notes still apply. [Development's retained agent template](engineering/development/CLAUDE.md) is not installed tooling. Generated localization/bridge/platform registrants under `lib/`, [packages/](../packages/) and platform directories belong to their source manifests/generators, not a separate documentation product. Do not hand-edit outputs to fix prose drift.
- **Dated plans and research:** [planning/](planning/), [superpowers/](superpowers/), [analysis/](analysis/), [opensource_audits/](opensource_audits/), [research/](research/), top-level [research/](../research/) and [open-source extractions](../opensource/) include proposals, generated reports, raw `.txt`/JSON/JSONL/CSV exports and citation metadata. “Complete”, benchmark figures and upstream capability descriptions apply only to their stated source/date/method; undated or unbound reports carry no current endorsement. They are not app-support promises, source/rights approval or mathematical certification. Use the [Reference Corpus provenance workflow](../opensource/docs/reference-corpus-workflow.md) before reuse. Upstream clones are local-only, not tracked vendored documentation.
- **Retained evidence and task history:** [qa/](qa/), [task reports](tasks/), release `PLAY_*`/`ALL_PLATFORMS_*` receipts, [tasks/evidence/](../tasks/evidence/), [migration fixtures](../migration/), local [issue records](../issues/), [BLOCKERS.md](../BLOCKERS.md), [CHECKLIST.md](../CHECKLIST.md), [changelog](../CHANGELOG.md) and the [archive](../todo.archive.md) retain historical decisions, commands, paths, warnings, logs, screenshots and failures. Their raw payloads, signed receipts and provenance must not be rewritten into passing/current evidence. A missing historical scratch path is not a new current entry point. Maintained QA playbooks must link to today's source and [verification owner](engineering/test-plan.md); retained gesture/AR designs do not supersede current controls or permissions.
- **Public metadata and media:** [web HTML](../web/landing.html), [web privacy policy](../web/privacy-policy.html), [localized store JSON](play-store-localized-listings.json), store `.txt` files and Fastlane copies are documentary surfaces. [Store copy maintenance](store_listing/README.md#copy-maintenance) owns generated mirrors; [capture provenance](store_listing/screenshot_captures.json) owns screenshot derivation. Old screenshots and `docs/assets/` media are dated illustrations, not current-layout or platform-parity evidence. Flutter's `web/index.html` is a build template: `$FLUTTER_BASE_HREF` and `flutter_bootstrap.js` are supplied by the build, not missing tracked guide files.
- **Not documentation:** application/test code, shaders, executable scripts, build/CI configuration, lockfiles and app resources remain source inputs even when they contain comments or use `.txt`/JSON/YAML. The reference-only Dart definitions under `research/fractals-library/categories/` are research material, not shipped modules. Legal/license/NOTICE text is preserved without editorial changes. No tracked PDF/RST/AsciiDoc guides were present in this sweep; do not infer their absence from a Markdown-only search.

Local path/fragment checks resolve relative to each source page with case sensitivity. Fenced code, literal former queue names and deliberate provenance placeholders are examples/history, not navigation. External URLs require separate checks: a local link pass does not prove remote availability, permissions, device behavior or every external claim. An HTTP error or untested external URL must be reported separately from a missing local target. No device, live publishing or exhaustive external-URL verification is implied by this index.
