# Flutter Fractal Forge — Execution TODO

[Backlog history](todo.archive.md). Scope authority is resolved; see [the accepted release contract](PRD.md#active-release-contract).

> **Last comprehensive update:** 2026-08-25 recursive-object 3D expansion. Catalog counts below are reconciled to the current integrity test.
>
> **Source anchors for this refresh:** `test/catalog/catalog_id_integrity_test.dart` (543 escape-time entries, 1020 production fractals, 1 scientific visualization, and 1028 debug/test registry modules including 7 diagnostics), `lib/features/viewer/fractal_viewer_screen.dart` (controls HUD), `lib/core/services/rendering/palette_service.dart` + `palette_shader_adapter.dart` (palette textures).

## Now

Owner interview order: **VIEW-UI-01 / VIEW-UI-02 first**, then **CAT-QUALITY-01 → CAT-QUALITY-02**. Primary focus: `VIEW-UI-001`. Preserve existing Gaussian work and active ownership; OpenAI-math additions remain Proposed. Pilot success: attractive defaults, useful controls and matching PNG export without hunting for good settings; mathematical honesty and accessibility remain mandatory. This is planning priority, not new implementation or scheduling authority. See [the recorded decision](PRD.md#quality-first-planning-priority).


- [ ] **VIEW-UI-01 — Make catalog Back compact without weakening navigation accessibility.**
  - Goal: VIEW-UI-001. Payoff: show more artwork without losing discoverable accessible navigation.
  - Sources: [Accepted correction](docs/engineering/spec.md#viewer-chrome-footprint-and-action-consistency), supplied Android screenshot, `lib/features/viewer/fractal_viewer_screen.dart`, `lib/features/viewer/chrome/fractal_view_controls.dart`, `BLOCKERS.md`.
  - Graph evidence: fresh partial seven-file Graphify graph; FractalViewerScreen at viewer_screen:130 and _ViewerOverflowMenu/FloatingActionButtonWidget at view_controls:642,716. Source-corroborated; truncated query and unindexed renderer/theme/service/doc semantics.
  - Scope: Replace the text-heavy persistent pill with a circular arrow; preserve key, tooltip/semantics, direct pop, export disabling, capture suppression and large-target mode. Correct title collisions only; no toolbar regrouping.
  - Progress: Offline implementation committed locally as `81161c13`: circular localized Back, 48/56px targets, Enter activation, direct pop and capture-mode suppression regressions. Complete isolated candidate passed 89 viewer/control tests and `flutter analyze`. Task remains open: same-state before/after screenshots and the full responsive/accessibility matrix are still pending. A follow-up adds actual-viewer regressions for HUD-open direct versus system Back, export-busy disabling, cancellation without route pop and navigation after cancellation; the isolated candidate passes 92 viewer/control tests and analysis with available Flutter 3.44.2 / Dart 3.12.2 (documented Flutter 3.44.6 remains unverified). A deliberately broken callback fails the new HUD/export assertions. Independent review found no blocking issues. Local follow-up `40ed03af` fixes a reproduced left-safe-area violation (Back was at x=12 inside a 16px inset) and adds 128 actual-viewer layout combinations: EN/ES; widths 320/768/1024/1440; portrait/landscape; text scales 1/2; dark/high contrast; 48/56px targets, including asymmetric 44px landscape cutouts. Complete isolated candidate passes 220 viewer/control tests, formatting and analysis on Flutter 3.44.2. Independent review found no blockers; action-collision assertions were strengthened and the full focused union rerun. Same-state screenshots, long-title fixtures and device/rendered acceptance were unverified at that checkpoint. Local follow-up `823ff4dd` adds longest-localized-registry-title fixtures to all 128 layout combinations and corrects their MediaQuery size to match each surface. It reproduces title intrusion into the side cutout and title/action collisions at 320px; the title now sits beside Back above the rail, with safe-area bounds and room for 56px Back targets. The complete isolated candidate passes 220 viewer/control tests, formatting and analysis; independent final review approves the scoped offline fix. Same-state before/after screenshots and device/rendered acceptance remain unverified. No device/GPU acceptance or publication is claimed.
  - Painted fixture evidence: 16 matched before/after widget-chrome capture pairs (32 decoded PNGs) cover EN/ES and widths 320/768/1024/1440 in portrait/default and landscape/enlarged-text/high-contrast/large-target states. Capture-only runs and all 16 measured 48/56px Back targets pass; independent review confirms the narrower Back and title relocation. Roboto is explicitly substituted for unbundled app font families, and the renderer is blank: these are NOT native/device/GPU or production-typography acceptance. Both selective baseline and current 320px portrait captures show right-edge action-rail clipping; keep the task open and investigate bounds without regrouping actions. No application source changed in this verification slice.
  - Rail follow-up: Local commit `d79b2eb0` (not pushed). Actual-viewer bounds assertions reproduced Fourier at right=352px against the 304px safe edge in 320px portrait; the expanded matrix also reproduced bottom=208px against the 184px safe edge in short landscape. Removed the fixed portrait width cap, made the existing rail scrollable without regrouping actions, and included horizontal safe insets. All 128 layout combinations now check every quick action (including overflow and auto-explore) for safe bounds, Back/title separation and hit testing after reveal. A real short-landscape drag exposes the last report action and its tap fires once. The complete isolated candidate passes 221 viewer/control tests, formatting and analysis on Flutter 3.44.2 / Dart 3.12.2; independent final review approves the offline slice. Sixteen matched post-fix widget captures decode against the preceding fixtures; the inspected 320px portrait comparison shows the formerly clipped rightmost controls fully visible. Roboto substitution and blank renderer limitations remain; no native/device/GPU or production-typography acceptance is claimed.
  - Keyboard/semantics follow-up: Added 320×100 logical-pixel landscape regressions that Tab through every available control, automatically reveal each focused target, and activate Report exactly once with Enter. A separate semantics-action test scrolls the clipped Report into view, checks its localized English label/tap action and activates it once; neither traversal nor scrolling fires the callback early. Complete isolated candidate passes 223 viewer/control tests, formatting and analysis on Flutter 3.44.2 / Dart 3.12.2. Independent review approves the test-only slice; disabling rail scrolling makes the new semantics-action assertion fail, and restoring it passes. This proves widget keyboard and semantics plumbing only, not TalkBack/VoiceOver or native typography/GPU acceptance. Application source is unchanged.
  - Current verification: Exact Flutter 3.44.6 / Dart 3.12.2 viewer/control tests now pass within the 247-test home/viewer/coral union. This clears that focused SDK gap, not native/device/GPU or production-font acceptance.
  - Native capture follow-up: `integration_test/screenshots/viewer_chrome_native_test.dart` passes two Linux/Xvfb EN/ES cases in a complete isolated candidate on Flutter 3.44.2 / Dart 3.12.2 with FORCE_GPU_RENDER. Decoded current-state 1280×720 PNGs show the real alternated_iteration shader and readable native font fallback without test font loading/substitution. Locale, localized Back tooltip, 48px Back/overflow targets, hit testing and direct Back navigation pass; full candidate analysis and independent source review pass. This is partial current-state Linux evidence, not a matched historical baseline, full responsive matrix, hardware-GPU or device screen-reader qualification.
  - Native responsive follow-up: Expanded the native harness to 16 EN/ES cases at 320/768/1024/1440 logical widths: portrait/default text/dark and landscape/text scale 2/high contrast/large targets. All 16 Linux/Xvfb tests pass in a complete isolated candidate on Flutter 3.44.2 / Dart 3.12.2; 16 PNGs decode at the asserted viewport dimensions without test-font substitution. Tests check actual MediaQuery size/scale, 48/56px Back and overflow targets, viewport containment, hit testing, non-overlap and direct Back navigation. Both viewer/control files pass (228 tests); full candidate analysis, formatting and independent source review pass. Inspected 320px captures show readable chrome and a real fractal, with the enlarged landscape title ellipsized; this is current-state native raster evidence with synthetic viewport metrics, not historical comparisons, the full accessibility matrix or device/hardware-GPU acceptance. Application source is unchanged.
  - Matched native follow-up: 16 selective historical/current Linux/Xvfb capture pairs (32 decoded PNGs) now cover the preceding EN/ES responsive states. Historical chrome uses both viewer files from `14a9eca4` on the current app; this is not a complete historical build. The harness initializes accessibility before mount on both sides; the failed historical live-toggle attempt remains recorded, not repaired. Current target/tooltip/hit-test/navigation assertions remain intact; old overflow size and tooltip are observations, not accepted current behavior. All 32 capture cases, 228 viewer/control tests, analysis, formatting and independent source review pass on Flutter 3.44.2 / Dart 3.12.2. Measured Back width falls from 157.7–264.6px to 48/56px; inspected 320px comparisons show the title relocation, corrected portrait rail clipping and circular overflow. Native fallback fonts are readable without test substitution; Xvfb uses software llvmpipe. See the [verification frontier](docs/engineering/test-plan.md#current-quality-first-verification-frontier) for exact limitations. Application code is unchanged; full VIEW-UI-01/02 acceptance remains open.
  - Next action: Extend remaining long-title/cutout/native interaction states; qualify actual device screen-reader scrolling in short landscape separately. Preserve remaining device/GPU qualification.
  - Acceptance: Compact arrow surface; target >=48px and >=56px with large targets; no title/safe-area/rail collisions or overflow at required widths/scales. EN/ES, keyboard/focus/high contrast and direct/system Back behaviors pass, including HUD/export/capture states.
  - Checks: add actual-viewer/control RED/GREEN tests in `test/fractal/fractal_viewer_screen_widget_test.dart` and `test/fractal/fractal_view_controls_test.dart`; run both via `flutter test ... --reporter expanded`, formatter and `flutter analyze`. Capture same-state before/after screenshots; test 320/768/1024/1440 logical widths, portrait/landscape, text scale 1/2, long title and accessibility states. Partial execution is recorded under Progress; remaining checks are NOT_RUN.
  - Dependencies: none.
  - Ownership: repository backlog, unassigned; preserve active workers and check live ownership before implementation. Planning does not dispatch.
- [ ] **VIEW-UI-02 — Give the existing overflow menu a matching circular surface.**
  - Current verification: Exact Flutter 3.44.6 viewer/control regressions pass within the 247-test home/viewer/coral union. The implementation is present; native screenshots, production typography and device/screen-reader qualification remain outstanding.
  - Goal: VIEW-UI-001. Payoff: show more artwork without losing discoverable accessible navigation.
  - Sources: [Accepted correction](docs/engineering/spec.md#viewer-chrome-footprint-and-action-consistency), supplied Android screenshot, `lib/features/viewer/fractal_viewer_screen.dart`, `lib/features/viewer/chrome/fractal_view_controls.dart`, `BLOCKERS.md`.
  - Graph evidence: fresh partial seven-file Graphify graph; FractalViewerScreen at viewer_screen:130 and _ViewerOverflowMenu/FloatingActionButtonWidget at view_controls:642,716. Source-corroborated; truncated query and unindexed renderer/theme/service/doc semantics.
  - Scope: Style existing PopupMenuButton only. Preserve menu items, platform wallpaper availability, callbacks, keys, export disabling and traversal. Keep looper/Fourier/report directly accessible; no new actions or dependencies.
  - Progress: Offline implementation committed locally as `06f6ec46` gives the existing popup a circular dark surface, white icon, 48/56px accessibility targets and an explicit focus border. Added EN/ES dark/high-contrast pointer opening, keyboard selection of every action, Escape dismissal and focus-return regressions; Linux omits wallpaper and export-busy cannot open the menu by pointer or Enter. Extended all 128 actual-viewer layout cases to assert the circular 48/56px overflow target. Complete isolated candidate passes 228 viewer/control tests, formatting and analysis on Flutter 3.44.2 / Dart 3.12.2; independent review approves the offline slice. Task stays open: same-state native screenshots, production-font/device screen-reader acceptance and documented Flutter 3.44.6 verification remain unproved. No push or live acceptance is claimed.
  - Acceptance: Circular dark button with consistent enabled/disabled/focus states and accessible target; pointer/keyboard open/select/dismiss work, dismissal restores focus, each action fires once and export-busy cannot invoke it. Required responsive/EN/ES/high-contrast states pass.
  - Checks: actual-viewer/control regressions in `test/fractal/fractal_viewer_screen_widget_test.dart` and `test/fractal/fractal_view_controls_test.dart` pass via `flutter test ... --reporter expanded`; formatter and `flutter analyze` pass. The 128-case matrix covers 320/768/1024/1440 logical widths, portrait/landscape, text scale 1/2, long localized titles and accessibility states. Same-state native before/after screenshots and device checks remain NOT_RUN.
  - Dependencies: none.
  - Ownership: repository backlog, unassigned; preserve active workers and check live ownership before implementation. Planning does not dispatch.

- [ ] **CAT-QUALITY-01 — Assess a family-stratified quality pilot without duplicating capture work.**
  - Goal: CAT-QUALITY-001. Payoff: improve the first experience while preserving mathematical and visual variety.
  - Sources: [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), [accepted outcome](PRD.md#catalog-quality-and-variety), `docs/planning/visual-audit-inventory.json`, `lib/features/catalog/data/catalog_repository.dart`, `lib/core/modules/fractal_mathematics.dart`.
  - Graph evidence: Fresh partial 38-file code-only Graphify scan: CatalogRepository (`catalog_repository.dart:15,20,57`), CatalogEntry (`catalog_entry.dart:12,30`), FractalMathematics (`fractal_mathematics.dart:11,45`) and LaunchVisualMetrics (`launch_visual_metrics.dart:9`). Extracted nodes are source-corroborated; five self-loops/duplicate-label warnings and truncated queries remain. Shaders/viewer/export/docs semantics are not indexed. See the quality plan for queries and receipt path.
  - Scope: Select at most 12 existing IDs spanning complex dynamics/root finding, geometric/IFS, attractors, 3D, tilings and cellular/stochastic systems where available. Reuse Featured Launch Set/VIS-006 evidence. Record exact families/groups, missing evidence and the three highest-impact reproduced defects. No source tuning or UI change in this assessment.
  - Acceptance: Every selected ID has separate framing/readability, identity/disclosure, controls, preview, performance and PNG verdicts with explicit PASS/FAIL/NOT_CHECKED and references. Record absent representatives and distinguish parameter/color variants from distinct systems. Bind three repairs to reproduced defects and a before/after comparison; missing evidence is not a fabricated failure. Proposed rubric remains labeled until adopted.
  - Checks: Validate inventory; reuse applicable named GPU/runtime/first-view tests and REL-JOURNEY artifact receipts. Retain exact commands, backend/device/seed and artifact paths. Run only needed pilot checks; full catalog completion is not required.
  - Dependencies: none.
  - Ownership: Repository backlog, unassigned; verify live ownership. Planning does not dispatch.
- [ ] **REL-JOURNEY-01-WEB — Qualify the complete web image-creation journey.**
  - Goal: REL-JOURNEY-001. Payoff: meet the accepted complete user journey on this platform without false parity claims.
  - Sources: [Accepted release contract](PRD.md#active-release-contract), [Journey verification](docs/engineering/test-plan.md#accepted-cross-platform-release-journey), `docs/engineering/rendering/renderer_backend_matrix.md`, `lib/features/export/export_options_sheet.dart`, and `test/export/viewer_export_session_test.dart`.
  - Graph evidence: fresh partial code-only export graph, `ExportOptionsSheet` → `ExportSheetSubmission` and `ExportOptions` at `export_options_sheet.dart:13,28,46`; `ExportResolutionSummary.fromEffectiveOptions` at `export_resolution_summary.dart:19`. Services, journey tests and doc semantics are unindexed; two self-loops/duplicate-label warnings require source corroboration.
  - Touches: test/playwright/
  - Scope: Extend the existing browser tests to browse/open 2D and 3D examples, customize the actual viewer, inspect current mathematics/qualifications, and download a PNG. Reuse the existing web export path Preserve formulas, IDs, favorites, presets, EN/ES support, preview quality caps and renderer gates. Exclude publication, deployment, historical MVP expansion and other platforms.
  - Acceptance: Both dimensional examples export decodable nonblank PNGs with the selected dimensions and edited state; disclosure is accurate; browser errors and silent placeholder substitutions are absent; saved data remains intact. Record every failure, skip and remaining gap. A build or widget-only pass does not close the task.
  - Checks: `flutter build web --no-pub`; run the existing Playwright runner with the exact added journey target recorded by the worker; retain downloads and decode/compare assertions. Corroborate `test/playwright/smoke-session-conflict.spec.mjs` and relevant export unit/widget tests. The new browser target is planned, not already present.
  - Dependencies: none. Platform slices are independent; no existing active worker is superseded.
  - Ownership: repository backlog, unassigned. Check live ownership before any dispatch.
  - Decision: reuse existing journey/export components and fix only reproduced in-scope defects; no speculative renderer redesign or new dependencies.
  - Skill application: planning-and-task-breakdown, bounded end-to-end slice; frontend-ui-engineering, interaction and saved-state regressions; documentation-and-adrs, distinguish accepted target from observed qualification.

- [ ] **SMOOTH-001-INVENTORY-01 — Reconcile one supported polynomial shader family with smooth-coloring coverage.**
  - Goal: SMOOTH-001. Payoff: replace the premature full-coverage claim with a checked family inventory and one bounded regression slice.
  - Sources: [Existing P1-3 scope](TODO.md#p1-3-smooth-coloring-in-all-shaders), `test/shaders/smooth_coloring_family_coverage_test.dart`, and `docs/engineering/performance/SHADER_OPTIMIZATIONS.md`.
  - Scope: inventory the integer-power Multibrot shaders against their live module bindings and existing source assertions. Confirm formula-appropriate coloring and add the missing d=4 contract assertion. Preserve recurrence, inside-set output, palettes, and existing tests. Do not claim whole-catalog or hardware-GPU qualification.
  - Acceptance: list each applicable family shader and its checked/unverified status; the d=4 shader is represented by a recurrence-appropriate assertion; `flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart` passes. Run targeted formatting and analysis for changed Dart tests. Record remaining uncovered families.
  - Dependencies: none.
  - Ownership: repository backlog; check active work before dispatch.
  - Decision: keep completed sample tests done and add a successor, because fourteen sampled shaders do not prove full applicable coverage.
  - Skill application: planning-and-task-breakdown, bounded family slice with checks; documentation-and-adrs, preserve implemented versus verified status. The missing d=4 assertion check failed during this documentation pass.

- [ ] **VIS-006 — Capture and inspect the next ten uncaptured Explore modules.** Goal: complete the accepted visual playtest audit.
  - Payoff: extend evidence-backed GPU default and runtime-preview coverage while preserving formulas.
  - Scope: select the next ten uncaptured Explore IDs from `docs/planning/visual-audit-inventory.json`; capture true module defaults and runtime previews. Run CPU checks only when a native CPU formula exists. Do not alter formulas, static catalog images, or research-library module support.
  - Sources: [Accepted visual scope](docs/planning/visual-fidelity-audit-next.md#accepted-focus), [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md), [`docs/planning/visual-audit-inventory.json`](docs/planning/visual-audit-inventory.json), and `goals.json`.
  - Acceptance: reconcile selected/generated/failed/skipped counts, record per-ID defaults and image metrics, and validate inventory references.
  - Dependencies: VIS-005 (task and goal prerequisite).
  - Prior evidence: VIS-006-BATCH-01 provides completed prior-batch evidence, not an additional prerequisite.
  - Ownership: repository backlog; currently in_progress. Preserve the active worker and check ownership before dispatch.
  - Goal: VIS-006.

## Next


- [ ] **CAT-QUALITY-02 — Repair three demonstrated pilot first-impression defects.**
  - Goal: CAT-QUALITY-001. Payoff: improve the first experience while preserving mathematical and visual variety.
  - Sources: [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), [accepted outcome](PRD.md#catalog-quality-and-variety), `docs/planning/visual-audit-inventory.json`, `lib/features/catalog/data/catalog_repository.dart`, `lib/core/modules/fractal_mathematics.dart`.
  - Graph evidence: Fresh partial 38-file code-only Graphify scan: CatalogRepository (`catalog_repository.dart:15,20,57`), CatalogEntry (`catalog_entry.dart:12,30`), FractalMathematics (`fractal_mathematics.dart:11,45`) and LaunchVisualMetrics (`launch_visual_metrics.dart:9`). Extracted nodes are source-corroborated; five self-loops/duplicate-label warnings and truncated queries remain. Shaders/viewer/export/docs semantics are not indexed. See the quality plan for queries and receipt path.
  - Scope: Use CAT-QUALITY-01 evidence to tune default framing/presets/palette or fix reproduced rendering/description/control errors for three existing IDs. One independently reversible fix at a time. Preserve formulas unless mathematically demonstrated wrong; preserve IDs, favorites, saved presets, runtime thumbnail policy and bounds. No new fractals/dependencies or blanket shader rewrite.
  - Acceptance: Before/after comparisons at identical settings show each named defect resolved, relevant interaction/identity checks pass and PNG matches the edited view. Report p50/p95 performance without inventing approved thresholds. Unchanged supported IDs and saved-state resolution; no loss of pilot family coverage. Do not count aesthetic improvement as mathematical certification or host-only tests as platform qualification.
  - Checks: Focused RED/GREEN regression for each cause; existing catalog identity/repository/search/a11y tests, formatter, flutter analyze, inventory validation. Run affected GPU capture/first-view and applicable REL-JOURNEY checks separately; record all skips.
  - Dependencies: CAT-QUALITY-01.
  - Ownership: Repository backlog, unassigned; coordinate with existing VIS-006 and formula workers before edits.


- [ ] **GAUSS-MOAT-02-WALK — Validate Gaussian-prime steps and display truthful component state.**
  - Payoff: demonstrate the moat question with truthful path/component/boundary states.
  - Goal: GAUSS-MOAT-001.
  - Sources: [Accepted scope](PRD.md#gaussian-moat-walking-visualization), [bounded design](docs/engineering/spec.md#gaussian-moat-walking-visualization), [verification](docs/engineering/test-plan.md#gaussian-moat-visualization), `lib/core/modules/builders/escape_time_catalog/batch_26_tenth_wave_research.dart`, and `shaders/number_theory/gaussian_prime_lattice_gpu.frag`. [Refined UI/budgets](docs/engineering/spec.md#ui-layout-and-interaction-contract) and [per-task fixture matrix](docs/engineering/test-plan.md#prime-walking-refined-acceptance-matrix).
  - Graph evidence: fresh scoped code-only Graphify graph; `ModuleRegistry` at `lib/core/modules/module_registry.dart:64`, `FractalRenderer` at `lib/features/renderer/widgets/renderer/fractal_renderer.dart:107`, and `FractalCanvas` at `lib/features/renderer/widgets/canvas/fractal_canvas.dart:6`. Extracted `FractalCanvas` inherits `CustomPainter`. Queries: `ModuleRegistry buildEscapeTimeCatalogModules FractalModule`, `FractalViewerScreen FractalRenderer FractalCanvas`, `_wrapWithGestures _onJuliaDualTap FractalCanvas`. Coverage is partial: 272 copied Dart files; shaders, docs, external proofs and controller semantics were read separately. The graph has 20 self-loops and duplicate-label normalization warnings; source corroboration governs behavior claims.
  - Ownership: repository backlog, unassigned. Check live ownership before dispatch. This planning pass dispatches no implementation worker.
  - Touches: lib/core/models/gaussian_moat_model.dart, lib/features/viewer/gaussian_moat_map.dart, lib/features/viewer/gaussian_moat_plot.dart, lib/features/viewer/fractal_viewer_screen.dart, lib/l10n/, test/modules/gaussian_moat_model_test.dart, test/features/viewer/gaussian_moat_walk_test.dart
  - Scope: inclusive integer-squared step adjacency, nonrepeating manual path, undo/reset, full-component overlay, conservative search-boundary status, stale-result handling and capture inclusion. Keep transient history outside saved shader uniforms. No longest-path optimization, autoplay, infinite search or proof certificate.
  - Acceptance: candidate selection alone never moves; inclusive 1+i → 1-i fixture accepts k=4 and rejects k=3; invalid/repeated/outside moves leave history intact; undo/reset and keyboard/list alternative work; B=1 components match independent k=2/k=4 expectations with truncated status. Stale work cannot publish and a completed-state PNG contains the enabled overlays.
  - Checks: add/run `flutter test test/modules/gaussian_moat_model_test.dart test/features/viewer/gaussian_moat_walk_test.dart --reporter expanded`; run affected gesture/export regressions and `flutter analyze`; decode an actual representative PNG before claiming capture inclusion. New tests and PNG evidence remain planned.
  - UI/performance: follow the shared HUD/panel layout, preview-then-Step interaction, visible bounded-state labels, hard workload caps, cooperative chunks and completed-snapshot capture. This is planned acceptance, not a measured pass.
  - Dependencies: GAUSS-MOAT-01-MAP.
  - Decision: bounded neighbor offsets instead of all-pairs edges; component search independent of path history; place overlays inside the real capture boundary or explicitly explain unsupported combinations.
  - Skill application: planning-and-task-breakdown, bounded interaction slice; frontend-ui-engineering, semantics, transforms and capture; documentation-and-adrs, finite search is not theorem verification.

- [ ] **GAUSS-MOAT-04-GROWTH — Scrub and animate jump-radius growth without queued or stale computations.**
  - Goal: GAUSS-MOAT-001. Payoff: show changing connectivity without suggesting a finite plot proves the theorem.
  - Sources: [Accepted Gaussian scope](PRD.md#gaussian-moat-walking-visualization), [accepted growth plan](docs/engineering/spec.md#gaussian-moat-walking-visualization), [growth details](docs/engineering/spec.md#bounded-radius-growth-and-visual-direction), and [verification](docs/engineering/test-plan.md#prime-walking-growth-and-quaternion-slice-checks). [Refined UI/budgets](docs/engineering/spec.md#ui-layout-and-interaction-contract) and [per-task fixture matrix](docs/engineering/test-plan.md#prime-walking-refined-acceptance-matrix).
  - Graph evidence: existing `FractalViewState`/viewer/canvas nodes from the scoped code-only graph; animation behavior is not established by graph edges. Corroborate existing viewer lifecycle and capture source. Self-loop/duplicate-label warnings and shader/doc gaps remain.
  - Scope: manual scrub and bounded play/pause of squared jump distance, legal-move/path edges, selected-prime component accent and domain-limit feedback. Preserve fixed computation bounds; clear path state when radius changes; reject stale recomputations and respect reduced motion. Exclude autonomous walker AI, unlimited search, dense all-pairs meshes and theorem certificates.
  - Acceptance: controlled slow-job/clock tests prove one active job plus one latest replacement input, no tick backlog, at least 500ms completed-state dwell, commit-on-release scrubbing, monotone components, maximum stop and cancellation on pause/navigation/background/export. Reduced motion blocks play; snapshot identity remains consistent.
  - Checks: extend/run `flutter test test/modules/gaussian_moat_model_test.dart test/features/viewer/gaussian_moat_walk_test.dart --reporter expanded`; formatter/analyzer; real journey and decoded PNG checks in GAUSS-MOAT-03-QUALIFY. Feature tests remain planned.
  - UI/performance: follow the shared HUD/panel layout, preview-then-Step interaction, visible bounded-state labels, hard workload caps, cooperative chunks and completed-snapshot capture. This is planned acceptance, not a measured pass.
  - Dependencies: GAUSS-MOAT-02-WALK.
  - Ownership: repository backlog, unassigned; check live ownership before dispatch.
  - Decision: bounded integer-squared radius schedule, not continuous approximate adjacency or unbounded domain expansion.
  - Skill application: frontend-ui-engineering, motion/cancellation and non-color-only states; planning-and-task-breakdown, bounded growth slice; documentation-and-adrs, visualization is not proof.

- [ ] **GAUSS-MOAT-03-QUALIFY — Qualify accessible Gaussian walking and frozen-state PNG export on all three targets.**
  - Payoff: prove usable, accessible exploration and accurate PNG output on the supported targets.
  - Goal: GAUSS-MOAT-001.
  - Sources: [Accepted scope](PRD.md#gaussian-moat-walking-visualization), [bounded design](docs/engineering/spec.md#gaussian-moat-walking-visualization), [verification](docs/engineering/test-plan.md#gaussian-moat-visualization), `lib/core/modules/builders/escape_time_catalog/batch_26_tenth_wave_research.dart`, and `shaders/number_theory/gaussian_prime_lattice_gpu.frag`. [Refined UI/budgets](docs/engineering/spec.md#ui-layout-and-interaction-contract) and [per-task fixture matrix](docs/engineering/test-plan.md#prime-walking-refined-acceptance-matrix).
  - Graph evidence: fresh scoped code-only Graphify graph; `ModuleRegistry` at `lib/core/modules/module_registry.dart:64`, `FractalRenderer` at `lib/features/renderer/widgets/renderer/fractal_renderer.dart:107`, and `FractalCanvas` at `lib/features/renderer/widgets/canvas/fractal_canvas.dart:6`. Extracted `FractalCanvas` inherits `CustomPainter`. Queries: `ModuleRegistry buildEscapeTimeCatalogModules FractalModule`, `FractalViewerScreen FractalRenderer FractalCanvas`, `_wrapWithGestures _onJuliaDualTap FractalCanvas`. Coverage is partial: 272 copied Dart files; shaders, docs, external proofs and controller semantics were read separately. The graph has 20 self-loops and duplicate-label normalization warnings; source corroboration governs behavior claims.
  - Ownership: repository backlog, unassigned. Check live ownership before dispatch. This planning pass dispatches no implementation worker.
  - Scope: actual catalog-to-walk-to-component-to-export journey; EN/ES explanations and source attribution, narrow/enlarged-text and keyboard/semantics checks, capped computation measurements and navigation cancellation. Preserve favorites/presets and other module behavior. No store publication, Lean rebuilding or all-catalog certification.
  - Acceptance: record complete Gaussian journey and decoded selected-dimension paused PNGs on named Android/web/Linux targets; check 48px action targets, widths 320/768/1024/1440, text scales 1/2, EN/ES, keyboard/focus and boundary states. Record cap/chunk/job telemetry and real timing/memory separately, with device gaps/skips explicit; no fabricated performance or physical-device pass.
  - Checks: create/run `integration_test/flows/gaussian_moat_journey_test.dart` on named Linux/Android targets; extend the existing production-build Playwright runner and record/run its actual target; run `flutter analyze`, focused model/widget tests, existing viewer/export regressions. Planned commands and performance measurements are defined in the linked verification plan, not reported as executed.
  - UI/performance: follow the shared HUD/panel layout, preview-then-Step interaction, visible bounded-state labels, hard workload caps, cooperative chunks and completed-snapshot capture. This is planned acceptance, not a measured pass.
  - Dependencies: GAUSS-MOAT-02-WALK, GAUSS-MOAT-04-GROWTH.
  - Decision: qualify native, browser and exported artifacts separately; attribute external proof reports without claiming independent theorem verification.
  - Skill application: frontend-ui-engineering, responsive/localized accessible journey; planning-and-task-breakdown, dependent live qualification; documentation-and-adrs, observed evidence versus planned checks.


- [ ] **QUAT-NORM-01-SLICE — Open a bounded fixed-d prime-norm quaternion view with deterministic picking.**
  - Goal: QUAT-NORM-001. Payoff: teach integer quaternion norms with a correctly labeled 3D view.
  - Sources: [Accepted companion](PRD.md#prime-norm-quaternion-companion), [accepted slice design](docs/engineering/spec.md#prime-norm-quaternion-companion), [planned checks](docs/engineering/test-plan.md#prime-walking-growth-and-quaternion-slice-checks), and `lib/core/modules/fractals/quaternion_julia_3d_module.dart`. [Refined UI/budgets](docs/engineering/spec.md#ui-layout-and-interaction-contract) and [per-task fixture matrix](docs/engineering/test-plan.md#prime-walking-refined-acceptance-matrix).
  - Graph evidence: the fresh partial code-only graph contains `FractalViewState` at `lib/core/models/fractal_view_state.dart:22` and `quaternion_julia_3d_module.dart`; quaternion query was truncated. Source at `lib/core/modules/fractals/quaternion_julia_3d_module.dart:37–42` confirms a Julia shader, not prime walking. No complete quaternion UI graph or proof semantics are claimed; existing self-loop/duplicate-label warnings remain.
  - Ownership: repository backlog, unassigned; check live ownership before dispatch. No implementation worker is started by this plan.
  - Touches: lib/core/models/prime_norm_quaternion_model.dart, lib/features/viewer/prime_norm_quaternion_slice.dart, lib/features/viewer/gaussian_moat_map.dart, lib/features/viewer/fractal_viewer_screen.dart, lib/l10n/app_*.arb, lib/l10n/app_localizations*.dart, test/modules/prime_norm_quaternion_test.dart, test/features/viewer/prime_norm_quaternion_slice_test.dart
  - Scope: bounded fixed-d integer points and norm predicate, rotatable `(a,b,c)` projection, companion access from the Gaussian-prime experience and truthful slice/domain/legend labels. Reuse the checked ordinary-prime provider, local view conventions and existing dependencies. Preserve Julia/Mandelbrot modules. Exclude full 4D enumeration, Hurwitz half-integers, quaternion factorization or a new rendering framework.
  - Acceptance: independent prime/composite norm, bounds and signed fixed-d fixtures pass; orthographic projection and deterministic screen-distance/depth/coordinate picking plus list alternative pass; rotation preserves model identities. Correctly labeled companion UI fits the shared responsive contract and respects the smaller workload caps/chunks.
  - Checks: create/run `flutter test test/modules/prime_norm_quaternion_test.dart --reporter expanded`; relevant registry/viewer regressions; targeted formatter and `flutter analyze`. New test files and 3D render checks remain planned.
  - UI/performance: follow the shared HUD/panel layout, preview-then-Step interaction, visible bounded-state labels, hard workload caps, cooperative chunks and completed-snapshot capture. This is planned acceptance, not a measured pass.
  - Dependencies: GAUSS-MOAT-01-MAP.
  - Decision: fixed-d induced slice before full 4D graphs; no false certified-prime label or reused Julia shader as an oracle.
  - Skill application: spec-driven-development, precise predicate/slice contract; frontend-ui-engineering, projection and explicit legend; planning-and-task-breakdown, bounded first slice.

- [ ] **QUAT-NORM-02-WALK — Walk in the quaternion slice with camera-independent adjacency and captured overlays.**
  - Goal: QUAT-NORM-001. Payoff: compare bounded walking with the Gaussian example without conflating slice and 4D connectivity.
  - Sources: [Accepted companion](PRD.md#prime-norm-quaternion-companion), [accepted slice design](docs/engineering/spec.md#prime-norm-quaternion-companion), [planned checks](docs/engineering/test-plan.md#prime-walking-growth-and-quaternion-slice-checks), and `lib/core/modules/fractals/quaternion_julia_3d_module.dart`. [Refined UI/budgets](docs/engineering/spec.md#ui-layout-and-interaction-contract) and [per-task fixture matrix](docs/engineering/test-plan.md#prime-walking-refined-acceptance-matrix).
  - Graph evidence: the fresh partial code-only graph contains `FractalViewState` at `lib/core/models/fractal_view_state.dart:22` and `quaternion_julia_3d_module.dart`; quaternion query was truncated. Source at `lib/core/modules/fractals/quaternion_julia_3d_module.dart:37–42` confirms a Julia shader, not prime walking. No complete quaternion UI graph or proof semantics are claimed; existing self-loop/duplicate-label warnings remain.
  - Ownership: repository backlog, unassigned; check live ownership before dispatch. No implementation worker is started by this plan.
  - Scope: inclusive original-coordinate adjacency, nonrepeating path/undo/reset, independently computed slice component, norm coloring and aligned capture. Reuse checked walk/capture behavior where compatible, with dimension-specific model/transform code. Handle depth overlap and coordinate-list selection. Exclude hidden cross-slice edges, generic n-dimensional framework, full 4D searches or moat theorem claims.
  - Acceptance: original-coordinate fixture (1,1,0,0) → (1,0,1,0) accepts k=2 and rejects k=1 independently of camera; selection does not commit; repeats/cross-slice steps fail; camera drags never select; slice changes reset/revalidate/cancel. Components/capture match the completed fixed-d snapshot and boundary status, with no full-4D claim.
  - Checks: create/run `flutter test test/modules/prime_norm_quaternion_test.dart test/features/viewer/prime_norm_quaternion_walk_test.dart --reporter expanded`; targeted formatter/analyzer, affected gesture/export regressions and decoded representative PNG. Feature evidence remains unrun.
  - UI/performance: follow the shared HUD/panel layout, preview-then-Step interaction, visible bounded-state labels, hard workload caps, cooperative chunks and completed-snapshot capture. This is planned acceptance, not a measured pass.
  - Dependencies: QUAT-NORM-01-SLICE, GAUSS-MOAT-02-WALK.
  - Decision: adjacency uses the fixed-d 4D squared metric, never screen distance; component is independent of visited path.
  - Skill application: frontend-ui-engineering, picking/semantics/export; planning-and-task-breakdown, explicit provider dependencies; documentation-and-adrs, distinguish induced slice from 4D graph.

- [ ] **QUAT-NORM-03-QUALIFY — Qualify accessible quaternion walking and frozen-state exports on all three targets.**
  - Goal: QUAT-NORM-001. Payoff: establish accurate, accessible rendered behavior and exports beyond pure model tests.
  - Sources: [Accepted companion](PRD.md#prime-norm-quaternion-companion), [accepted slice design](docs/engineering/spec.md#prime-norm-quaternion-companion), [planned checks](docs/engineering/test-plan.md#prime-walking-growth-and-quaternion-slice-checks), and `lib/core/modules/fractals/quaternion_julia_3d_module.dart`. [Refined UI/budgets](docs/engineering/spec.md#ui-layout-and-interaction-contract) and [per-task fixture matrix](docs/engineering/test-plan.md#prime-walking-refined-acceptance-matrix).
  - Graph evidence: the fresh partial code-only graph contains `FractalViewState` at `lib/core/models/fractal_view_state.dart:22` and `quaternion_julia_3d_module.dart`; quaternion query was truncated. Source at `lib/core/modules/fractals/quaternion_julia_3d_module.dart:37–42` confirms a Julia shader, not prime walking. No complete quaternion UI graph or proof semantics are claimed; existing self-loop/duplicate-label warnings remain.
  - Ownership: repository backlog, unassigned; check live ownership before dispatch. No implementation worker is started by this plan.
  - Scope: actual companion-open/rotate/select/walk/component/export journey, EN/ES legend/disclosure, reduced motion, narrow/enlarged text, keyboard/semantics, capped computation measurements and cancellation. Preserve existing module IDs/user data. Exclude store publication, Lean builds and proof of a higher-dimensional moat.
  - Acceptance: actual companion rotation/picking/list/Step/component/export journey and decoded selected-state PNGs pass on named targets; occlusion, EN/ES, keyboard/semantics/focus, high contrast, reduced motion and responsive text/layout fixtures pass. Measure cap/chunk/job behavior and real timing/memory; unavailable or emulator-only results remain separate.
  - Checks: create/run `integration_test/flows/prime_norm_quaternion_journey_test.dart` on named Linux/Android targets; extend and run the actual production-build browser target; focused model/widget tests, existing viewer/export regressions, formatter/analyzer. Exact new browser target is recorded when implemented, not invented here.
  - UI/performance: follow the shared HUD/panel layout, preview-then-Step interaction, visible bounded-state labels, hard workload caps, cooperative chunks and completed-snapshot capture. This is planned acceptance, not a measured pass.
  - Dependencies: QUAT-NORM-02-WALK.
  - Decision: qualify displayed geometry and exported artifacts separately from the quaternion predicate.
  - Skill application: frontend-ui-engineering, localized accessible 3D journey; planning-and-task-breakdown, dependent platform qualification; documentation-and-adrs, unrun checks are not evidence.

- [ ] **REL-JOURNEY-02-LINUX — Qualify the complete Linux image-creation journey.**
  - Goal: REL-JOURNEY-001. Payoff: meet the accepted complete user journey on this platform without false parity claims.
  - Sources: [Accepted release contract](PRD.md#active-release-contract), [Journey verification](docs/engineering/test-plan.md#accepted-cross-platform-release-journey), `docs/engineering/rendering/renderer_backend_matrix.md`, `lib/features/export/export_options_sheet.dart`, and `test/export/viewer_export_session_test.dart`.
  - Graph evidence: fresh partial code-only export graph, `ExportOptionsSheet` → `ExportSheetSubmission` and `ExportOptions` at `export_options_sheet.dart:13,28,46`; `ExportResolutionSummary.fromEffectiveOptions` at `export_resolution_summary.dart:19`. Services, journey tests and doc semantics are unindexed; two self-loops/duplicate-label warnings require source corroboration.
  - Scope: Extend the existing native user-flow and export tests to browse/open 2D and 3D examples, edit the viewer, inspect current mathematics/qualifications and save PNG files. Reuse native export capture and storage Preserve formulas, IDs, favorites, presets, EN/ES support, preview quality caps and renderer gates. Exclude publication, deployment, historical MVP expansion and other platforms.
  - Acceptance: Both dimensional examples produce readable PNGs with selected dimensions and edited view/settings, accurate disclosure and no crash/placeholder substitution; saved data remains intact. Record every failure, skip and remaining gap. A build or widget-only pass does not close the task.
  - Checks: `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded`; `flutter test test/export/viewer_export_session_test.dart test/export/export_service_test.dart --reporter expanded`; record/run the exact added artifact-export test, formatter and analyzer. Hardware/backend identity must accompany the result.
  - Dependencies: none. Platform slices are independent; no existing active worker is superseded.
  - Ownership: repository backlog, unassigned. Check live ownership before any dispatch.
  - Decision: reuse existing journey/export components and fix only reproduced in-scope defects; no speculative renderer redesign or new dependencies.
  - Skill application: planning-and-task-breakdown, bounded end-to-end slice; frontend-ui-engineering, interaction and saved-state regressions; documentation-and-adrs, distinguish accepted target from observed qualification.

- [ ] **REL-JOURNEY-03-ANDROID — Qualify the complete Android image-creation journey.**
  - Readiness: Play-only candidate 1.1.108 is prepared, not published. Full release/device and cross-platform journey gates remain required. No Android device is connected; the reported running Waydroid instance was unreachable over ADB during preparation. The proposed 39-path camera repair is withheld after review BLOCK (Luminous pan cancellation and unversioned saved-frame semantics); the owner question is unanswered, not a waiver. See the verification frontier in `docs/engineering/test-plan.md`.
  - Goal: REL-JOURNEY-001. Payoff: meet the accepted complete user journey on this platform without false parity claims.
  - Sources: [Accepted release contract](PRD.md#active-release-contract), [Journey verification](docs/engineering/test-plan.md#accepted-cross-platform-release-journey), `docs/engineering/rendering/renderer_backend_matrix.md`, `lib/features/export/export_options_sheet.dart`, and `test/export/viewer_export_session_test.dart`.
  - Graph evidence: fresh partial code-only export graph, `ExportOptionsSheet` → `ExportSheetSubmission` and `ExportOptions` at `export_options_sheet.dart:13,28,46`; `ExportResolutionSummary.fromEffectiveOptions` at `export_resolution_summary.dart:19`. Services, journey tests and doc semantics are unindexed; two self-loops/duplicate-label warnings require source corroboration.
  - Scope: Reuse the common native journey tests on a named Android device and verify actual PNG storage/gallery behavior for edited 2D and 3D views. Reuse existing MediaStore export Preserve formulas, IDs, favorites, presets, EN/ES support, preview quality caps and renderer gates. Exclude publication, deployment, historical MVP expansion and other platforms.
  - Acceptance: Both examples yield readable, visible PNGs at the selected destination with selected dimensions and edited state; disclosure is accurate; no crash/placeholder substitution or saved-data loss occurs. Record every failure, skip and remaining gap. A build or widget-only pass does not close the task.
  - Checks: Record the Android device ID and run the common journey plus the exact added storage verification target on it. Read back/decode the actual saved artifacts and verify gallery visibility. Emulator-only checks remain separately labeled and cannot prove physical-device behavior.
  - Dependencies: none. Platform slices are independent; no existing active worker is superseded.
  - Ownership: repository backlog, unassigned. Check live ownership before any dispatch.
  - Decision: reuse existing journey/export components and fix only reproduced in-scope defects; no speculative renderer redesign or new dependencies.
  - Skill application: planning-and-task-breakdown, bounded end-to-end slice; frontend-ui-engineering, interaction and saved-state regressions; documentation-and-adrs, distinguish accepted target from observed qualification.

- [ ] **SMOOTH-001-INVENTORY-02 — Verify the next uncovered polynomial smooth-coloring family.**
  - Goal: SMOOTH-001. Payoff: extend coverage without mistaking samples for a complete audit.
  - Sources: [Existing P1-3 scope](TODO.md#p1-3-smooth-coloring-in-all-shaders), the family inventory produced by SMOOTH-001-INVENTORY-01, and `test/shaders/smooth_coloring_family_coverage_test.dart`.
  - Scope: select one uncovered applicable family from the inventory, record shader/module bindings, and add formula-specific source or numeric assertions. Preserve formulas. Exclude new fractals and general shader rewrites.
  - Acceptance: the selected family has explicit coverage and inside-set/palette assertions; focused family and numeric regression tests pass; the inventory names remaining gaps. Run formatter/analyzer on changed tests. Do not close the goal until the complete applicable inventory is accounted for.
  - Dependencies: SMOOTH-001-INVENTORY-01.
  - Ownership: repository backlog; check active work before dispatch.

- [ ] **VIS-006-BATCH-20 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Goal: complete the accepted visual playtest audit.
  - Payoff: extend measured GPU and first-view audit coverage while preserving fractal formulas.
  - Scope: select the next ten uncaptured Explore IDs from `docs/planning/visual-audit-inventory.json`; capture module defaults and actual runtime previews. Run CPU checks only where a native CPU formula exists. Do not alter formulas, static catalog images, or research-library module support.
  - Sources: [Accepted visual scope](docs/planning/visual-fidelity-audit-next.md#accepted-focus), [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md), [`docs/planning/visual-audit-inventory.json`](docs/planning/visual-audit-inventory.json), and `goals.json`.
  - Acceptance: reconcile selected/generated/failed/skipped counts; record defaults, metrics, and artifacts for each ID; validate inventory references; run formatter, analyzer, and targeted GPU integration tests.
  - Dependencies: VIS-006. VIS-005 (goal prerequisite).
  - Ownership: repository backlog; check active work before dispatch.
  - Goal: VIS-006.

- [ ] **VIS-006-CPU-01 — Verify native CPU behavior for five audited Explore modules.**
  - Goal: VIS-006. Payoff: distinguish CPU formula correctness from registration and GPU image health.
  - Sources: [Accepted visual scope](docs/planning/visual-fidelity-audit-next.md#accepted-focus), `docs/planning/visual-fidelity-audit-next.md`, `docs/planning/visual-audit-inventory.json`, `lib/features/renderer/cpu/cpu_formulas.dart`, and `test/cpu/cpu_formula_coverage_test.dart`.
  - Scope: select five captured Explore IDs with registered native CPU formulas and no recorded correctness check. Reuse existing tests/oracles where available; add a small deterministic known-point or reference comparison for the selected formulas. Do not use a synthetic fallback as proof or redesign formulas.
  - Acceptance: each selected ID records native support, exact reference/check, and passing or failed result; no available oracle is reported as an explicit skip rather than a pass. Run `flutter test test/cpu/cpu_formula_coverage_test.dart` plus the exact added focused test, formatter/analyzer, and the inventory validator. Record remaining CPU gaps.
  - Dependencies: VIS-006-FIRST-VIEW-04. VIS-005 (goal prerequisite).
  - Ownership: repository backlog; check active work before dispatch. No hardware or full-catalog qualification is implied.

- [ ] **VIS-006-FIRST-VIEW-04 — Verify five captured Explore modules without first-view evidence.**
  - Goal: VIS-006. Payoff: qualify actual catalog-to-viewer GPU starts separately from thumbnail captures.
  - Sources: [Accepted visual scope](docs/planning/visual-fidelity-audit-next.md#accepted-focus), `docs/planning/visual-fidelity-audit-next.md`, `docs/planning/visual-audit-inventory.json`, and `integration_test/flows/vis006_first_view_test.dart`.
  - Scope: select five captured Explore rows lacking `first_view`, reuse the existing first-view harness, and assert module identity, default params/view, and the first GPU frame. No formulas, defaults, static thumbnails, or research-renderer implementations may change.
  - Acceptance: five exact IDs emit `gpu_first_frame` with `backend=gpu`; defaults match each module preset; inventory rows link to exact test evidence. Run `flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded`, targeted formatting/analysis, and `python3 research/fractals-library/scripts/validate_visual_inventory.py`. Record device/backend and every failure or skip.
  - Dependencies: VIS-006-BATCH-20. VIS-005 (goal prerequisite).
  - Ownership: repository backlog; preserve existing active VIS-006 work.



- [ ] **ICON-ZJ-02 — Replace app and store icon assets with the approved app capture.**
  - Goal: VIS-003. Payoff: use one approved, app-derived identity consistently in launchers, HomeScreen and the prepared Play listing.
  - Sources: [Accepted outcome and planner decisions](docs/engineering/spec.md#app-derived-zig-zag-julia-icon), `pubspec.yaml`, `assets/fractal-forge-icon-source.json`, `docs/store_listing/assets.json`, `scripts/play_store_listing.py`, `lib/features/home/home_screen.dart`.
  - Status: open.
  - Scope: After existing owner sign-off, install the staged source/derivatives at existing asset paths; retain raw capture/state under `assets/icon/zig_zag_julia/`; update the existing provenance manifest, alternate raster alias and configured generated launcher/favicon resources. Narrowly support fully opaque RGBA icons in the listing validator with regressions; keep other image groups RGB. Update affected store docs/test-plan/changelog to actual implementation. Latest direct owner authority additionally permits icon-only Play API publication after approving B. No listing text/video, screenshots, feature graphic, release track, binary upload, version bump, package rename, new platform support or dependency changes.
  - Acceptance: Approved composition and source hashes match every delivered derivative; master/foreground 1024px, Play 512px opaque sRGB 32-bit PNG at most 1024 KB, in-app mark 64px. Existing configured platform icon resources and Android adaptive XML/padding/background are coherent; no active raster alias retains old artwork. Icon-only opaque-RGBA validation passes and transparent/wrong-size/oversize icons fail; existing RGB campaign fixtures and strict RGB non-icon validation remain valid. HomeScreen logo renders without asset errors. Generated files and Android proof/device review match the approved candidate, without claiming publication.
  - Checks: Planned, unrun: `dart run flutter_launcher_icons`; `python3 -m unittest test/scripts/test_app_icon_assets.py test/scripts/test_play_store_listing.py`; `scripts/update-play-store-listings.sh --validate-only`; `flutter test test/screens/home_screen_widget_test.dart`; `flutter analyze`; `git diff --check`. Add the new asset/provenance regression fixture as part of this work. Inspect generated Android masks/resources and verify an installed launcher on a real device; record unavailable platform builds separately, never as passed. Do not run listing `--dry-run` (it stages remote edits), `--audit` or `--commit` as local validation.
  - Dependencies: ICON-ZJ-01, VIS-003.
  - Ownership: FRACTAL, current interactive implementation. Owner explicitly approved B and instructed app/Play icon replacement. Installed-device appearance remains unverified; keep original live qualification open rather than invent a device pass.
  - Owner authorization: “Good . Change the new app icon in app and playstore” explicitly authorizes B asset application and icon-only listing publication now. This is not a device-qualification or broader release waiver. VIS-003 retains its unexecuted installed-device check.
  - Progress: Approved B assets and configured Android/iOS/web/Windows/macOS icons are regenerated and applied in the canonical working checkout. Sixteen asset tests, 11 home widget tests, full Flutter analysis and 25 listing/publisher regressions pass on the isolated coherent candidate; canonical installed-asset and home smoke checks also pass. The icon-only Play edit was committed across all 15 live locales. Fresh-edit readback matches B SHA256 `c22c4fde194800588d21ad3ef2047749bb6335ce4b3fff605c00b1a054396c41` in every locale and proves complete live text/video dictionaries plus all inspected non-icon image metadata/order unchanged. No binary, release track or remote Git update was performed. This is delivered asset/listing work, not installed-device qualification; original device acceptance and task completion remain open.
  - Next action: Verify the installed B launcher on an Android test device when available and record the remaining VIS-003 verdict; no device is attached. Existing installed apps receive the launcher change with a future binary update, which this icon-only instruction did not publish. Do not re-upload the already verified listing icon merely to refresh evidence.

## Needs decision

- [ ] **CAT-QUALITY-03 — Decide curated discovery with the complete catalog still accessible.**
  - Goal: CAT-QUALITY-001. Payoff: improve the first experience while preserving mathematical and visual variety.
  - Sources: [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), [accepted outcome](PRD.md#catalog-quality-and-variety), `docs/planning/visual-audit-inventory.json`, `lib/features/catalog/data/catalog_repository.dart`, `lib/core/modules/fractal_mathematics.dart`.
  - Graph evidence: Fresh partial 38-file code-only Graphify scan: CatalogRepository (`catalog_repository.dart:15,20,57`), CatalogEntry (`catalog_entry.dart:12,30`), FractalMathematics (`fractal_mathematics.dart:11,45`) and LaunchVisualMetrics (`launch_visual_metrics.dart:9`). Extracted nodes are source-corroborated; five self-loops/duplicate-label warnings and truncated queries remain. Shaders/viewer/export/docs semantics are not indexed. See the quality plan for queries and receipt path.
  - Scope: Proposed: small curated collection using existing cards/filters and source-reviewed family/group metadata; full catalog/search/favorites remain accessible. Record adopt/revise/defer before product UI work. No destructive deduplication, renaming, certification badge or remote ranking service.
  - Acceptance: Owner records the discovery/promotion decision. If adopted, bind exact representative IDs and honest qualifications to pilot evidence, preserve full supported ID availability and state, EN/ES, keyboard/screen-reader access and restored search/filter behavior. Proposed layout is not counted as implemented.
  - Checks: Decision record plus planned catalog search/math-navigation/a11y/ID regression and named 320px/768px layouts at text scale 2; these checks are NOT_RUN until an approved UI change is implemented.
  - Dependencies: CAT-QUALITY-02.
  - Ownership: Product owner decision; proposed UI remains Needs decision. No implementation or schedule is authorized.


- [ ] **MEDIA-002 — Select launch hero stills.** Scope: choose 6–8 from the captured Featured Launch Set plus separate 3D/tiling candidates (`mandelbulb` and `spectre_monotile` or `hat_monotile`); no source asset publication. Acceptance: record the selected module IDs and artifact paths, covering 2D escape-time, Newton, IFS, attractor, tiling, and one 3D example as required by the runbook. Dependency: candidate output from MEDIA-001 and supplemental high-resolution captures must exist. Blocker: selection is taste-based and requires product-owner judgment; owner not recorded. See [`docs/planning/LAUNCH_MEDIA.md`](docs/planning/LAUNCH_MEDIA.md).
  - Goal: MEDIA-002. Payoff: choose representative launch imagery without publishing assets.
  - Sources: `docs/planning/LAUNCH_MEDIA.md` and MEDIA-001 evidence above.
  - Dependencies: MEDIA-001 (existing verified launch captures). Supplemental 3D/tiling captures and owner selection remain acceptance prerequisites; no new capture task is invented.
  - Ownership: product owner decision required; no publication is authorized.
  - Scope: select 6–8 captured stills covering the existing launch-media family requirements; exclude publication and new rendering work.
  - Acceptance: owner records selected IDs and artifact paths, including supplemental 3D/tiling candidates. Required captures must exist before selection.

- [ ] **VIS-003 — App icon visual sign-off.** Scope: inspect the existing adaptive launcher and store artwork in representative device masks; do not treat missing files as the issue or redesign without approval. Acceptance: product owner records accept/request-change and any exact crop/design correction. Blocker: visual acceptance criteria/approval are owner-controlled; inputs and dimensions were checked, but visual acceptance is not claimed. Ownership: owner decision required.
  - Goal: VIS-003. Payoff: obtain an explicit artwork acceptance decision.
  - Sources: `docs/store_listing/ASSET_SPECS.md` and the Slice D input checks in `docs/planning/visual-fidelity-audit-next.md`.
  - Target clarification: The owner now requests an app-derived Zig-Zag Julia replacement; see [the prospective branding override](docs/engineering/spec.md#app-derived-zig-zag-julia-icon). Review staged ICON-ZJ-01 candidates and record their exact hashes/crop corrections plus representative Android device/mask observations from the disposable preview build (retain APK hash); no canonical integration is needed to obtain that preview. Historical SVG input checks are not approval of the replacement; original owner-controlled acceptance remains unchanged. ICON-ZJ-02 waits for this sign-off.
  - Owner approval: B/open-spiral composition was selected, followed by explicit instruction to apply it in the app and Play Store. No further design-choice interview is needed. Remaining live qualification is actual installed Android launcher presentation; no device is attached and that check is not claimed.
  - Checks: Planned owner review of ICON-ZJ-01 proof at native icon sizes, actual Android launcher presentation and the recorded capture/provenance; save explicit accept/request-change with exact candidate hashes. No execution or publication from this review task.
  - Dependencies: none.
  - Ownership: product owner decision required. No redesign or release is authorized.
  - Scope: review existing adaptive launcher/store artwork in representative masks; exclude unapproved redesign or release.
  - Acceptance: owner records accept/request-change and exact requested crop or design corrections.

- [ ] **OAI-VIS-01-IFS — Decide a self-similar measure overlap explorer.**
  - Goal: OAI-VIS-001. Payoff: add a distinct experience only if it meets the catalog quality bar.
  - Sources: [Pinned shortlist and papers](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), OpenAI commit `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, existing module/inventory overlap inspection.
  - Graph evidence: partial seven-file Graphify scan; CatalogRepository:15, ModuleRegistry:64, FractalMathematics:11 are source-correlated. Truncated query/duplicate-label warning; source corroborates declarative entries and shader model. Proof/viewer/export semantics unindexed.
  - Scope: Proposed candidate decision, not implementation. Exact affine-composition entropy versus branch entropy; measure versus attractor; reuse Cantor/IFS where truthful. Preserve existing IDs/state; no shaders, dependencies, migration, renderer rewrite, dispatch or schedule.
  - Acceptance: record select/revise/defer with exact finite model, distinctness, compatibility approach, approximation labels, resource caps and discriminating correctness/render/export checks. Choose at most one initial prototype; do not claim theorem verification from a finite image or source README.
  - Checks: inspect referenced pinned paper/model and scope; adopt the candidate-specific fixtures in the shortlist, then bind exact planned test targets before any implementation. Product tests/Lean rebuilds are NOT_RUN.
  - Dependencies: none; proposals do not bypass current focus or existing quality gates.
  - Ownership: product owner choice, repository backlog; Needs decision. Planning does not authorize implementation.

- [ ] **OAI-VIS-02-SLE — Decide a seeded SLE curve explorer.**
  - Goal: OAI-VIS-001. Payoff: add a distinct experience only if it meets the catalog quality bar.
  - Sources: [Pinned shortlist and papers](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), OpenAI commit `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, existing module/inventory overlap inspection.
  - Graph evidence: partial seven-file Graphify scan; CatalogRepository:15, ModuleRegistry:64, FractalMathematics:11 are source-correlated. Truncated query/duplicate-label warning; source corroborates declarative entries and shader model. Proof/viewer/export semantics unindexed.
  - Scope: Proposed candidate decision, not implementation. Reviewed Loewner numerical scheme, deterministic Brownian seed and bounded refinement; do not label random walks SLE. Preserve existing IDs/state; no shaders, dependencies, migration, renderer rewrite, dispatch or schedule.
  - Acceptance: record select/revise/defer with exact finite model, distinctness, compatibility approach, approximation labels, resource caps and discriminating correctness/render/export checks. Choose at most one initial prototype; do not claim theorem verification from a finite image or source README.
  - Checks: inspect referenced pinned paper/model and scope; adopt the candidate-specific fixtures in the shortlist, then bind exact planned test targets before any implementation. Product tests/Lean rebuilds are NOT_RUN.
  - Dependencies: none; proposals do not bypass current focus or existing quality gates.
  - Ownership: product owner choice, repository backlog; Needs decision. Planning does not authorize implementation.

- [ ] **OAI-VIS-03-VORONOI — Decide a finite Poisson–Voronoi crossing explorer.**
  - Goal: OAI-VIS-001. Payoff: add a distinct experience only if it meets the catalog quality bar.
  - Sources: [Pinned shortlist and papers](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), OpenAI commit `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, existing module/inventory overlap inspection.
  - Graph evidence: partial seven-file Graphify scan; CatalogRepository:15, ModuleRegistry:64, FractalMathematics:11 are source-correlated. Truncated query/duplicate-label warning; source corroborates declarative entries and shader model. Proof/viewer/export semantics unindexed.
  - Scope: Proposed candidate decision, not implementation. Explicit finite geometry/adjacency, monotone occupancy and crossing fixtures; preserve percolation and Voronoi crackle identities. Preserve existing IDs/state; no shaders, dependencies, migration, renderer rewrite, dispatch or schedule.
  - Acceptance: record select/revise/defer with exact finite model, distinctness, compatibility approach, approximation labels, resource caps and discriminating correctness/render/export checks. Choose at most one initial prototype; do not claim theorem verification from a finite image or source README.
  - Checks: inspect referenced pinned paper/model and scope; adopt the candidate-specific fixtures in the shortlist, then bind exact planned test targets before any implementation. Product tests/Lean rebuilds are NOT_RUN.
  - Dependencies: none; proposals do not bypass current focus or existing quality gates.
  - Ownership: product owner choice, repository backlog; Needs decision. Planning does not authorize implementation.

- [ ] **OAI-VIS-04-UST — Decide uniform spanning tree and loop-erased path explorer.**
  - Goal: OAI-VIS-001. Payoff: broaden mathematically distinct experiences without a quantity-driven catalog expansion.
  - Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 231 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
  - Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
  - Scope: Proposed finite-model candidate choice only. Seeded branching trees, a highlighted unique path and animated loop erasure on a capped finite grid. Wilson sampling is an established finite uniform-spanning-tree approach; the paper concerns the free spanning forest on infinite graphs, not a new finite algorithm. No explicit spanning-tree/loop-erased ID matched the recorded inventory. Maze CA, brownian_tree_dla and levy_brownian_paths exist, but neither maze rules nor diffusion-limited aggregation is a uniform spanning tree. Do not substitute DLA or relabel an existing identity. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning.
  - Acceptance: owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem.
  - Checks: planned discriminating fixtures: Every vertex belongs to one acyclic connected tree, edge count V-1, unique paths; exact tiny-graph enumeration checks the sampling law, replay same seed, disclose rooting/free/wired boundary choice, cancel long walks and cap walk work without silently biasing accepted samples. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN.
  - Dependencies: none; decision proposals cannot bypass existing quality gates or primary focus.
  - Ownership: product owner choice; Needs decision, unassigned. No implementation authority.

- [ ] **OAI-VIS-05-DIMER — Decide double-dimer nested-loop explorer.**
  - Goal: OAI-VIS-001. Payoff: broaden mathematically distinct experiences without a quantity-driven catalog expansion.
  - Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 226 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
  - Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
  - Scope: Proposed finite-model candidate choice only. Draw two independent perfect matchings of a bounded bipartite lattice, then their superposition: doubled edges and closed loops. Color by loop identity/nesting and retain the two matchings for inspection. The cited paper proves a half-plane Temperleyan scaling limit; generic finite rectangles are not automatically that law. No dimer ID matched the inventory. Related to SLE/CLE but distinct finite perfect-matching model; keep it one entry, not one catalog item per loop color. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning.
  - Acceptance: owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem.
  - Checks: planned discriminating fixtures: One matched edge per vertex in each matching, degree two with multiplicity in the superposition, doubled edges treated separately, loop decomposition exhausts remaining edges and small exact matchings check sampling. Distinguish exact uniform sampling from a finite MCMC approximation; report burn-in/convergence limitations rather than claim uniformity. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN.
  - Dependencies: none; decision proposals cannot bypass existing quality gates or primary focus.
  - Ownership: product owner choice; Needs decision, unassigned. No implementation authority.

- [ ] **OAI-VIS-06-HEIGHT — Decide six-vertex height and contour explorer.**
  - Goal: OAI-VIS-001. Payoff: broaden mathematically distinct experiences without a quantity-driven catalog expansion.
  - Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 225 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
  - Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
  - Scope: Proposed finite-model candidate choice only. Show lattice arrows, a finite discrete height map and contour bands for the ice model. Enforce two arrows in and two out at every interior vertex; display a=b=1 and c weight, boundary conditions and sector. Result 232 supplies a related triangular-Lipschitz-height variant, grouped here rather than booked separately. No six_vertex/height/gaussian_free ID matched. Ordinary procedural noise is not a Gaussian free field or an ice-model sampler. Similar colors do not establish equivalent mathematical identity. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning.
  - Acceptance: owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem.
  - Checks: planned discriminating fixtures: Ice constraints hold; oriented height increments are path-consistent under the stated boundary/sector convention; tiny configurations have correct weights; seed replay and sampler limitations are disclosed. A torus can have nonzero winding, so do not claim a globally periodic scalar height outside a zero-winding sector. Finite height samples are not exact continuum GFF samples. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN.
  - Dependencies: none; decision proposals cannot bypass existing quality gates or primary focus.
  - Ownership: product owner choice; Needs decision, unassigned. No implementation authority.

- [ ] **OAI-VIS-07-FK — Decide fortuin–Kasteleyn cluster and interface explorer.**
  - Goal: OAI-VIS-001. Payoff: broaden mathematically distinct experiences without a quantity-driven catalog expansion.
  - Sources: [Candidate plan](docs/planning/visual-fidelity-audit-next.md#openai-mathematics-visual-candidate-shortlist), [Expanded shortlist](docs/planning/visual-fidelity-audit-next.md#expanded-candidates--additional-source-backed-proposals), [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), pinned OpenAI result 223 at `fd4aeeb2ee4fc729c18d98444fed42fd0529eeeb`, current inventory overlap receipt.
  - Graph evidence: four-file partial code-only scan; ModuleRegistry:64, FractalMathematics:11, CatalogRepository:15 corroborated in source; truncated query and duplicate-label warning, complete model/shader semantics unindexed.
  - Scope: Proposed finite-model candidate choice only. Finite square-lattice random-cluster configurations with visible bond probability p, cluster weight q, clusters, boundary wiring and exploration interface. The finite law weights configurations by p^open*(1-p)^closed*q^clusters; it is not independent percolation when q differs from one. Treat q=1 and q=2 as configurations of one family. Existing percolation is not this finite random-cluster law; coordinate with OAI-VIS-03-VORONOI and preserve its ID. It also relates to OAI-VIS-02-SLE but finite lattice connectivity is a different model. Reuse a future common model only if justified by real callers, not a speculative graph framework. No new IDs, dependencies, shaders, saved-state migrations, dispatch or schedule during planning.
  - Acceptance: owner records select/revise/defer and exact finite model, sampler/boundary conditions, resource caps, uncertainty disclosures and compatibility contract; choose at most one initial prototype across the shortlist. No finite output is proof of the continuum/infinite theorem.
  - Checks: planned discriminating fixtures: Tiny exact partition-function/cluster-count fixtures, q=1 reduction to independent bonds, correct wired/free cluster counting and Dobrushin interface rules, seed replay and explicit sampler mixing gaps. Do not infer arbitrary-q uniformity or SLE convergence from a colorful sample. The inspected first paper covers 1<=q<4; the index lists broader companions, whose hypotheses must be reviewed separately. Bind actual test targets before approved implementation; model/render/platform checks are NOT_RUN.
  - Dependencies: none; decision proposals cannot bypass existing quality gates or primary focus.
  - Ownership: product owner choice; Needs decision, unassigned. No implementation authority.

## Done

## Goal coverage — visual-fidelity scope

<!-- goals:coverage:begin -->

Generated from `goals.json` by `goals.py render`. `met` requires an executed, passing check.

| Goal | Status | Evidence | Task |
| --- | --- | --- | --- |
| VIS-004: Verify the Featured Launch Set default and viewer-start flow | met | executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis004_newton_z3_first_view_test.dart &amp;&amp; flutter analyze integration_test/flows/vis004_newton_z3_first_view_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis004_nova_first_view_test.dart</code> → pass; executed <code>flutter analyze integration_test/flows/vis004_nova_first_view_test.dart</code> → pass; executed <code>flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/flows/vis004_newton_z3_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/flows/vis004_newton_z3_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (pass; observed gpu_first_frame module=newton_z3 backend=gpu at 207ms, assertions synchronized to that frame)</code> → pass; executed <code>flutter test integration_test/flows/vis004_nova_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (pass; observed gpu_first_frame module=nova backend=gpu; default pan=(0,0), zoom=1.5, iterations=200, relaxation=1.0, colorScheme=2)</code> → pass; executed <code>git diff --check</code> → pass; inspection <code>TODO.md#VIS-004: all nine Featured Launch Set IDs have executed GPU first-view evidence</code> → pass; inspection <code>TODO.md#VIS-004: prior real-GPU and viewer-start checks cover four modules</code> → pass | — |
| VIS-005: Reconcile the visual audit across Explore and the research library | met | executed <code>flutter test test/catalog/catalog_id_integrity_test.dart --reporter expanded (15 tests passed; includes live Explore inventory reconciliation)</code> → pass; executed <code>python research/fractals-library/scripts/validate_manifest.py</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py</code> → pass; inspection <code>TODO.md#VIS-005: prior broad audit timed out and research definitions are not mapped</code> → fail; inspection <code>docs/planning/visual-audit-inventory.json: 1,027 Explore IDs and 200 manifest IDs have explicit renderer status and references</code> → pass | — |
| VIS-006: Audit mapped fractals in reconciled batches | partial | executed <code>Artifact reconciliation: 20/20 batch-11 PNGs exist; 10 default images are 256x256 and 10 runtime images are 384x346; all targets have captured inventory metrics and no failures/skips</code> → pass; executed <code>CATALOG_THUMB_ONLY=&lt;ten VIS-006-BATCH-12 IDs&gt; CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch12-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default image-health pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=&lt;ten VIS-006-BATCH-15 IDs&gt; CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch15-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.arneodo,core.dadras,core.chen,core.lu_chen,core.halvorsen,core.scroll_waves,core.rikitake,core.aizawa,core.rabinovich_fabrikant,core.nose_hoover CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch11-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default images 256x256; strict image-health pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.buddhabrot_approx,core.anti_buddhabrot,core.nebulabrot,core.wolfram_rule30,core.rule90_linear_ca,core.rule150_linear_ca,core.cyclic_cellular_automaton,core.greenberg_hastings_ca,core.klausmeier_vegetation,core.gerhardt_schuster_tyson_ca CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch19-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all default image verdicts pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.burning_ship CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-burning-ship-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 1209 colors; blackPixelRatio=0.2008; math oracle pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.druid,core.inverse_mandelbrot,core.glynn,core.simonbrot,core.shark_fin,core.manowar,core.spider,core.collatz,core.popcorn,core.talis CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch03-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all ten GPU image metrics pass; no CPU oracles registered)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.four_wing CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-four-wing-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 785 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass; shader receives bailout=8; oracle skipped)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.fractal_canopy,core.benesi,core.schottky_limit_set,core.henon,core.tinkerbell,core.gingerbreadman,core.lozi,core.duffing,core.ikeda,core.clifford CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch09-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all 256x256 and strict image verdict pass; all math oracles skipped)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.greek_cross_fractal,core.sierpinski_pentagon,core.hexaflake,core.pentaflake,core.cantor_dust,core.apollonian_gasket,core.ford_circles,core.steiner_chain,core.cesaro_fractal,core.cantor_set CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch08-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; strict render health pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.greek_cross_fractal,core.sierpinski_pentagon,core.hexaflake,core.pentaflake,core.cantor_dust,core.apollonian_gasket,core.ford_circles,core.steiner_chain,core.cesaro_fractal,core.cantor_set CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch08-defaults-review STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.householder,core.zeta_newton,core.magnet_newton,core.hypercomplex_newton,core.quaternion_julia_2d,core.tessarine_julia,core.split_complex,core.dual_complex,core.bicomplex,core.sine_julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch14-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-julia-defaults STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 2298 colors; verdict pass; Julia C=(-0.8,0.156), iterations=160, bailout=4.0; math oracle pass; render warmup 2092.344ms; capture 278.926ms)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.julia_dual,core.phoenix,core.tricorn,core.celtic,core.buffalo,core.multibrot3,core.nova,core.nova_julia,core.fatou,core.gamma_fractal CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch01-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.koch_snowflake CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-koch-followup STRICT_CATALOG_THUMBS=true FORCE_GPU_RENDER=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.levy_c_curve,core.levy_tapestry,core.golden_dragon,core.twin_dragon,core.terdragon,core.chair_tiling,core.koch_anti_snowflake,core.quadratic_koch_island,core.cyclosorus_fern,core.menger_sponge_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch06-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; each 256x256; all render verdicts pass; no reference math oracles)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.log_spiral,core.lyapunov,core.logistic_lyapunov,core.circle_map_lyapunov,core.sine_map_lyapunov,core.tent_map,core.hopalong,core.pickover_biomorph,core.feigenbaum,core.gauss_map CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch18-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.lorenz_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-lorenz-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed=1/1/0; image 256x256, 641 colors, nonBlack=1.0)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-mandelbrot-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256; 941 colors; blackPixelRatio=0.1749; nonBlack=0.8251; verdict pass; math oracle pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.perpendicular_julia,core.tricorn_julia,core.burning_ship_julia,core.multibrot_neg2,core.heart,core.cosine_mandelbrot,core.tangent_mandelbrot,core.sinh_mandelbrot,core.cosh_mandelbrot,core.tanh_mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch17-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (10/10/0/0; all metrics pass; math oracle skipped 10)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.perpendicular_julia,core.tricorn_julia,core.burning_ship_julia,core.multibrot_neg2,core.heart,core.cosine_mandelbrot,core.tangent_mandelbrot,core.sinh_mandelbrot,core.cosh_mandelbrot,core.tanh_mandelbrot CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch17-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all image health pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.perpendicular_mandelbrot,core.lambda,core.magnet_type_1,core.magnet_type_2,core.magnet_type_3,core.power_sum,core.cactus,core.astroid,core.deltoid,core.eisenstein CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch02-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; 10/10 math oracle skipped for lack of stable known-point checks)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.peter_de_jong,core.svensson,core.gumowski_mira,core.arnold_cat,core.standard_map,core.zaslavsky,core.kicked_rotator,core.chua_circuit,core.sprott_a,core.burke_shaw CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch10-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all defaults 256x256; all strict metrics pass; reference oracles skipped)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.rossler_2d CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-rossler-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; image 256x256, 1245 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass; math oracle skipped: no reference oracle)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.secant_cosecant,core.taylor,core.rational_map,core.lattes_map_julia,core.complex_henon_julia_slice,core.matrix_logistic_spectrum,core.barnsley_j2,core.barnsley_j3,core.celtic_julia,core.buffalo_julia CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch16-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all ten default image-health pass; reference math oracle skipped 10)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.tetration,core.sierpinski_triangle,core.sierpinski_carpet,core.koch_snowflake,core.dragon_curve,core.barnsley_fern,core.pythagorean_tree,core.hilbert_curve,core.peano_curve,core.gosper_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch04-defaults STRICT_CATALOG_THUMBS=false flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0; all image-health verdicts pass)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.tetration,core.sierpinski_triangle,core.sierpinski_carpet,core.koch_snowflake,core.dragon_curve,core.barnsley_fern,core.pythagorean_tree,core.hilbert_curve,core.peano_curve,core.gosper_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch04-strict STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/9/1/0; Koch strict black-ratio threshold failure)</code> → fail; executed <code>CATALOG_THUMB_ONLY=core.thomas_attractor CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-thomas-attractor-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 979 colors, blackPixelRatio=0.0, nonBlack=1.0; verdict pass; no math oracle)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.vicsek_fractal,core.penrose_tiling,core.fibonacci_word,core.rauzy_fractal,core.arnoux_rauzy_fractal,core.dual_substitution_tiling,core.bedford_mcmullen_carpet,core.self_affine_finite_type,core.pinwheel_tiling,core.z_order_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch07-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (10/10/0/0; all defaults image verdict pass; math oracles skipped 10)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.vicsek_fractal,core.penrose_tiling,core.fibonacci_word,core.rauzy_fractal,core.arnoux_rauzy_fractal,core.dual_substitution_tiling,core.bedford_mcmullen_carpet,core.self_affine_finite_type,core.pinwheel_tiling,core.z_order_curve CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch07-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded; FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch07_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.yu_wang,core.zhou_chen,core.tsucs,core.rayleigh_benard,core.robinson,core.globo_toroid,core.tamari,core.wang_sun_cang,core.newton_z3,core.halley CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch13-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0)</code> → pass; executed <code>CATALOG_THUMB_ONLY=core.yu_wang,core.zhou_chen,core.tsucs,core.rayleigh_benard,core.robinson,core.globo_toroid,core.tamari,core.wang_sun_cang,core.newton_z3,core.halley CATALOG_THUMB_USE_MODULE_DEFAULTS=true STRICT_CATALOG_THUMBS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-batch13-defaults flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=10/10/0/0)</code> → pass; executed <code>FORCE_GPU_RENDER=true FORCE_RUNTIME_CATALOG_THUMBNAILS=true flutter test integration_test/catalog/vis006_batch18_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch07_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime previews pass; 384x346 metrics)</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch08_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch11_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews; 384x346; all image-health verdicts pass)</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch13_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual GPU previews pass; dimensions 384x346)</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_batch14_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>FORCE_GPU_RENDER=true flutter test integration_test/catalog/vis006_julia_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 1314 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass; first_thumbnail_displayed=1909ms)</code> → pass; executed <code>FRESH 2026-10-06: CATALOG_THUMB_ONLY=core.four_wing CATALOG_THUMB_USE_MODULE_DEFAULTS=true CATALOG_THUMB_OUTPUT_DIR=build/test_output/vis006-four-wing-defaults STRICT_CATALOG_THUMBS=true flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (selected/generated/failed/skipped=1/1/0/0; 256x256, 785 colors, verdict pass)</code> → pass; executed <code>FRESH 2026-10-06: dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (0 changed) &amp;&amp; flutter analyze integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (no issues) &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py (1027 Explore, 200 manifest; pass) &amp;&amp; git diff --check (pass)</code> → pass; executed <code>FRESH 2026-10-06: flutter test integration_test/catalog/vis006_four_wing_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 481 colors; verdict pass)</code> → pass; executed <code>RenderMathOracle.evaluate in strict GPU report: all ten targets explicitly skipped because no reference oracle exists; cpu_formulas.dart registry inspection confirmed native _cpu_ implementations for all ten (not CPU correctness tests)</code> → pass; executed <code>STRICT batch04 GPU defaults capture selected=10 generated=9 failed=1 skipped=0; Koch blackPixelRatio=0.301254 exceeds threshold &lt;0.2; failure recorded and follow-up t_b2bbfadc created</code> → fail; executed <code>VIS-006 remaining-scope reconciliation after Thomas Attractor batch: mapped core Explore rows remain uncaptured; batch completes this module only</code> → fail; executed <code>VIS-006 scope closure check: requested all mapped Explore definitions and first-view behavior are not covered by this Four Wing-only batch</code> → fail; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch04_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch04_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch04_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch04_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check (all pass)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch06_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch06_runtime_preview_test.dart &amp;&amp; flutter test integration_test/catalog/vis006_batch06_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews pass; each 384x346; per-image metrics emitted)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch07_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch07_runtime_preview_test.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch09_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch09_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch13_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch13_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch13_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch13_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check HEAD</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch16_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch16_runtime_preview_test.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch17_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch17_runtime_preview_test.dart &amp;&amp; flutter test integration_test/catalog/vis006_batch17_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10 actual GPU runtime previews, 384x346, all metrics pass)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch18_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch18_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate . &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch19_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch19_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &amp;&amp; git diff --check (all passed)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart (formatted; no issues)</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart &amp;&amp; flutter analyze integration_test/flows/vis006_first_view_test.dart &amp;&amp; flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>dart format --output=none --set-exit-if-changed integration_test/flows/vis006_first_view_test.dart &amp;&amp; flutter analyze integration_test/flows/vis006_first_view_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>dart format --output=none --set-exit-if-changed lib/core/modules/builders/escape_time_catalog/ifs_geometric_fractals.dart &amp;&amp; flutter analyze lib/core/modules/builders/escape_time_catalog/ifs_geometric_fractals.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed lib/core/modules/common_params.dart test/modules/module_registry_widget_test.dart</code> → pass; executed <code>dart format integration_test/catalog/vis006_batch03_runtime_preview_test.dart --set-exit-if-changed &amp;&amp; flutter analyze integration_test/catalog/vis006_batch03_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>dart format integration_test/catalog/vis006_batch17_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch17_runtime_preview_test.dart &amp;&amp; flutter test integration_test/catalog/vis006_batch17_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews, all 384x346 and metric verdict pass)</code> → pass; executed <code>dart format integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (Formatted 1 file; 0 changed)</code> → pass; executed <code>dart format integration_test/catalog/vis006_julia_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_julia_runtime_preview_test.dart &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &amp;&amp; git diff --check (all passed)</code> → pass; executed <code>flutter analyze integration_test/catalog/vis006_four_wing_runtime_preview_test.dart (No issues found)</code> → pass; executed <code>flutter analyze integration_test/flows/vis006_first_view_test.dart</code> → pass; executed <code>flutter analyze lib/core/modules/common_params.dart test/modules/module_registry_widget_test.dart</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch01_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch02_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime GPU previews; 384x346; metrics captured; all verdicts pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch03_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (ten runtime catalog previews; each image metric verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 GPU runtime previews pass; 384x346)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch04_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 runtime previews pass; 384x346 metrics)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch08_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 GPU catalog previews; 384x346; all image verdicts pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch09_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual GPU runtime previews pass; all 384x346)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch10_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews; 384x346; all image-health verdicts pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch12_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime previews; all pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch13_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch15_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch16_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews pass; each 384x346; per-image metrics emitted)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch19_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_batch19_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (10/10 actual runtime GPU previews, 384x346; all image verdicts pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 1063 colors; blackPixelRatio=0.2151; verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_four_wing_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (core.four_wing runtime preview 384x346; 481 colors, blackPixelRatio=0.0, nonBlack=1.0, verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_julia_dual_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/catalog/vis006_lorenz_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (runtime catalog preview 384x346; 3008 colors; nonBlack=1.0)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_mandelbrot_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 603 colors; blackPixelRatio=0.1772; nonBlack=0.8228; verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_rossler_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (runtime catalog preview 384x346; 421 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass)</code> → pass; executed <code>flutter test integration_test/catalog/vis006_thomas_attractor_runtime_preview_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true --reporter expanded (384x346; 876 colors; blackPixelRatio=0.0; nonBlack=1.0; verdict pass)</code> → pass; executed <code>flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded</code> → pass; executed <code>flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (15/15 pass; five target modules logged gpu_first_frame backend=gpu and matched module default preset)</code> → pass; executed <code>flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (5/5 GPU first frames; each controller module, params, pan and zoom matched module default preset)</code> → pass; executed <code>flutter test integration_test/flows/vis006_first_view_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded (observed gpu_first_frame modules=fatou,gamma_fractal,lambda,nova_julia,perpendicular_mandelbrot; backend=gpu; default params/view matched; 10/10 total passed)</code> → pass; executed <code>flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; CPU formula registry coverage; no independent correctness claim)</code> → pass; executed <code>flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; confirms data-driven CPU approximation coverage, not native Thomas ODE correctness)</code> → pass; executed <code>flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; registry/finite-color coverage, not independent mathematical correctness)</code> → pass; executed <code>flutter test test/cpu/cpu_formula_coverage_test.dart --reporter expanded (4 tests passed; resolves each escape-time catalog module and verifies finite CPU color output, including native formulas in this batch)</code> → pass; executed <code>flutter test test/modules/module_registry_widget_test.dart --plain-name 'Rossler bailout schema preserves configured default'</code> → pass; executed <code>git diff --check</code> → pass; executed <code>inventory reconciliation: prior VIS-006 captures occupy Explore rows 0–72; this task scope occupies the next ten source-ordered rows 73–82; all ten referenced shader assets exist</code> → pass; executed <code>python - batch17 report/artifact/inventory reconciliation (10 target rows captured; selected/generated/failed/skipped=10/10/0/0; ten 384x346 runtime PNGs; next uncaptured order advances to core.log_spiral, core.lyapunov, core.logistic_lyapunov) &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate . &amp;&amp; git diff --check</code> → pass; executed <code>python -c "import json; d=json.load(open('docs/planning/visual-audit-inventory.json')); r=d['rows']; x=[i for i in r if i.get('source')=='Explore' and i.get('group')=='core']; captured=[i for i in x if i.get('runtime_preview','').startswith('captured in VIS-006:') or i.get('runtime_preview','').startswith('captured in VIS-006 ')]; print(f'Explore core rows={len(x)}; captured entries={len(captured)}; remaining={len(x)-len(captured)}'); assert len(captured)==len(x), 'VIS-006 has remaining mapped entries'" (exit 1: 1027 Explore core rows; 3 captured; 1024 remaining)</code> → fail; executed <code>python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null</code> → pass; executed <code>python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null</code> → pass; executed <code>python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py fmt . &amp;&amp; python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py validate . &amp;&amp; python /home/xel/.hermes/shared-skills/repo-docs/scripts/goals.py render . &amp;&amp; python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; git diff --check HEAD</code> → pass; executed <code>python VIS-006-BATCH-08 reconciliation assertion: exact ten IDs and order, shader assets, per-ID inventory records, default report 10/10/0/0, ten runtime PNGs</code> → pass; executed <code>python batch17 reconciliation: source-order exact target IDs, 10 shader paths exist, defaults report and runtime PNG count 10 each, inventory rows captured</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch10_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch10_runtime_preview_test.dart &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; flutter test test/catalog/catalog_id_integrity_test.dart --reporter expanded</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -c "verify ten VIS-006-BATCH-01 cpu_formula fields against cpu_formulas.dart registry and assert 9 native formulas plus julia_dual absent"</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_burning_ship_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check &amp;&amp; python inventory-count assertion</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt; /dev/null &amp;&amp; git diff --check (1227 rows; pass)</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; batch16 artifact/inventory reconciliation assertion &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch08_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch08_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch11_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch11_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch14_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch14_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; dart format --output=none --set-exit-if-changed integration_test/catalog/vis006_batch19_runtime_preview_test.dart &amp;&amp; flutter analyze integration_test/catalog/vis006_batch19_runtime_preview_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py &amp;&amp; python -m json.tool docs/planning/visual-audit-inventory.json &gt;/dev/null &amp;&amp; git diff --check</code> → pass; executed <code>python research/fractals-library/scripts/validate_visual_inventory.py (OK: 1027 Explore IDs + 200 manifest IDs; 1227 unique rows)</code> → pass; executed <code>python ~/.hermes/shared-skills/repo-docs/scripts/goals.py validate .</code> → pass; executed <code>python3 VIS-006-BATCH-01 report/inventory/path reconciliation assertion</code> → pass; executed <code>visual inventory JSON candidate integrity and source-order assertion for the five first-view rows</code> → pass; inspection <code>Inspected default and actual runtime-preview PNGs for core.four_wing: both are smooth broad color gradients with sharp sector/wedge boundaries, not a recognizable four-wing orbit; preserve formula pending follow-up</code> → fail; inspection <code>Lorenz captures show a narrow diagonal band over a smooth gradient rather than a recognizable two-lobed silhouette; visual follow-up warranted, formula preserved</code> → fail; inspection <code>Rossler defaults/runtime captures are mostly smooth gradients with a sharp triangular boundary rather than a recognizable orbit; additionally configured bailout=12 is normalized to 8 by shared parameter max=8 before shader uniform mapping; visual/default follow-up warranted, formula preserved</code> → fail; inspection <code>TODO.md#VIS-006: broad batch audit remains to be completed; Lorenz batch only captured</code> → fail; inspection <code>docs/planning/visual-audit-inventory.json: only 7 of 1,027 Explore rows have capture records; 200 manifest rows are missing_app_renderer; no first_viewer field exists; cpu_formula is not audited in 1,224 rows and three rows have limited caveats</code> → fail; inspection <code>shaders/ifs_and_geometric/koch_snowflake_gpu.frag:102-105: edge below 0.02 returns opaque black; observed strict default blackPixelRatio=0.301254 above harness threshold &lt;0.2. No shader/default alteration authorized.</code> → fail | VIS-006, VIS-006-BATCH-20, VIS-006-CPU-01, VIS-006-FIRST-VIEW-04 |
| SMOOTH-001: Prove smooth-coloring coverage for supported escape-time shaders | partial | executed <code>dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart</code> → pass; executed <code>dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>dart format test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; dart format --output=none --set-exit-if-changed test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart &amp;&amp; flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart &amp;&amp; git diff --check</code> → pass; executed <code>flutter analyze test/shaders/smooth_coloring_family_coverage_test.dart</code> → pass; executed <code>flutter test test/shaders/smooth_coloring_family_coverage_test.dart</code> → pass; executed <code>flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart --reporter expanded</code> → pass; executed <code>flutter test test/shaders/smooth_coloring_family_coverage_test.dart test/shaders/smooth_coloring_regression_test.dart test/shaders/escape_time_perturb_smooth_coloring_test.dart test/shaders/mcmullen_map_smooth_coloring_test.dart</code> → pass; executed <code>git diff --check</code> → pass; executed <code>python3 -c 'from pathlib import Path; p="shaders/escape_time_family/families/multibrot/integer_powers/multibrot4_gpu.frag"; assert Path(p).is_file(); assert p in Path("test/shaders/smooth_coloring_family_coverage_test.dart").read_text(), "SMOOTH-001 incomplete: supported Multibrot d=4 is absent from the family coverage test"'</code> → fail; inspection <code>TODO.md#P1-3: four families (7 shaders) covered; complete applicable polynomial escape-time inventory remains open</code> → fail; inspection <code>docs/engineering/performance/SHADER_OPTIMIZATIONS.md</code> → pass | SMOOTH-001-INVENTORY-01, SMOOTH-001-INVENTORY-02 |
| MEDIA-002: Select launch hero stills from qualified captures | unmet | inspection <code>TODO.md#MEDIA-002: owner selection remains open</code> → fail | MEDIA-002 |
| VIS-003: Obtain app icon visual sign-off | unmet | inspection <code>TODO.md#VIS-003: owner sign-off remains open</code> → fail | ICON-ZJ-02, VIS-003 |
| DOC-PRD-001: Resolve which documents own active product scope | met | executed <code>python3 "$HERMES_PROFILE/cache/scratch/repo-interview-release-20261011/check_interview_docs.py" "$REPO" (interview documentation/ledger only)</code> → pass; inspection <code>BLOCKERS.md#BLK-20261005-004: conflicting scope statements require owner decision</code> → fail | — |
| REL-JOURNEY-001: Qualify the complete image-creation journey on Android, web and Linux | unverified | inspection <code>PRD.md#active-release-contract: owner accepted the cross-platform journey; complete platform qualification remains unverified</code> → pass | REL-JOURNEY-01-WEB, REL-JOURNEY-02-LINUX, REL-JOURNEY-03-ANDROID |
| GAUSS-MOAT-001: Explore exact bounded Gaussian-prime walks with responsive controls and truthful reachability | unmet | executed <code>GAUSS-MOAT-01-MAP manual integration: git apply --check approved-owned.patch on main 7ede12424e6787ad9a514b8cdc9c37f509286b5f failed; three-way recovery leaves spec.md/test-plan.md conflicted because planning prerequisite is absent. Code-only diagnostic 171 tests/analyzer/format pass, not coherent integration qualification. Receipt /home/xel/.hermes/profiles/fractal/autowork/gaussian-moat-map/manual-integration-20261012/receipt.json</code> → fail; executed <code>GAUSS-MOAT-01-MAP offline/local integration only: python3 /home/xel/.hermes/profiles/fractal/autowork/gaussian-moat-map/coherent-continuation-20261012/run-frozen-gate.py at 79ae96506af162cc3f0f2392b631c5bf7229b333; 171 focused tests, analyzer, 8-file format, gen-l10n/source stability, docs/scope/diff pass; independent integration source review approved; git merge --ff-only and exact main/tree/15-path readback pass. No live/platform/milestone qualification.</code> → pass | GAUSS-MOAT-02-WALK, GAUSS-MOAT-03-QUALIFY, GAUSS-MOAT-04-GROWTH |
| QUAT-NORM-001: Explore exact prime-norm quaternion slice walks with camera-independent connectivity | unmet | — | QUAT-NORM-01-SLICE, QUAT-NORM-02-WALK, QUAT-NORM-03-QUALIFY |
| CAT-QUALITY-001: Improve catalog first-impression quality without losing variety or saved identities | unverified | — | CAT-QUALITY-01, CAT-QUALITY-02, CAT-QUALITY-03 |
| VIEW-UI-001: Reduce intrusive viewer navigation chrome and style overflow consistently | unverified | — | VIEW-UI-01, VIEW-UI-02 |
| OAI-VIS-001: Select a mathematically distinct quality-gated visual candidate from OpenAI math | unverified | — | OAI-VIS-01-IFS, OAI-VIS-02-SLE, OAI-VIS-03-VORONOI, OAI-VIS-04-UST, OAI-VIS-05-DIMER, OAI-VIS-06-HEIGHT, OAI-VIS-07-FK |

<!-- goals:coverage:end -->

---

## Architecture Direction (decided 2026-02-15, reaffirmed 2026-04-05)

**GPU-primary, CPU safety net.**
- GPU is the default renderer; many catalog modules share reviewed shader families rather than one shader per fractal
- Live registry lock: 543 escape-time catalog entries, 38 raymarched-3D entries, 9 custom hand-built modules, 1020 production fractals plus 1 scientific visualization (1028 debug/test `ModuleRegistry` modules including 7 diagnostics)
- CPU fallback auto-activates via renderer health/precision policy when GPU output or precision is invalid
- CPU path is maintenance-only (no further performance investment)
- GPU investment: coloring quality, smooth iteration, deep zoom, new formulas

---

## Perturbation Theory — Realistic Capability Assessment

**IMPORTANT:** Perturbation theory CANNOT be applied to all fractals. This section clarifies what's achievable.

### ✅ Perturbation Theory WORKS For (Polynomial Escape-Time)

These fractals use differentiable formulas where `dz_next = f(z+dz, c+dc) - f(z,c)` can be computed:

| Category | Fractals | Count | Status |
|----------|----------|-------|--------|
| Core Mandelbrot family | mandelbrot, multibrot variants | ~20 | 🔶 Mandelbrot uses DF2 path; multibrot3/4/5 perturbation implemented |
| Julia variants | julia, celtic_julia, buffalo_julia, etc. | ~30 | 🔶 Core `julia` perturbation implemented; variants remain open |
| Burning Ship variants | burning_ship, burning_ship_cubic, etc. | ~10 | 🔶 `burning_ship` implemented; variants remain open |
| Phoenix variants | phoenix, phoenix_julia | ~4 | 🔶 `phoenix` implemented; variants remain open |
| Buffalo/Tricorn/Celtic | buffalo, tricorn, celtic | ~6 | ✅ Implemented for core IDs |

**Current shipped GPU perturbation path:** `julia`, `burning_ship`, `buffalo`, `tricorn`, `celtic`, `phoenix`, `multibrot3`, `multibrot4`, `multibrot5`.
**Total achievable with perturbation: ~70-80 fractals**

### ❌ Perturbation Theory DOES NOT Work For

| Category | Reason | Examples |
|----------|--------|----------|
| IFS/Geometric | Uses iterated function systems, not escape-time | Sierpinski, Koch, Barnsley Fern |
| Strange Attractors | Continuous dynamics, not complex iteration | Lorenz, Rossler, Clifford |
| Cellular Automata | Discrete grid-based, not complex plane | Rule 30, Brian's Brain |
| Root-Finding fractals | Newton/Halley method, different algorithm | Newton z³-1, Halley |
| Stochastic | Random sampling, not deterministic | Buddhabrot, DLA |
| Tilings | Substitution rules, not iteration | Penrose, Ammann-Beenker |

**Most of the 1020-production-fractal catalog is still NOT suitable for perturbation; exact category counts need a fresh catalog audit.**

### 📊 Module Registry Breakdown (1020 production fractals; 1028 debug/test modules)

```
Live locks from test/catalog/catalog_id_integrity_test.dart:
├── Escape-time catalog raw unique IDs: 543
├── Raymarched-3D catalog IDs: 38
├── Custom hand-built modules: 9
├── Production fractals: 1020
├── Scientific visualizations: 1
└── Debug/test ModuleRegistry modules including diagnostics: 1028

Perturbation-capable target remains ~70-80 polynomial escape-time fractals.
Currently routed to GPU perturbation: 9 IDs (julia + 8 generic escape-time IDs).
Older 370-count planning rows are retired.
```

---

## P0 — MUST SHIP NEXT

**All open (unchecked) items in this section remain P0 until resolved.**

### P0-1: Critical Render Regressions

- Done: **GPU artifact at z≈5.10e+6** — Color blocks/grid artifacts appear despite perturbation shader ✅ FIXED 2026-04-05
  - **Root cause:** Delta overflow check in `escape_time_perturb_gpu.frag:165` used threshold `1e6` which was too aggressive
  - **Fix:** Changed threshold from `1e6` to `1e12` to avoid false triggers at deep zoom
  - **Verified:** All 350 fractals render correctly (fractal_render_audit_test.dart passed)

- [x] **FractalViewControls parameter mismatch** ✅ FIXED 2026-04-05
  - **Issue:** `fractal_viewer_screen.dart` called `FractalViewControls` with old parameter names
  - **Fix:** Updated to match current widget signature (`onOpenMoreActions` → removed, `onEnterFullscreen` → `onToggleFullscreen`)

- [x] **KIFS Menger Sponge stuck on "Loading shaders..."** — 3D fractal not loading ✅ FIXED 2026-04-05
  - **Root cause:** SkSL compiler doesn't support `%` operator on integers or `clamp(int, int, int)`
  - **Fix:** Replaced with integer-division modulo trick and `float(clamp(float(...)))` pattern
  - **Files fixed:** `shaders/quaternion_julia_2d_gpu.frag`, `shaders/menger_sponge_gpu.frag`, `shaders/menger_3d_slice_gpu.frag`
  - **Verified:** All 14 3D shaders compile successfully (shader_3d_diagnostic_test.dart passed)

- [x] **All 3D fractals broken** — Raymarching not working ✅ FIXED 2026-04-05
  - **Root cause:** Same SkSL incompatibility issues in 3D fractal shaders
  - **Fix:** Applied SkSL-compatible replacements to all affected 3D shaders
  - **Verified:** Build succeeds, all tests pass (864+ passed)

### P0-2: User-Reported Blockers (2026-02-25)

- [x] GPU→CPU fallback too slow when zooming deep; reduce hysteresis/threshold so CPU engages faster
- Done: **Controls too big/too intrusive** — Redesign for smaller, less cluttered UI ✅ 2026-06-06
  - Replaced modal bottom sheet (38% screen height) with semi-transparent HUD overlay
  - Game-like glass-morphism HUD with compact sliders, palette chips, and action buttons
  - Tap-outside-to-dismiss behavior (like game HUD)
  - Fractal visible and updating behind controls
  - New: `fractal_controls_hud.dart` overlay widget
  - Changed: viewer FAB toggles overlay instead of opening modal
  - Tests: 5 new HUD tests + all 18 existing controls tests pass
- Done: **3D fractals not working** — Investigate 3D pipeline/shaders and fix ✅ FIXED 2026-04-05
  - **Root cause:** SkSL `%` and `clamp(int, int, int)` not supported
  - **Fix:** See P0-1 items above
- **App icon visual sign-off** — adaptive launcher and store-art inputs exist; visual presentation acceptance remains open (details in Launch Visual Audit Handoff below).
- [x] **Improve catalog thumbnails** — Larger view size, higher-quality renders ✅ 2026-08-29
  - Raised bounded capture/decode width to 384 px with high-quality filtering
  - Increased thumbnail detail caps to 24 web / 40 native iterations and 24 colors
  - Added layout-aware cache keys so portrait grids never reuse square captures
- [ ] **Visual playtest audit** — cover both Explore groups and all 200 research-library definitions. Check true module defaults, runtime previews, and first viewer renders. Run CPU checks where a native CPU formula exists. Preserve formulas and log failures. The broad audit remains partial: the inventory now records captures for 187 of 1,028 Explore IDs (841 remain uncaptured), and all 200 research definitions have no app renderer. First-view evidence is recorded for 14 Explore rows; CPU formula coverage remains partial. See `VIS-005` and `VIS-006` below.

### Visual Fidelity Audit — current queue

#### Now


  - [x] **VIS-006-BATCH-18 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU module-default captures reconciled selected/generated/failed/skipped as 10/10/0/0; all ten default images passed image health. In-app runtime GPU previews passed 10/10 at 384x346. Per-ID paths, defaults, and actual image metrics are recorded in `docs/planning/visual-audit-inventory.json`; mathematical oracles are skipped because no reference oracle is registered. Defaults: `build/test_output/vis006-batch18-defaults/`; runtime previews: `build/test_output/vis006-batch18/`; test: `integration_test/catalog/vis006_batch18_runtime_preview_test.dart`. No formulas or defaults changed.
  - [x] **VIS-006-BATCH-14 — Capture defaults and runtime previews for the next ten uncaptured Explore modules.** Strict forced-GPU module-default captures reconciled selected/generated/failed/skipped as 10/10/0/0; all ten default images are 256x256 with strict image-health pass. Actual runtime catalog GPU previews passed 10/10 at 384x346. Per-ID artifacts, image metrics, shader references, and native CPU formula registration (correctness NOT_CHECKED; no formula for Zeta Newton) are recorded in `docs/planning/visual-audit-inventory.json`. The ten math oracles are NOT_CHECKED because no stable reference oracle is registered. Default artifacts: `build/test_output/vis006-batch14-defaults/`; runtime previews: `build/test_output/vis006-batch14/`; test: `integration_test/catalog/vis006_batch14_runtime_preview_test.dart`. No formulas or defaults changed.

- [x] **Initial seven-module GPU batch (historical VIS-006 evidence).** Captures or runtime previews are recorded for `core.burning_ship`, `core.four_wing`, `core.julia`, `core.lorenz_2d`, `core.mandelbrot`, `core.rossler_2d`, and `core.thomas_attractor`. Visual findings for Four-Wing, Lorenz, Rössler, and Thomas remain follow-ups; this batch does not complete the broader goal. See `goals.json` and the inventory artifact references.

- Done: GPU deep zoom not switching to CPU at all; adjust fallback thresholds/hysteresis
- [x] **Panning bugs at high zoom** — Fixed 2026-08-12 by migrating
  camera/render vectors from Float32-backed `vector_math` to
  `vector_math_64`; verified at `1e12` zoom and from viewport-edge gestures
  (`fractal_view_state_test.dart`, `fractal_renderer_gesture_test.dart`)
- [x] **Auto-zoom not continuous** — fixed: zero-dwell transitions between zoom legs; elapsed-time animation, speed changes, and interruption/resume are covered by auto-explore service/planner tests ✅ verified 2026-10-03
  - **Verified:** `flutter test test/features/auto_explore/auto_explore_service_test.dart test/features/auto_explore/auto_explore_zoom_planner_test.dart` (48 tests passed)

## Launch Visual Audit Handoff

Canonical plan: [`docs/planning/visual-fidelity-audit-next.md`](docs/planning/visual-fidelity-audit-next.md). The thumbnail decision is resolved: 320×320 launch-set thumbnail media outputs, no static catalog thumbnail bundle; 256×256 staged smoke is allowed. High-resolution hero stills remain a separate configurable output.

### Now

None: the current Featured Launch Set Chromium smoke and 320×320 GPU capture gates are complete. Remaining launch-media selection and icon visual sign-off require product-owner judgment.

### Blocked / Needs decision



### Done

## Documentation scope questions

### Blocked / Needs decision


### P0-3: Dynamic Iteration Adjustment

- [x] Increase max iteration slider beyond 500 (now 5000)
- [x] Automatically raise iteration count when zooming in (adaptive step-up)
- [x] Adaptive logic: start low, progressively increase based on zoom growth
- [x] Convergence detection: compare previous frame, stop when changes < threshold
- [x] Works on both GPU and CPU fallback paths

---

## P1 — HIGH PRIORITY (Deep Zoom & GPU Quality)

### P1-1: Perturbation Theory Improvements

#### P1-0: Escape-Time Shader SkSL Fix (COMPLETED 2026-04-05)
- [x] **Escape-time shader GPU compilation fix** — 204 shaders had SkSL-incompatible `%` operator
  - **Root cause:** SkSL doesn't support `%` (modulo) operator on integers
  - **Fix:** Replaced `x % N` with `x - (x / N) * N` across all affected shaders
  - **Files fixed:** All shaders with `(schemeInt - 50) % 4` palette cycling
  - **Verified:** `buffalo_gpu.frag` now compiles on GPU (previously failed)
  - **Impact:** All escape-time fractals now render correctly on GPU instead of falling back to CPU

#### P1-1a: Fix Perturbation Artifact Bug (COMPLETED 2026-04-05)

- [x] Raised perturbation overflow threshold from `1e6` to `1e12` in `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`
- [ ] Follow-up only if artifacts recur: replace discontinuous fallback with smoother reference-orbit transition

#### P1-1b: Extend Perturbation to Julia Variants

**Target Fractals (Priority Order):**
- [x] `julia` - core Julia (2026-07-02: flat-render bug fixed; unified into
  escape-time wrapper via julia mode, `julia_perturb_module.dart` deleted)
- [x] `celtic_julia`, `buffalo_julia`, `burning_ship_julia`, `tricorn_julia`
  (2026-07-02: julia-mode flag reusing base deltas)
- [x] 26 preset-c julias (`f0143`-`f0176` series) routed as z²+c julia mode
- [ ] `phoenix_julia`, cubic/power/trig/perpendicular variants — need new
  shader deltas; deferred (see spec Out of scope)

**Implementation:**
- Julia variants use `uExtra2` shader flag: `dz0 = pixel offset`, `dc = 0`
- Each variant reuses its base formula's existing delta function (no new deltas)
- All julia variants now routed through unified `escape_time_perturb_module`
- `kJuliaVariantSpecs` table maps catalog IDs to (base formula, fixed c)
- F-series preset julias read `juliaCReal`/`juliaCImag` from module params

**Files:**
- `lib/core/modules/escape_time_perturb_module.dart` (unified wrapper + variant table)
- `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` (julia mode flag)
- `lib/features/renderer/policy/precision_ladder_policy.dart` (routing gate)
- `lib/features/renderer/policy/render_plan.dart` (resolver simplification)
- Deleted: `lib/core/modules/julia_perturb_module.dart`

#### P1-1c: Add Period Detection for Reference Orbit (COMPLETED 2026-07-02)

- [x] **Period detection shipped** in `computeEscapeTimePerturbOrbitBytes`
  (`lib/core/modules/escape_time_perturb_module.dart`)
  - Detects approximate cycles (eps 1e-9, max period 64) with a
    consecutive-pair confirmation so Phoenix's `(z, z_prev)` state is safe
  - On detection, stops iterating and fills the orbit texture tail by
    repeating the cycle bytes (byte-identical for exact cycles, ≤1 LSB for
    attracting cycles)
  - Orbit computation extracted to a pure, GPU-free testable function
  - **Verified:** `test/perturb_orbit_period_test.dart` (exact 1- and
    2-cycles byte-identical vs full iteration; chaotic center has no false
    positives; escaping center unchanged)

- [x] **Julia orbit encoding bug fixed 2026-07-02** — `julia_perturb_module.dart`
  still used the old 16-bit packing that mismatched the shader's 24-bit decode,
  degrading the Julia reference orbit to ~8 effective bits (decode error
  ~1.7e-2 vs intended ~4.8e-7). Now delegates to `packPerturbOrbitComponent`.
  **Verified:** `test/julia_perturb_orbit_encoding_test.dart`

### P1-2: Series Approximation (Deep Zoom Speedup)

**What it does:** Precompute early iterations as polynomial series, skip actual iteration when safe.

**Performance gain:** 10x-100x speedup at extreme zoom.

#### P1-2a: Series Approximation on GPU

**Implementation Approach:**
```glsl
// Add to escape_time_perturb_gpu.frag
uniform sampler2D uSeriesCoeffs;  // Texture with precomputed coefficients
uniform int uSeriesLength;         // Number of terms

vec2 computeSeries(vec2 dc, int n) {
    // Evaluate polynomial using Horner's method
    // Z_n ≈ sum_{k=0}^{N} a_k * dc^k
}

void main() {
    // ...
    for (int n = 0; n < MAX_ITERS; n++) {
        if (n < uSeriesLength && dc_magnitude_small) {
            Z_n = computeSeries(dc, n);  // Skip iteration
        } else {
            Z_n = fetchOrbit(n) + deltaIterate(n, dc);  // Full perturbation
        }
    }
}
```

**Files to Create:**
- `lib/core/modules/series_approximation.dart` — Coefficient computation

**Files to Modify:**
- `shaders/escape_time_perturb_gpu.frag`
- `lib/core/modules/escape_time_perturb_module.dart`

#### P1-2b: Series Approximation on CPU

**Implementation:**
```dart
// Compute series coefficients during reference orbit calculation
List<Complex> computeSeriesCoefficients(Complex c, int terms) {
    // a_0 = 0
    // a_1 = 1 (for Mandelbrot)
    // a_2 = 2*z_1
    // a_3 = 2*z_2 + 2*z_1^2
    // ... derive recursively
}
```

### P1-3: Smooth Coloring in ALL Shaders

**Current State:** Smooth-coloring code appears in multiple shaders, including `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`. No complete inventory or regression test verifies coverage across the applicable polynomial escape-time shader set.

**Target:** Audit all applicable polynomial escape-time shaders and add or confirm formula-appropriate smooth coloring. The earlier estimate of approximately 80 shaders has not been rechecked.

**Example Formula:** This expression is used by the perturbation shader. Check each recurrence and magnitude value before applying it to another shader.
```glsl
float smoothVal = float(it) - log2(log2(max(1e-12, finalMag2))) + 4.0;
```

**Shader Files to Audit:** (Priority order; these are review targets, not confirmed failures)
1. `shaders/legacy/escape_time/mandel_step_smooth.frag`
2. `shaders/legacy/escape_time/julia.frag`
3. `shaders/legacy/escape_time/burning_ship.frag`
4. Applicable files under `shaders/escape_time_family/`

See [`docs/engineering/performance/SHADER_OPTIMIZATIONS.md`](docs/engineering/performance/SHADER_OPTIMIZATIONS.md) for current coverage limits and checks.

### P1-4: Arbitrary Precision for Extreme Zoom (CPU)

**Current Limit:** Double precision ~1e12 with df2 shader, then arbitrary precision CPU.

**Implementation Options:**

| Approach | Pros | Cons |
|----------|------|------|
| Integer arrays (base 10^9) | Fast, portable | Complex implementation |
| `decimal` package | Easy | Slow, large numbers |
| MPFR bindings | Fast, proven | Native code, complex |

**Recommended:** Custom integer array implementation for performance.

**Files to Create:**
- `lib/core/math/big_decimal.dart` — Arbitrary precision arithmetic
- `lib/core/math/big_complex.dart` — Complex number with BigDecimal

### P1-5: True Plane Anchors (AR-Ready)

**From PRD:** "Integrate true plane anchors (vertical + horizontal)"

**Implementation:**
1. Detect dominant line/plane in fractal boundary via edge detection
2. Anchor navigation to detected geometry
3. Enable "tap to place" on fractal boundaries

**Status:** Not started, deferred.

---

## P2 — IMPORTANT PRODUCT POLISH

### P2-1: GPU Visual Quality

- Pending: **Smooth coloring** in all escape-time shaders (see P1-3)
- Done: **Palette texture system** — Pass palette as texture uniform
- [ ] **Color cycling animation** — Perturbation shader supports time shift; roll out beyond perturbation path
- [x] **User palette selection** — Select from viewer controls
- [ ] **Regression test** — Assert no banding artifacts

### P2-2: UI/UX Improvements

- Done: **Controls redesign** — HUD overlay shipped (`FractalControlsHud`)
- Done: **Controls snap/collapse** — 24px vertical handle swipe snaps
  closed/open; 48px touch target, existing accessible toggle retained
- [ ] **Overflow menu** — Existing secondary-action menu is present; circular surface correction is tracked by **VIEW-UI-02**. Further action regrouping remains Proposed; preserve direct-access guarantees.
- [ ] **Auto-pilot improvements** — Smooth path, dwell behavior
- [x] **Manual corrections** — Auto-explore yields to continuous gestures,
  adopts the corrected zoom/direction, and replans one-shot wheel/keyboard
  corrections (`auto_explore_service_test.dart`)

### P2-3: Preset & Export

- [ ] **Preset thumbnails** — Auto-generate on save
- [x] **Custom palettes** — Save/load gradients
- [ ] **Bookmarks** — Save coordinates + formula + palette
- Pending: **Share presets** — One-tap Instagram/X/WhatsApp
- [ ] **Frame lock** — Exact viewer-to-export fidelity

### P2-4: Catalog Hardening

- [x] Registry covers 543 escape-time entries + 38 raymarched 3D + shared/custom promotions = 1020 production fractals plus 1 scientific visualization (1028 debug/test modules including diagnostics)
- [ ] **PRD manifest loader** — `assets/catalog/prd_catalog.json`
- [x] ID lock/integrity tests
- [x] Filter/sort + list/grid toggle
- [x] Persist catalog view mode
- [x] **Add 4+ new formulas** — Catalog has grown beyond the old 370 baseline

### P2-5: Export Hardening

- [x] Export pauses auto-navigation
- [x] Separate Save vs Share
- [ ] **Resume policy prompt** — After export
- Pending: **Share QA** — WhatsApp/Instagram/X/gallery

---

## P3 — ENHANCED DEEP ZOOM (Googol-Scale)

### P3-1: Googol-Scale Architecture (10^100+)

**Target:** Enable zoom beyond 10^100.

**Components Required:**

| Component | Status | Files |
|-----------|--------|-------|
| Arbitrary precision math | 🔶 Planning | `big_decimal.dart`, `big_complex.dart` |
| Reference orbit (big float) | 🔶 Planning | `escape_time_perturb_module.dart` |
| Series approximation (GPU) | 🔶 Planning | `series_approximation.dart` |
| Delta iteration (big float) | 🔶 Planning | `escape_time_perturb_gpu.frag` |
| Period detection | 🔶 Planning | `escape_time_perturb_module.dart` |

### P3-2: Perturbation for All Polynomial Fractals

**Target:** ~80 fractals total with perturbation support.

**Progress:**
- Currently routed: 9 IDs (`julia` + 8 generic escape-time IDs)
- Julia variants: ~30 candidates (core `julia` done; variants still open)
- Other polynomial: ~40 candidates

**To Implement:**
1. Add delta formulas for all unique polynomial patterns
2. Create universal perturbation wrapper
3. Add to `kPerturbableEscapeTimeIds`

### P3-3: Chunked Rendering for Extreme Zoom

**Why:** At googol-scale, single-frame render may be too slow.

**Solution:** Tile-based parallel rendering with edge feathering.

```dart
// Divide viewport into NxN tiles
// Render tiles in parallel
// Stitch with edge blending
class ChunkedRenderer {
    List<ui.Image> tiles;
    Future<void> renderTile(int x, int y);
    ui.Image stitchTiles(List<ui.Image> tiles);
}
```

---

## P4 — NEW FRACTAL FORMULAS

### P4-1: New Escape-Time Fractals

- [x] **Target met:** Catalog grew beyond the old 370 baseline to 1014 production fractals.
- Pending: Next formula work should be quality-gated: only add researched formulas with tests, stable IDs, and shader assets.

### P4-2: New 3D Fractals

- Done: 3D shader compatibility blockers fixed.
- Pending: Next 3D work should prioritize visual QA and thumbnails over raw count.

---

## COMPLETED ITEMS

### Deep Zoom
- [x] Perturbation theory shader (9 routed IDs: Julia + 8 generic escape-time IDs)
- [x] Double-float shader (`mandelbrot_df2.frag`) for 5e6-1e12
- [x] Reference orbit cache (LRU singleton)
- [x] Deep zoom precision policy with hysteresis
- [x] Dynamic iteration scaling with zoom

### Rendering
- [x] GPU-primary with CPU fallback
- [x] Tile-based CPU renderer (96px, spiral, cancel-on-gesture)
- Done: Smooth coloring in perturbation shader
- Done: Palette texture support + cached sampler adapter
- [x] **Batched orbit-texture rasterization** (2026-07-02) — shared
  `rasterizePerturbOrbitBytes` (one `drawVertices` call) replaces the
  per-pixel `drawRect` loops duplicated in both perturbation modules
  (~4,000 draw ops per navigation step → 1; measured 3.33ms → 1.38ms per
  build at max iterations). Byte-exactness locked by
  `test/perturb_orbit_texture_test.dart` (software rasterizer) and
  `integration_test/rendering/perturb_orbit_texture_gpu_test.dart`
  (real GL pipeline; run with `-d linux`, needs `xvfb-run` when headless)

### Quality
- [x] 64 palette support + selector
- [x] Screen-reader labels
- [x] GPU→CPU threshold tuning
- [x] Catalog integrity tests

### Testing
- [x] Focused TODO refresh checks passed: catalog integrity, controls HUD, palette texture/cache tests
- [x] 19 integration test files
- [x] Golden tests (phone/tablet × dark/highContrast)
- [x] Semantic audit

---

## CPU PATH — MAINTENANCE ONLY

**Policy:** No further performance investment.

**Maintained for:**
- Emulator testing
- Broken GPU fallback
- Extreme zoom beyond GPU capability

**Current capabilities:**
- Double precision
- Tile-based progressive rendering
- 2x2 AA refine pass
- Smooth escape-time coloring

---

## OUT OF SCOPE

- **Arenaton** — Not part of this repo
- **Video recording** — Deferred
- **Runtime shader compilation** — Deferred
- **User-defined formulas** — Deferred (would require interpreter)

---

## FILE MANIFEST

### Critical Files to Modify

| File | Change | Priority |
|------|--------|----------|
| `shaders/escape_time_family/core/escape_time_perturb_gpu.frag` | Add smoother fallback / series approx if needed | P1 |
| `lib/core/modules/escape_time_perturb_module.dart` | Period detection, more polynomial IDs | P1 |
| `lib/core/modules/builders/escape_time_catalog.dart` | Add perturbation configs | P1 |
| `lib/features/renderer/policy/precision_ladder_policy.dart` | Threshold tuning | P2 |
| `lib/features/renderer/cpu/cpu_fractal_renderer.dart` | BigDecimal support | P3 |

### Files to Create

| File | Purpose | Priority |
|------|---------|----------|
| `lib/core/modules/series_approximation.dart` | Series coeff computation | P1 |
| `lib/core/math/big_decimal.dart` | Arbitrary precision | P3 |
| `lib/core/math/big_complex.dart` | Big complex number | P3 |
| `lib/core/modules/perturbation_catalog.dart` | Universal perturbation builder | P3 |

---

## RESEARCH SOURCES

### Perturbation Theory
- K.I. Martin — "Perturbation techniques for the Mandelbrot set"
- Fractalforums.com — "Perturbation Theory" (1000+ posts)
- Deepzoom.com — Practical perturbation implementation

### Series Approximation
- Paul Derbyshire — "Optimizing Mandelbrot Computation"
- Smart Internet — Series approximation algorithms

### Implementation References
- FractInt — Classic fractal software (C, historical)
- KFract — Open source perturbation
- Mandelbrot Explorer — Modern Windows app

---

## SUCCESS CRITERIA

| Milestone | Verification |
|-----------|--------------|
| No artifacts at z=5.10e+6 | Visual test, screenshot comparison |
| 3D fractals render | Launch app, navigate to Mandelbulb |
| Julia perturbation | Zoom Julia to 1e10, verify smooth |
| Series approx 10x speedup | Benchmark frame time before/after |
| Googol-scale zoom | Zoom to 10^50, verify no precision loss |

---

## NOTES

- **Perturbation ≠ Universal** — Only ~80/370 fractals can use it
- **IFS/Attractors/Cellular** — Require completely different deep zoom strategies (if any)
- **Series approximation** — Only helps when zoomed into areas that escape late
- **Period detection** — Critical for stability at extreme zoom
