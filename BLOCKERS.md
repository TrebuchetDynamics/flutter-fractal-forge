# BLOCKERS

This file contains only hard blockers that require user action.

## Active

### BLK-20261005-004 — Confirm the active product-scope document

- Status: ACTIVE
- Category: USER_DECISION
- Owner: user
- Task/Card: DOC-PRD-001
- Blocked scope: Final reconciliation of product requirements shared by root `PRD.md` and `docs/planning/PRD.md`
- Why blocked: The root PRD states MVP requirements that `TODO.md` calls deferred or that current product support no longer treats as MVP (for example short-video export and iOS release). The planning PRD is a dated readiness snapshot, not an explicit superseding decision.
- Evidence: `PRD.md` sections 2, 7 and 13; `TODO.md` OUT OF SCOPE and P2-5; `docs/planning/PRD.md` historical audit header.
- User action required: Which source states active product scope: A) root `PRD.md` remains the approved baseline and `TODO.md` records deferred items, or B) the active backlog/README supersedes conflicting root-PRD items?
- Default if no answer: B, treat the root PRD's conflicting unimplemented items as historical until revalidated; do not add product scope.
- Proceeding with: Default B applied, pending answer. New docs describe observed architecture and tests only; no feature scope was changed.
- Asked: Telegram cron report, 2026-10-05
- Resume condition: Record which document owns active scope, then reconcile requirements and goal tasks without changing implementation.
- Created: 2026-10-05T20:35:25-06:00
- Last checked: 2026-10-05T20:35:25-06:00

### BLK-20261005-003 — Choose which viewer actions remain directly visible

- Status: ACTIVE
- Category: USER_DECISION
- Owner: user
- Task/Card: t_4fdf9ad0
- Blocked scope: Final action hierarchy for the viewer overflow menu
- Why blocked: Run 270 found existing viewer-controls tests treat looper, Fourier, and report as direct-access controls, while the proposed overflow grouping moves them. The worker reverted its incomplete attempt.
- Evidence: `hermes kanban runs t_4fdf9ad0 --json` reports run 270 blocked; existing viewer-control widget tests include keyboard, semantics, and viewport checks; card contract names a conservative default grouping.
- User action required: Choose A) move export/share, looper, Fourier, wallpaper, and report into overflow while keeping core navigation/randomization/color controls direct, or B) keep looper, Fourier, and report directly visible and move only export/share and wallpaper.
- Default if no answer: B, preserve looper/Fourier/report direct-access guarantees and move only export/share and wallpaper into overflow. Run 299 identified explicit compact-size and keyboard/screen-reader guarantees, so this is the smaller evidence-backed interpretation of the original preserve-primary contract.
- Proceeding with: Default B applied, pending answer. After run 299 re-raised the hierarchy question, fleet governor replaced current guidance and resumed the original card using triage_resume.py. The project worker owns the secondary-only menu implementation; existing primary keyboard, semantics, viewport and callback coverage stays intact. No rendering, publication or external action changes.
- Asked: Telegram cron report, 2026-10-05
- Resume condition: Apply the selected grouping when the original viewer-menu card can be resumed without overlapping work.
- Created: 2026-10-05
- Last checked: 2026-10-05

### BLK-20261005-005 — Confirm the two Explore catalog groups

- Status: ACTIVE
- Category: USER_DECISION
- Owner: user
- Task/Card: t_9e78cf82
- Blocked scope: Final exact-coverage denominator for the VIS-005 Explore inventory
- Why blocked: The task contract asks for both Explore groups, but no project document names them. `CatalogRepository` exposes `CatalogFamily.core` and `PerformanceFractalCatalog`; the worker requested confirmation before treating these as the two groups.
- Evidence: `lib/features/catalog/data/catalog_repository.dart:19-50`; `CatalogFamily.core` and performance modules; `hermes kanban show t_9e78cf82` and run 305.
- User action required: Should VIS-005 treat the two groups as A) core plus performance catalog families, or B) different groups you intended?
- Default if no answer: A, core plus performance catalog families.
- Proceeding with: Default A applied, pending answer. Fleet governor resumed original t_9e78cf82 with core plus performance as the explicit inventory denominator; prerequisite count repair t_8f16da6f completed with 14 passing tests. No replacement card, rendering change or product expansion.
- Asked: Telegram cron report, 2026-10-05
- Resume condition: Inventory proceeds now on A; if the owner supplies different group names, reconcile the reversible inventory interpretation without changing rendering.
- Created: 2026-10-05T21:22:47-06:00
- Last checked: 2026-10-05T21:22:47-06:00

### BLK-20261007-001 — Confirm the Play production recovery gate

