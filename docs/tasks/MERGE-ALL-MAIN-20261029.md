# Merge current work to main — 2026-10-29

## Scope

The owner requested merging all work to main before continuing the all-platform
release. Publication is paused for this integration. Merge current source rather
than replaying historical feature snapshots over their corrected successors.
No existing worktree, branch, staged change, conflicted merge or private evidence
is deleted or rewritten.

## Included

- Normal three-way merge of local main `27e0c02f` and origin/main `f2e33f28`:
  release/F-Droid/web-response-policy repairs, versioned entrypoints, 1.1.114
  metadata and Linux image fixtures. Both local renderer/camera regressions and
  Android safety documentation are preserved. The merge is `faed5861`.
- Recovered bounded changes from the dirty `improve-v1-20261025` worktree:
  accessibility preference type validation and ordered theme/contrast writes;
  safe loading of wrong-typed presets, renderer preferences and viewer sessions;
  Fourier boundary timeout ownership, abandoning queued attempts and disposing
  images that arrive after the deadline. Current Burning Ship slot migration,
  renderer debug settings and viewer UI remain intact.
- The missing historical appendix from `09a4abee` is retained with an explicit
  reference to its subsequently repaired async navigation hold (`a9d2ed2e`).

## Verification and provenance

Private execution records: `.git/merge-all-main-20261029/` in the repository's
common Git directory. They are local evidence, not source or release receipts.

- The initial merged tree passed the unchanged full offline gate: Flutter 3.44.6,
  Dart 3.12.2, lock-enforced offline dependencies, clean analysis, 3,126 Flutter
  passes / 8 skips, 454 Python passes / 1 skip / 148 subtest passes, 25 Bats passes.
- Recovered preference tests first reproduced wrong-type failures. After adding
  forwarding getters to the delayed preferences fixture, four real async ordering
  regressions failed independently of mock API assumptions. Recovered production
  fixes then passed all 72 focused preference tests.
- The original viewer boundary capture algorithm was extracted without its fix:
  the recovered Fourier tests reproduced a late-image leak and a queued capture
  starting after timeout (two failures, five passes). With the recovered helper,
  all seven capture cases and 208 viewer widget cases passed (215 total).
- Final combined unchanged offline gate: **exit 0**; clean analysis; **3,162
  Flutter tests passed / 8 skipped**, **454 Python tests passed / 1 skipped /
  148 subtests passed**, **25 Bats tests passed**. Pinned SDK and enforced offline
  lock preflight were revalidated; `pubspec.lock` remained unchanged. Records:
  `final-full-check.log` and `final-full-check.exit`.
- Fresh-context independent review found no critical, important or minor scoped
  defects and independently reran all **79** recovered preference/capture tests.
  No rollback guarantee for failed preference writes or broader preference-key
  hardening is claimed. Review did not qualify devices, browsers or publication.
- The final report-only update records those observed results; no executable
  input changed after the combined gate. Canonical integration and push are
  separate operations, verified by the executing session's final Git readback.

## Preserved exclusions

These are explicit integration limits, not deleted work or passing checks:

- Historical EXPORT, Gaussian walking/growth, Number Walls, quaternion walking,
  sine sphere, visual audit, Android safety and refactor-plan branch tips have
  patch-equivalent or corrected successors already on main. Replaying their full
  snapshots would restore older behavior or evidence claims. Linux fixture branch
  `99953c5f` is included through origin/main.
- Earlier release 111/112 metadata is superseded by 114. Their Play record already
  exists; do not downgrade identity or duplicate a consumed publication.
- Dirty quaternion-drag and CAT-QUALITY trajectory copies are already represented
  by newer source. Old toolbar/impeccable copies would reintroduce removed music
  and outdated controls. The visual probe uses a developer-local font and is
  explicitly temporary, not a deliverable.
- `improve-v1-20261025` Number Walls indicator/header UI work still requires a
  transplant onto the current viewer plus layout/render/semantics verification;
  its whole old viewer cannot safely be copied. It remains untouched locally.
- `viewer-mobile-ui-integration-20261028` browser test edits still expect the
  obsolete Fractal Music action and lack current browser proof. Preserve for a
  separate selector/journey reconciliation, not as passing live evidence.
- `ship-min-tests-20261026` and the matching improve-v1 deletion batch remove Julia
  semantic coverage not replaced by the new manifest assertions. Preserve the
  staged files; no tests are deleted by this integration.
- ACAD-013/014 set-aside worktrees contain unresolved merge entries; older
  academic, planning and prototype worktrees retain unverified or superseded
  overlays. No conflicted index is adopted or resolved on another writer's behalf.
- `.pi-subagents` transcripts, generated artifacts, credentials and temporary
  probes are excluded from source delivery.

## Release boundary

New merged source needs fresh source-bound artifacts and qualification; the old
114 campaign must not be repinned. Waydroid's existing designation remains valid,
but its current ADB/network failure requires administrator diagnostics. Linux
human image review, Windows/Apple native hosts and signing/store requirements,
F-Droid Android qualification/maintainer acceptance, and web hardware-browser and
exact production readback gates remain separate. No publication follows from
passing this offline integration gate alone.
