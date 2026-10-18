# BLOCKERS

This file contains only hard blockers that require user action.

## Active

<!-- pi-autowork:questions:start -->

### Q-NUM-WALL-02 — USER_INPUT — effort input — unblocks 3

- Task: NUM-WALL-02 — Open real Number Walls from their catalog category with restorable controls.
- Needs: worker reported a blocker: Provide MarkupSafe in the provisioned Python environment to allow the required research/script pytest collection and execution. (+1 more in report.json)
- Since: 2026-10-18T23:40:01Z
- Answer: Answer in NUM-WALL-02's TODO.md entry: widen `Touches:`, supply the input, narrow the acceptance, or add a dated `Owner decision:` line. The runner reruns it when the entry changes.

### Q-APP-001-47 — USER_DECISION — effort investigate — unblocks 4

- Task: APP-001-47 — Qualify the official local MCP inspection workflow.
- Needs: report.json does not match worker commit/files or reports failure: a check did not pass
- Since: 2026-10-18T21:07:19Z
- Answer: Read the evidence (the worker's report and validation log under .git/autowork-execution/slot-data/APP-001-47/), then rescope or split APP-001-47 in its TODO.md entry. The runner reruns it when the entry changes.

### Q-SINEWARP-001-aa — USER_DECISION — effort investigate — unblocks 1

- Task: SINEWARP-001-aa — Implement the bounded recursive sine-warped sphere.
- Needs: report.json does not match worker commit/files or reports failure: a check did not pass
- Since: 2026-10-18T22:21:26Z
- Answer: Read the evidence (the worker's report and validation log under .git/autowork-execution/slot-data/SINEWARP-001-aa/), then rescope or split SINEWARP-001-aa in its TODO.md entry. The runner reruns it when the entry changes.

### Q-ACAD-007-f8 — USER_DECISION — effort investigate — unblocks 0

- Task: ACAD-007-f8 — Prepare a verified academic pilot approval brief.
- Needs: report.json does not match worker commit/files or reports failure: a check did not pass
- Since: 2026-10-18T21:01:46Z
- Answer: Read the evidence (the worker's report and validation log under .git/autowork-execution/slot-data/ACAD-007-f8/), then rescope or split ACAD-007-f8 in its TODO.md entry. The runner reruns it when the entry changes.

### Q-RELEASE-002-75 — USER_DECISION — effort investigate — unblocks 0

- Task: RELEASE-002-75 — Prepare and qualify every available platform without publication.
- Needs: worker timeout after 5400 s while running (1 min): export PATH="$AUTOWORK_CACHE/flutter-3.44.6/bin:$PATH" PUB_CACHE="$AUTOWORK_CACHE/pub-cache" TMPDIR="$TMPDIR" PYTHONPATH
- Since: 2026-10-18T21:31:58Z
- Answer: Read the evidence (the worker's report and validation log under .git/autowork-execution/slot-data/RELEASE-002-75/), then rescope or split RELEASE-002-75 in its TODO.md entry. The runner reruns it when the entry changes.

<!-- pi-autowork:questions:end -->

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

## Resolved

### BLK-20261005-004 — Confirm the active product-scope document

- Status: RESOLVED
- Category: USER_DECISION
- Resolved: 2026-10-11
- Resolution: Owner selected B in the repository interview: the current backlog/README governs active product scope. Conflicting older PRD requirements remain historical or deferred. The accepted Android/web/Linux journey and explicit classifications are recorded in `PRD.md#active-release-contract`.
- Owner: user
- Task/Card: DOC-PRD-001
- Blocked scope: Final reconciliation of product requirements shared by root `PRD.md` and `docs/planning/PRD.md`
- Why blocked: The root PRD states MVP requirements that `TODO.md` calls deferred or that current product support no longer treats as MVP (for example short-video export and iOS release). The planning PRD is a dated readiness snapshot, not an explicit superseding decision.
- Evidence: `PRD.md` sections 2, 7 and 13; `TODO.md` OUT OF SCOPE and P2-5; `docs/planning/PRD.md` historical audit header.
- User action required: Which source states active product scope: A) root `PRD.md` remains the approved baseline and `TODO.md` records deferred items, or B) the active backlog/README supersedes conflicting root-PRD items?
- Default if no answer: B, treat the root PRD's conflicting unimplemented items as historical until revalidated; do not add product scope.
- Proceeding with: Explicit owner choice B replaces the provisional default. DOC-PRD-001 reconciles the affected documents. New release qualification remains planned, not verified.
- Asked: Telegram cron report, 2026-10-05
- Resume condition: Record which document owns active scope, then reconcile requirements and goal tasks without changing implementation.
- Created: 2026-10-05T20:35:25-06:00
- Last checked: 2026-10-11

### BLK-20261008-001 — Pin down the incorrect 3D control behavior

- Status: RESOLVED
- Category: USER_INPUT
- Resolved: 2026-10-08
- Resolution: User clarified that 3D rotation and panning felt wrong. Added viewport-relative orbit sensitivity, screen-relative camera-target pan, and pan-target wiring for every registered 3D module.
- Evidence: `test/fractal/fractal_renderer_gesture_test.dart` covers portrait-axis orbit/pan scaling, two-finger pan without tilt/zoom, and rotated-camera pan. `test/modules/mandelbulb_shared_pan_target_test.dart` verifies custom uniform bindings and pan use across registered 3D shaders. Targeted tests passed; full `flutter test --concurrency=2 --reporter compact` passed 2,562 tests with 8 skipped; `flutter analyze` reported no issues.

### BLK-20261007-001 — Confirm the Play production recovery gate

- Status: RESOLVED
- Category: USER_DECISION
- Resolved: 2026-10-07
- Resolution: Owner accepted the proposed recovery gate for Play 1.1.107/code107: monitor Android Vitals crash-free users for the first seven days; if any 24-hour window falls below 99.5%, Juan Tamez publishes tested hotfix 1.1.108/code108 to production/completed using `PLAY_TRACK=production PLAY_RELEASE_STATUS=completed ./scripts/build-upload-playstore.sh --build-name 1.1.108 --build-number 108`.
- Evidence: Telegram clarification response: “Accept the proposed gate.” The signed AAB SHA-256 `41ed401f63380dd4d84b44ca8539a7124daf1fe6e3d201d68ecbbf8aa3083468` was uploaded; receipt `play-console-upload/release-1.1.107-main-7ede1242/play-publication-receipt.json` records edit `18271163851051330565` and `postCommitVerified: true`. Fresh Android Publisher readback confirms production versionCode 107 `completed` and the en-US release note is present; readback evidence is in `play-console-upload/release-1.1.107-main-7ede1242/release-notes-readback.json`.

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