- Status: ACTIVE
- Category: USER_DECISION
- Owner: user
- Task/Card: N/A (direct Play release request)
- Blocked scope: Publishing the prepared 1.1.107 (versionCode 107) bundle as a completed production release
- Why blocked: A completed Play release is a full rollout and cannot be downgraded in place. The prior `production/completed` choice for 1.1.106 is reused as the current target default, but no measurable post-release trigger, observation window, recovery owner, or higher-version hotfix action has been accepted.
- Evidence: Live Android Publisher readback reports production 1.1.106/106 `completed`; uploaded bundles currently top out at code 106. Version metadata commit `e003597b` is pushed to `origin/main`; the signed, bundletool-validated 1.1.107 AAB is at `play-console-upload/release-1.1.107/` with SHA-256 `85f8209d162c32f5b85dbd2dcf91ecbc7520c5f78f7e31298528604d1e96606f`. The direct uploader accepts `completed|draft` and defaults to `internal/draft` (`scripts/build-upload-playstore.sh`). `docs/engineering/runbook.md` states no general client-app rollback procedure is defined.
- User action required: Accept or replace this proposed recovery gate: Android Vitals crash-free users below 99.5% over a 24-hour window during the first seven days after publication; Juan Tamez owns recovery and publishes a corrected 1.1.108/code108 with `PLAY_TRACK=production PLAY_RELEASE_STATUS=completed ./scripts/build-upload-playstore.sh --build-name 1.1.108 --build-number 108` after the hotfix is tested.
- Default if no answer: Recommend the gate above and production/completed as the full-rollout target; no reply is not publication approval, so keep the signed AAB local without a Play upload.
- Proceeding with: Release metadata commit `e003597b` is pushed to `origin/main`; signed 1.1.107 AAB is validated and available locally. No Play upload or production edit has been made.
- Asked: Telegram DM, 2026-10-07; clarification timed out unanswered (no publication approval inferred)
- Resume condition: Owner accepts the gate or provides a measurable alternative, recovery owner, and exact higher-version recovery command.
- Created: 2026-10-07T04:52:54-06:00
- Last checked: 2026-10-07T05:58:54-06:00

## Resolved

### BLK-20261005-002 — Approve focused visual verification

- Status: RESOLVED
- Category: USER_DECISION
- Resolved: 2026-10-05T17:55:42-06:00
- Resolution: Owner approved narrow formula-preserving corrections and focused regression/GPU verification, and chose preserving each fractal's established formula while tuning defaults/rendering and fixing implementation bugs.
- Evidence: User answers via native clarification; `test/modules/module_registry_widget_test.dart`; `test/shaders/escape_time_family/families/nova_shader_assets_test.dart`; `integration_test/catalog/generate_gpu_thumbnails_test.dart`; real-GPU captures under `build/test_output/nova-convergence-regression-green/` and `build/test_output/newton-z3-initial-default-after-fix/`.

### BLK-20261005-001 — Admit launcher repair and a new media capture

- Status: RESOLVED
- Category: USER_DECISION
- Resolved: 2026-10-05T14:55Z
- Resolution: Owner authorized the launcher define-forwarding repair and recapture during the 2026-10-05 fleet audit. The restriction was agent-written card scope, which is not a valid user blocker under the updated hard-blockers policy. Work routed to t_8b02fb11.
- Evidence: t_8b02fb11; scripts/capture-launch-media.sh:33 lacks --dart-define=FORCE_GPU_RENDER=true.

> <details><summary>Original entry</summary>
>
> #### Original active record (BLK-20261005-001)
>
> - Former status: ACTIVE
> - Category: USER_DECISION
> - Impact: SCOPE_BLOCKING
> - Owner: user
> - Task/Card: t_b4e2f5ad
> - Blocked scope: MEDIA-001 application-GPU and nine-image qualification
> - Why blocked: Original contract permits one exact capture then read-only diagnosis; it prohibits launcher/source edits and capture reruns. Run141 diagnosed the omitted FORCE_GPU_RENDER define selecting the integration black placeholder. GPU prerequisites do not authorize changing that fixed scope.
> - Evidence: Original t_b4e2f5ad title/body and run141; scripts/capture-launch-media.sh; lib/core/services/platform/runtime_mode_service.dart:47-71; renderer placeholder at FractalRenderer:383-391. Nine black 320x320 captures, not media acceptance.
> - User action required: Authorize a narrowly bounded launcher define-forwarding repair and one fresh MEDIA-001 capture on the original card, retaining the nine-image quality gates and no publication/deployment.
> - Resume condition: Scope is explicitly admitted; the project profile can repair launcher forwarding, verify application GPU use and run the capture without changing or weakening original qualification criteria.
> - Created: 2026-10-05T12:12:31.155457+00:00
> - Last checked: 2026-10-05T13:06:07Z
> - Reconciliation: Current original card still forbids source edits and capture reruns. Read-only diagnosis is complete; its done state is not MEDIA-001 qualification. No accepted later scope admission was found. Exact next dependency is launcher define-forwarding repair plus one fresh 320x320 nine-image qualification attempt; existing GPU prerequisites do not authorize it. Other project slices remain available.
>
> </details>
