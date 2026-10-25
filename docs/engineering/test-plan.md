# Verification plan

## Production release defaults

The release dispatcher, shell publisher and CI configuration default to Play
`production`/`completed`; GitHub creation defaults to a published release.
`test/scripts/test_gitlab_release.py` covers both release targets, unset/empty
values, explicit internal/draft overrides and consistent shell/CI defaults.
`test/scripts/test_generate_release_evidence.py` retains the artifact/device gates.
Run `python3 -m unittest discover -s test/scripts -p 'test_*.py'` and
`env -u GITLAB_CI bats test/scripts/*.bats` for offline verification.
These checks make no live publication and do not qualify installed-device behavior.
GitLab execution remains deferred under the [current owner policy](../../PRD.md#independent-platform-release-policy). The [independent-platform route](release/MULTIPLATFORM.md#independent-platform-release-campaign) preserves lane-local qualification and production defaults; the older GitLab resumption note is historical, not authorization to dispatch or publish.

## Common offline gate

Run from the execution checkout root with the pinned Flutter 3.44.6 SDK and provisioned Python/Bats tooling:

```sh
flutter pub get --offline --enforce-lockfile &&
flutter analyze --no-pub &&
flutter test --no-pub &&
python3 -m pytest test/research test/scripts -q &&
bats test/scripts/*.bats
```

The preflight regenerates checkout-local metadata without changing the lockfile. A full gate requires every terminal stage result; targeted unittest runs above are not a substitute for the complete Python family. See [the export-preparation runbook](runbook.md#offline-check-export-preparation) for the bounded native-assets repair and its dated source-bound results. ACAD-008-74 is done in `7ae1dbd6`; this does not qualify unintegrated feature candidates, device/browser journeys or a later source snapshot. No app suite was rerun by this documentation pass.

## Current quality-first verification frontier

Owner order: verify the compact catalog-back control and circular overflow surface (`VIEW-UI-01`, `VIEW-UI-02`), then assess the diverse catalog pilot (`CAT-QUALITY-01`) before its defect repairs (`CAT-QUALITY-02`). UI changes require actual-viewer layout/interaction and same-state image checks; pilot promotion requires attractive defaults, useful controls and matching PNG output with honest mathematics and accessibility. Both viewer corrections have local implementations; the wrapped-rail and keyboard/semantics follow-ups are `d79b2eb0` and `72d08ba1`, and circular overflow is `06f6ec46`. The 247-test home/viewer/control/coral union passes on Flutter 3.44.6 / Dart 3.12.2, including the corrected compact-Back keyboard selector and coral render checks at zoom 0.85, 6 and 10. This is focused host evidence, not a whole-suite, device or store pass. Earlier widget captures used substituted Roboto and a blank renderer. Matched native Linux/Xvfb evidence now covers 16 EN/ES pairs at widths 320/768/1024/1440, portrait/default and landscape/2× text/high contrast/large targets, using the real alternated_iteration shader and native font fallback without test-font loading. The baseline selectively restores the two viewer chrome files from `14a9eca4` on otherwise current `f90a3681` sources; it is not a complete historical app build. Both sides initialize accessibility before mounting: the original attempt with live toggling failed on the historical text pill's TextStyle interpolation and remains failed evidence, not a fixed production bug. The historical observation harness omits the absent tooltip and current overflow-size acceptance; the current harness retains its stronger assertions. All 32 capture cases and 228 viewer/control tests pass; full candidate analysis, formatting and independent source review pass on Flutter 3.44.2 / Dart 3.12.2. All 32 PNGs decode at expected dimensions. Back widths measure 157.7–264.6px historically versus current 48/56px; inspected 320px comparisons show the title beside Back, the portrait rail no longer clipped at the right edge, and a matching circular overflow. Enlarged landscape titles still ellipsize. The native Linux cases also open the controls HUD and verify that explicit catalog Back pops directly; viewer widget tests separately verify system Back dismisses the HUD first. Xvfb reports Mesa llvmpipe, not hardware acceleration; synthetic viewport states, native font fallback and selective historical chrome do not establish bundled production typography, full historical pixel equivalence, live accessibility-setting transitions, device rotation or screen-reader acceptance. Physical-device interaction and screen-reader qualification remain required. Viewer task acceptance and the quality pilot remain open. Existing regressions cover direct/system Back, capture/export states, safe areas and longest localized titles across the 128-case widget layout matrix; 16 paired widget-chrome captures used substituted Roboto and a blank renderer and are not production-typography, device or GPU acceptance.

The Play-only 1.1.108 candidate retains every release gate. The proposed camera-local 3D pan repair is not integrated: independent review reproduced zero visible Luminous pan and found changed saved-preset/import/history framing, including vertical sign and some zero-pan camera orientation. Its owner question is unanswered; no migration or compatibility waiver is claimed. Existing camera behavior is retained and the limitations remain a release risk.

The existing completed manual-correction and palette items must not be treated as fresh planned features. Manual-correction regressions have an existing target at `test/features/auto_explore/auto_explore_service_test.dart`; their prior completion is not a new test pass here. Retain regression coverage when refining those controls, and keep full platform/export qualification separate.

## Automated checks

CPU renderer teardown: `test/a11y/screens/viewer_debug_report_a11y_test.dart`
retains contrast, tap-target and naming assertions and checks that cancellation
during unmount emits no exception. The reproduced failure is fixed by invalidating
the render job before cancelling the worker in `CpuFractalRenderer.dispose`.
Focused candidate verification passed all 28 tests and five repeated contrast
cases on Flutter 3.44.6; full host qualification is recorded separately.

The release-dispatch regressions in `test/scripts/test_gitlab_release.py` cover
Play-only target/track/commit binding and the retained protected-ref, build and
evidence barriers. The focused 16-test suite passed locally during preparation;
this verifies dispatch/configuration fixtures, not a completed CI or store release.

Run from the repository root with the Flutter SDK and dependencies available:

| Risk | Command or test target | Observable expected result |
|---|---|---|
| Dart correctness and lint | `flutter analyze` | No analyzer errors; resolve warnings according to repository policy. |
| Unit and widget behavior | `flutter test` | All selected tests pass; any skip is reported with its reason. |
| Integration flows | `flutter test integration_test/` on a configured device | Catalog-to-viewer navigation, controls, and tested export flows complete without uncaught errors. Device and platform must be recorded. |
| Shader/module contract | `flutter test test/shaders/` and relevant module tests, including `test/core/modules/builders/uniform_layout_test.dart` and `test/modules/mandelbulb_shared_pan_target_test.dart` | Selected shader assets load/compile in the test backend; source and asset tests check their declared contracts; shared ray-marched 3D frame slots carry time, resolution, pan, zoom, and rotation consistently across the shared builder and custom modules. This is not proof of hardware GPU output or visual camera feel. |
| Real GPU rendering | `flutter test integration_test/rendering/` on a supported desktop/device GPU | The selected rendering assertions and image checks pass on the named backend. Preserve screenshots/reports when the target test emits them. |
| Full catalog visual audit | `python3 scripts/audit-linux-fractals.py` on Linux with its documented display/GPU setup | Audit report records each selected module's render result and visual metrics. A timeout or omitted module is incomplete evidence. |

CI's current validation and device integration job definitions are in `.gitlab-ci.yml`. The optional Linux catalog audit runs separately from the standard validation job. A test's presence is not evidence that it passed; record the exact command, environment, and result for each acceptance claim.

## Risk-based scenarios

- Catalog: search, category display, list/grid state, and stable module identity.
- Viewer: module selection, configured default view, pan/zoom/rotation, reset, parameter changes, and accessibility semantics.
- Renderer: shader compile/load failure, GPU-health fallback, precision eligibility, cancellation during navigation, and a CPU formula's bounded render.
- Persistence: save and restore supported settings/presets; malformed stored values do not crash the app.
- Export/platform: verify file creation and share/wallpaper behavior on each supported platform; widget-level sheet coverage alone does not prove platform writes.
- Visual-audit qualification: verify true defaults, runtime previews, and the first viewer GPU frame separately. Run native CPU checks where supported, record unsupported/skipped checks, and preserve formulas while logging failures.
- Smooth coloring: run the focused regression set and reconcile coverage against the full applicable polynomial escape-time shader inventory. Passing sampled families does not establish complete coverage.
- Web: verify the browser preview separately; do not infer export, CPU precision, deep-zoom, or hardware-GPU parity from a successful page load.
- Playwright catalog smoke: with an active viewer session stored in
  `localStorage`, open `/?smokeModule=mandelbrot`. The explicit module must
  emit its opened and first-frame markers, and the canvas must be visible
  (`test/playwright/smoke-session-conflict.spec.mjs`).

## Accepted cross-platform release journey

Status: Accepted

Source: [Owner-approved release contract](../../PRD.md#active-release-contract), accepted in the 2026-10-11 repository interview. This section defines planned qualification, not an executed pass.

Run the same browse → customize → understand → export outcome on Android, web, and Linux. Representative module IDs are an engineering choice, not a catalog-wide certificate. Reuse `mandelbrot` and `mandelbulb` for the 2D/3D paths, plus one clearly qualified unverified/inspired entry to test honest disclosure.

For each target, record the build/source identity, device or browser, actual backend, module IDs, exact actions, logs, and saved PNGs. Check search/navigation, edited parameters/view, current formula or qualification, and preserved favorites/presets. Decode saved files and check selected dimensions and visible mathematical content. Compare the export with the edited viewer state without demanding pixel identity across different output resolutions. No silent loading/gradient/placeholder substitution counts as a mathematical export pass. Preserve bounded approximate catalog previews with explicit labels.

| Target | Planned verification path | Complete-journey status |
|---|---|---|
| Web | Extend the existing Playwright targets in `test/playwright/` to exercise an actual PNG download from the production web build. Verify downloaded bytes and browser errors, not just a first-frame marker. Build with `flutter build web --no-pub`. Record the supported browser used. | Unverified |
| Linux | Extend `integration_test/flows/user_flows_test.dart` and the existing export tests to save/decode real artifacts. Run `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` plus the exact added export target. | **Partial (2026-10-16):** native AMD Radeon RX 6800 XT GPU journey passed for `mandelbrot` and `mandelbulb`; saved PNGs decoded at selected 1280×720 with varied sampled pixels. The journey edited each viewer, checked current formula/qualification, and retained favorites/preset state. Full flow: 12 passed, 1 explicit Barnsley Fern default-view skip because runtime `pan.y=0.5` differs from declared `0.2`. The accepted Linux journey still needs an inspired/unverified sample, Spanish coverage, retained PNGs and human composition review. See [Linux backend evidence](rendering/renderer_backend_matrix.md#linux-image-creation-journey-2026-10-16). |
| Android | Exercise the same flow on a named Android device and verify the actual MediaStore destination and visible/readable exported image. Record the selected device ID and the exact integration command. Emulator/software rendering and physical-device results remain separate. | **Unverified (2026-10-16):** `adb devices -l` returned no attached devices in this qualification attempt. No Android journey or gallery readback ran. The shared Linux journey is not Android evidence; its local export-directory PNG check does not prove MediaStore persistence or gallery visibility. Pending a connected named Android device: run `flutter test integration_test/flows/user_flows_test.dart -d <device-id> --dart-define=FORCE_GPU_RENDER=true --reporter expanded --plain-name 'Android 2D and 3D journey saves edited mathematical PNG artifacts'` (after adding/confirming that platform-specific target and MediaStore readback), and record both saved PNGs decoded at selected dimensions plus gallery query/readability for each. Emulator-only results must be labeled separately and do not establish physical-device behavior. |

Existing widget, compiled-shader, golden, and browser smoke results remain useful lower-level evidence. They do not close this complete journey. Unsupported environments or missing devices are reported as gaps, never substituted with fabricated results. macOS/Windows, video export, and whole-catalog mathematical certification are excluded from this new gate.

## Limits and outstanding coverage

Real-device MediaStore and wallpaper verification, real-device gesture feel/deep zoom, and broad visual audit work remain listed in `TODO.md` and the current platform/audit documents. The visual-inventory validator checks ID counts, references, and shader paths; it does not prove GPU image quality, a first viewer frame, or native CPU-formula coverage. The inventory records capture/runtime-preview evidence for 187 of 1,028 Explore rows; 841 remain uncaptured. All 200 research definitions have no app renderer. First-view evidence is recorded for 14 Explore rows; `cpu_formula` is `not audited` in 1,145 of the 1,228 rows. These totals describe recorded inventory evidence, not a fresh GPU or artifact qualification. Historical run counts in `PRD.md` are dated snapshots, not current verification receipts. No claim is made here that these checks ran during documentation maintenance. For REL-JOURNEY-03-ANDROID, offline inspection found no attached ADB device (`adb devices -l`); Android journey execution and actual MediaStore/gallery readback remain pending live qualification, not a pass or an offline blocker.

## Gaussian moat visualization

Status: Accepted; native Linux and production Chromium journey evidence recorded below. Android and full cross-target qualification remain pending.

Source: [Accepted feature](../../PRD.md#gaussian-moat-walking-visualization) and [bounded specification](spec.md#gaussian-moat-walking-visualization). The Linux and web receipts below establish only their recorded environments and default-domain scenario; they do not qualify Android, physical GPU behavior, full responsive/localization/accessibility coverage, or cap performance.

- Mathematical fixtures: ordinary-prime norms off-axis; axis primes congruent to `3 mod 4`; origin/units/composite norms excluded; all signs and conjugates; bounded sieve limits; invalid/oversized inputs; points outside the computation domain. Expected values must be independently specified, not generated by the predicate under test.
- Graph fixtures: inclusive squared-distance equality, just-outside steps, distinct endpoints, deterministic small components, visited-path independence, unreachable targets, trapped walk versus full component, and conservative boundary-truncation status. No viewport-only or trapped-path assertion proves a global moat.
- UI fixtures: catalog identity `gaussian_prime_lattice`, default domain/step display, tap/coordinate round trips after pan/zoom and pane resizing, valid/invalid steps, undo/reset, module switch, parameter changes and stale-result cancellation. Preserve existing favorites/presets and other module gestures.
- Accessibility: keyboard selection and movement alternatives, useful coordinate/count/status semantics, non-color-only states, high contrast, EN/ES, 320px width and enlarged text. Provide reduced-motion behavior if transitions animate.
- Export: download/save the actual PNG containing exact points, selected path and enabled component overlay. Decode it, verify selected dimensions, and compare the represented edited state. Check capture placement, compare/Fourier panes and incompatible visual effects rather than relying on widget presence.

Focused model/widget targets: `test/modules/gaussian_moat_model_test.dart` and `test/features/viewer/gaussian_moat_walk_test.dart`. Journey: `integration_test/flows/gaussian_moat_journey_test.dart`. Existing regression anchors: `test/modules/tenth_wave_fractal_additions_test.dart`, `test/modules/module_registry_widget_test.dart`, `test/fractal/fractal_renderer_gesture_test.dart`, `test/features/viewer/every_module_viewer_walk_test.dart`, and `test/export/`.

Qualification evidence (Flutter 3.44.6 / Dart 3.12.2): focused model/widget/registry/gesture/export regressions passed 349 tests and `flutter analyze` reported no issues. The widget matrix covers 320/768/1024/1440 widths, EN/ES and 1×/2× text, invalid-bound handling, and keyboard candidate focus. Native Linux/Xvfb journey enters `gaussian_prime_lattice` through the searchable catalog card (not a preselected viewer), opens Walk, commits the `1+i` → `1−i` step, pauses growth, and saves pre/post HD PNGs through the viewer export sheet. Both decode as 1280×720 with changed RGBA pixels. A measured initial Step target was 146.5×40 logical pixels (semantics rect agreed), failing the 48×48 minimum. The Gaussian Walk button style now explicitly uses padded tap targets and standard visual density; the journey asserts both dimensions are at least 48px and passes. Linux/Xvfb is not physical-GPU or Android storage evidence.

The production web runner target is `test('Gaussian catalog walk exports a frozen paused PNG')` in `test/playwright/web-image-creation-journey.spec.mjs`. Run with `flutter build web --release --no-pub && PLAYWRIGHT_PORT=20102 /home/xel/git/trebuchet-dynamics/flutter-fractal-forge/node_modules/.bin/playwright test test/playwright/web-image-creation-journey.spec.mjs --project=chromium --grep 'Gaussian catalog walk'`. Chromium passed the actual catalog → Walk → select → keyboard Step → growth/pause → downloaded PNG journey; before/paused downloads decoded to 1280×720 and their full RGBA hashes differed, with no browser errors. The single observed B=32 run reported 868 points, component size 824, 534.8ms generation-to-ready and 64,000,000 bytes Chromium JS heap before/after. These are one-run observations, not caps, latency guarantees, native memory, or cross-target performance claims.

Android is still pending: no named Android device, journey, MediaStore/gallery readback, or device PNG was available in this run. Also pending are B=128 cap/chunk/job/cancellation telemetry and target-specific real timing/memory, complete live EN/ES/responsive/keyboard/screen-reader checks on each platform, and human review of exported mathematical composition. Use `flutter test integration_test/flows/gaussian_moat_journey_test.dart -d <device-id> --reporter expanded` on the named Android target and record physical-device and emulator evidence separately; do not infer Android qualification from Linux or Chromium.

Measure capped-domain generation/component duration and memory on each target; record source, device/browser, backend and input bounds. The [refined hard workload and scheduling limits](spec.md#workload-and-scheduling-limits) define planned bounded execution; they are not measured latency promises or a changed Play release gate. No runaway task, stale paint or unbounded allocation is acceptable. A browser loading timeout is infrastructure failure, not mathematical RED or GREEN. Unit, browser, emulator and physical-device evidence remain separate.

## Prime-walking growth and quaternion slice checks

Status: Accepted

Sources: [Gaussian growth design](spec.md#bounded-radius-growth-and-visual-direction) and [quaternion companion](spec.md#prime-norm-quaternion-companion). These checks are planned and have not run.

Growth: test manual radius scrub, play/pause, monotone components at fixed domain, start-prime retention, invalid path resets, superseded-result rejection, reduced-motion manual stepping, and explicit truncated status throughout boundary-limited animation. Preserve existing 2D gestures and export the selected radius/state, not a racing frame.

Quaternion fixtures: independently specified prime/composite norms, zero/units, signs, permutations, nonzero fixed `d`, invalid/oversized inputs, exact 4D squared distance with fixed `d`, inclusive threshold and truncated slice boundaries. Assert that graph connectivity is camera-independent and explicitly slice-only. Test depth-overlap selection, projection round trips, rotation/pan alignment, coordinate-list/keyboard alternatives, EN/ES disclosures, dark/high-contrast/narrow/enlarged-text states and navigation cancellation.

Planned targets: `test/modules/prime_norm_quaternion_test.dart`, `test/features/viewer/prime_norm_quaternion_walk_test.dart`, `integration_test/flows/prime_norm_quaternion_journey_test.dart`. Run `flutter test test/modules/prime_norm_quaternion_test.dart test/features/viewer/prime_norm_quaternion_walk_test.dart --reporter expanded`, `flutter analyze`, and that journey on named Linux/Android targets. On headless Linux, wrap the native integration command in `xvfb-run -a`; without a display the application can build but fails to establish its debug connection. Xvfb qualifies native desktop journey execution only, not physical GPU performance. Extend the existing production web runner and record its actual target. Decode saved/downloaded PNGs, checking dimensions, selected slice, projected points and enabled walk/component overlay. Report emulator and physical-device evidence separately.

Measure domain generation, component search, animation recomputations, memory and frame stability at the specified caps on each target. Keep budget-dependent results explicit; no guessed latency or throughput value is an executed acceptance result. A mathematical predicate test is not a rendered 3D or browser qualification.

## Prime-walking refined acceptance matrix

Status: Accepted

Source: owner request to refine the existing Gaussian/quaternion tasks without implementation. Check [layout and interactions](spec.md#ui-layout-and-interaction-contract), [bounded scheduling](spec.md#workload-and-scheduling-limits) and [quaternion picking](spec.md#quaternion-layout-and-picking-details). Every application check below is planned. Independent fixture expectations and measured runtime receipts are required; a graph, test file or claimed task completion is not a pass.

| Existing task | Required discriminating check and expected result |
|---|---|
| `GAUSS-MOAT-01-MAP` | Verify primes `1+i`, `1-i`, `3`, `3i` and reject origin, units, `2`, `2+2i`. At `B=1`, only the four `(±1,±1)` points are vertices. Test all supported signed transforms and out-of-domain labels. At 320/768/1024/1440 logical-pixel widths, EN/ES and text scales 1/2, controls remain reachable without overflow; tap mapping uses the reduced plot pane. Above-cap, noninteger, NaN/infinite inputs fail before allocation. |
| `GAUSS-MOAT-02-WALK` | `1+i` to `1-i` has squared distance 4: Step succeeds at `k=4` and is disabled at `k=3`; selecting alone never changes path. Reject repeat/composite/out-of-domain candidates. In the `B=1` fixture, `k=2` yields singleton components; `k=4` connects all four primes, while boundary status stays truncated. Undo restores legality and Reset walk leaves camera unchanged. Delayed old computations cannot paint after newer input. A real paused PNG includes selected path/overlay and selected dimensions. |
| `GAUSS-MOAT-04-GROWTH` | With a controllable clock and deliberately slow computation, assert one active job/one replacement input, no queued timer ticks, at least 500ms completed-state dwell and increasing-radius component inclusion in a fixed domain. Slider drag does not run every intermediate graph; release commits the latest value. Pause/navigation/background/export cancel progression; reduced motion prevents autoplay. Export cannot combine mismatched graph/text/input states. |
| `GAUSS-MOAT-03-QUALIFY` | Run the above UI/gesture/semantics tests and actual catalog → Walk → select → Step → component → growth → paused export journey on named Android/web/Linux targets. Check native keyboard focus, minimum 48px action targets, narrow/short/2× text layouts, EN/ES labels and visible boundary states. Decode PNGs and inspect real overlays, not widget presence alone. Record cap/budget telemetry and unavailable environments separately. |
| `QUAT-NORM-01-SLICE` | Accept `(1,1,0,0)` with norm 2 and `(1,1,1,0)` with norm 3; reject origin, `(1,0,0,0)` and `(2,0,0,0)`. Exercise positive/negative/nonzero `d`, all domain/slice caps and fixed-d labels. Rotation leaves coordinates/norms unchanged. Orthographic test camera can overlap those two valid points; frontmost-depth and exact-coordinate tie rules plus the list alternative select deterministically. No false Julia/4D/Hurwitz label appears. |
| `QUAT-NORM-02-WALK` | `(1,1,0,0)` to `(1,0,1,0)` has squared distance 2: Step succeeds at `k=2`, not `k=1`, regardless of camera. Preview does not move; repeat and cross-slice moves fail. Camera gestures do not select/commit. Changing `d` cancels stale graph work, resets path and revalidates root. Components use original-coordinate distances and conservative domain status. Frozen-snapshot PNG contains the selected slice/camera/path/overlay. |
| `QUAT-NORM-03-QUALIFY` | Actual companion-open → rotate → pick/list → Step → component → export journey on named targets; test occlusion, focus/screen-reader alternative, EN/ES fixed-d explanation, reduced motion, high contrast and the same responsive widths/text scales. Decode saved/downloaded output, verify selected state/dimensions and retain cap/performance measurements. Emulator-only storage is not physical-device acceptance. |

Instrumented cap runs use Gaussian `B=128,k=100` and quaternion `B=12,abs(d)=12,k=16`, plus default settings. Assert candidate ceilings 66,049/15,625, sieve limits 32,768/576 and neighbor-offset counts 316/256. Probe counters cannot exceed 20,871,484/4,000,000 for a full single candidate traversal. Ensure visited/queue/path and result retention remain bounded, no all-pairs/all-radius cache exists, and cancelled jobs are released. These ceilings are deterministic workload checks, not peak-RSS measurements.

For cooperative execution, instrument candidate/neighbor probe counts, wall-clock chunk durations, yield/cancellation checkpoints and stale-publication attempts. With a fake clock/controlled workloads, verify yielding after at most 1,024 probes or the 8ms chunk budget. On each real target, retain measured generation/search/paint timing, memory observations and responsiveness separately; scheduler/OS delay must not be reported as a guaranteed 8ms completion. No new throughput/fps claim is inferred from caps.

Run the existing planned model/widget/journey targets; add these scenarios to those files, not another parallel suite. Record exact added production-web target when implemented. `flutter analyze --no-pub && flutter test --no-pub` is the future regression Guard. It was not run as feature verification in this docs-only refinement.


## Zig-Zag Julia icon checks

[Accepted outcome and planner decisions](spec.md#app-derived-zig-zag-julia-icon). ICON-ZJ-01 obtains a real app-renderer capture and staged derivative/provenance proof; the same task prepares an isolated debug Android preview APK with source/asset hashes so existing VIS-003 can retain owner/device visual sign-off before canonical integration; ICON-ZJ-02 integrates only the approved candidate. The planning-only state is superseded for ICON-ZJ-01: real Radeon-GPU capture (three revised variants in one integration test), actual catalog-to-viewer saved-state regression (one integration test), 15 Python asset tests including genuine-stage regeneration, focused Flutter analysis, private launcher generation and ARM64 debug APK build pass. APK readback matches all five candidate input PNG hashes. Native-size/mask proof inspection records surviving principal centers but lost fine detail. Independent tooling review approves the exact unchanged four source hashes. The owner subsequently selected B/open spiral; its native viewer regression, 15 actual-stage asset tests, icon generation and private APK build/readback pass as well. The candidate is composition-selected but not installed, device-qualified, integrated as current branding or published. ICON-ZJ-01 preparation is complete and reviewed; its source/tooling files also pass 15 actual-stage Python tests and the B native viewer regression in the canonical checkout. VIS-003 installed-device sign-off and ICON-ZJ-02 remain open; no Android device is attached. Captures, source state, importable preset, transformation manifest, proof and private preview build remain separate evidence; no full app suite or public store acceptance is claimed.

- Add `test/scripts/test_app_icon_assets.py` to check raw capture/output hashes, complete saved app state, deterministic crop/resize/mask lineage, dimensions and configured resource coverage; reject missing/synthetic provenance. Staged candidates use the same checks before installation; the worker must provide a staging-root fixture rather than falsely validate only existing Recursive Ember files.
- Extend `test/scripts/test_play_store_listing.py` for icon-only fully opaque RGBA acceptance and transparent, wrong-size and oversize rejection; preserve legacy RGB acceptance and unchanged RGB-only checks for all non-icon groups. New delivered Play icon must be 32-bit opaque sRGB PNG, 512×512, at most 1024 KB.
- Run `dart run flutter_launcher_icons`, `python3 -m unittest test/scripts/test_app_icon_assets.py test/scripts/test_play_store_listing.py`, `scripts/update-play-store-listings.sh --validate-only`, `flutter test test/screens/home_screen_widget_test.dart`, `flutter analyze` and `git diff --check` during integration. These commands are planned, not passing feature evidence; listing `--dry-run` stages remote edits and is excluded.
- Inspect native 32/48/64px readability, light/dark surfaces and circle/squircle/rounded-square masks. Both principal spiral centers must remain distinguishable at 48px and inside Android's centered 66dp/108dp safe circle, with no UI, seam, halo, outer shadow or baked mask. Verify the actual saved state in the app viewer and the installed Android launcher; software-GL smoke and a proof sheet do not replace real-GPU capture or device sign-off. Other platform build/device acceptance and public Play propagation remain separate/unverified.


### Applied B assets and icon-only Play update

The explicit owner application/publication request is executed: 16 asset/provenance/resource tests, 11 home widget tests, full Flutter analysis, and 25 listing regressions pass in the coherent candidate. Canonical installed-resource tests and its home-render smoke pass too. The publisher permits fully opaque RGBA icons while keeping other groups RGB, discovers live locales, writes only `/icon`, and verifies full listing dictionaries plus other image groups before commit and in a fresh edit. Live committed readback validates all 15 locale icon hashes against `c22c4fde194800588d21ad3ef2047749bb6335ce4b3fff605c00b1a054396c41`; texts/video and non-icon images are unchanged. No release/binary/track update occurred. Remaining NOT_CHECKED: actual installed Android launcher/device presentation and public Play cache/review propagation. ICON-ZJ-02 and VIS-003 retain the device acceptance gap; no completed whole-feature qualification is claimed.

## Number wall verification

Status: Number Walls math and catalog/viewer integration have local native/offline coverage. All six Flutter Chrome state/replay cases pass on the current composition with the bounded invocation below, including active-module edit ownership and reentrant candidate staging. The [2026-10-25 composed host evidence](../qa/number-walls/2026-10-25/README.md) adds a completed production Chromium journey and supplemental native Linux rendering/export execution. Installed-platform qualification, the native test-driver receipt and release acceptance remain incomplete; these results do not qualify the merged tree or hardware GPUs.

NUM-WALL-01 owns independent integer-determinant reductions, six pinned sequence definitions, BigInt precision, prime rejection/unverified states, zero-denominator recovery, halo and cancellation. NUM-WALL-02 owns real catalog/viewer/thumbnail wiring, decimal-string persistence/import/deep-link compatibility and EN/ES accessible controls. NUM-WALL-03 owns manual randomizer/undo, zero-mask-preserving foreground/background/residue palettes, colour-only no-recompute and immutable same-cell PNG export. Exact commands and acceptance are in `tasks/items/NUM-WALL-01.md` through `tasks/items/NUM-WALL-05.md`.

Existing native integration tests are `test/number_walls/number_wall_catalog_test.dart`, `number_wall_state_test.dart` and `number_wall_viewer_test.dart` in that directory. They cover certified replay (including forged status and rejected visual flags), cancellation after newer parameter/camera/effect edits to the active module, listener-triggered candidate merging, six sources, exact Canvas/sampler pixels, real Home deep-link navigation, localized pending/error feedback for rejected or unverified startup restoration without a grid, and EN/ES controls at 320/768/1440 widths with 2× text, high contrast and reduced motion. The async determinant path avoids redundant modular division for already-canonical residues; its odd-prime fixture also checks negative and oversized matrix entries. Shader compilation, formatting and analyzer checks accompany them. These fixtures do not establish physical-device performance or installed accessibility acceptance.

The adjacent `test/services/test_screenshot_service_test.dart` fixture drives frames and waits for actual capture completion before asserting directory creation and tearing down temporary directories/logger state. Its invalid-key captures must settle to null; do not replace completion with a fixed number of zero-delay yields, pre-create the target directory or leave retry futures pending. Repeat the fixture in isolation and alongside logger/export tests when validating this seam.

Compatibility coverage also includes the existing `test/fractal/fractal_viewer_screen_widget_test.dart` cases “restores a durable session before the viewer is rendered” and “unknown restored module is rejected without mutating the viewer”. Keep their first-frame assertions unchanged: ordinary module visuals and HUD visibility restore at the synchronous commit boundary, while Number Walls visuals wait for certification. Rejected or superseded snapshots must not trigger completion/history work before controller attachment. Run the public-count, viewer-session-store and settings accessibility targets alongside these cases; reconcile counts against the delivered registry rather than a retained candidate's total.

NUM-WALL-04 records real Linux/browser grid parity, screenshots, responsive/cancellation measurements and decoded saved/downloaded PNGs. NUM-WALL-05 records installed Android, TalkBack and gallery readback separately. Fixtures must cover cross-rule zero denominators, singular/swapped pivots, nonzero odd-prime residues, signed Pagoda versus ternary-lift differences, a prime outside quick picks, composites/Carmichael numbers, malformed/oversized values, unverified long jobs and stale Apply/export/navigation races. Proposed benchmark limits are not measurements. A cropped or degenerate zero region is not a failed square-window theorem. No visual metric alone proves mathematical identity, app-derived beauty, live backend acceptance or release readiness.

Use the existing exact SDK/lockfile and full regression gates when implementing. Planner-selected default grid is 96x32 at nStart=64 and p=2; bounded stress reaches 256x64 and custom-prime validation, with timings/environment recorded rather than invented. Save native/browser matrices and PNG readback; keep unavailable device checks open. The native targets above exist; follow-up stress, export and installed-platform journeys still require their own evidence.

NUM-WALL-01 recovery: if Flutter/Chrome bootstrap cannot execute within bounded startup diagnostics, use the [pure-Dart math-browser route](spec.md#number-walls-math-browser-recovery) with the same independent fixture corpus, native Dart results and real sandboxed Chromium JavaScript results. Assert actual test-case/result set equality and cleanup. This is not a passing receipt for the failed Flutter command and does not replace later widget or real UI journeys. The shared 971-fixture math corpus has matching native Dart and sandboxed Chromium JavaScript results (`196b53dc`). This math-only result does not substitute for the required Flutter Chrome state/replay run.

On the provisioned Linux host, use the supported executable override below with pinned Flutter 3.44.6. The task-scoped launcher keeps Chromium sandboxing enabled and uses basic password storage only for the temporary test profile, avoiding the desktop key-store path implicated by the HTTP navigation stall. It does not load a user profile, modify the SDK or disable web security. The debug-mode default-grid reconstruction can exceed the harness's default 30-second case budget on this host; the approved two-minute case budget preserves every grid size and assertion. The current six-case run completes with the same bounded budget, original grid sizes and assertions. Do not raise that budget to conceal unfinished work; no interactive rendering latency is claimed.

```sh
CHROME_EXECUTABLE="$PWD/scripts/number-wall-chrome.py" \
  flutter test --no-pub --platform chrome \
  test/number_walls/number_wall_state_test.dart --reporter expanded --timeout 2m
```

Use the existing NUM-WALL-02-only OS-assigned-loopback exception, a temporary directory/profile and normal owned-process cleanup. This invocation does not grant that port exception to other tasks or qualify NUM-WALL-04/05.

### Composed Number Walls host journeys (NUM-WALL-04)

`integration_test/flows/number_wall_journey_test.dart` and `test/playwright/number-wall-journey.spec.mjs` exercise the production catalog, exact renderer, controls, stored-preset/session seams and export UI. The native fixture does not substitute test fonts, a placeholder renderer or a fake exporter. The browser loads the release bundle and decodes actual downloads.

The six sequence cases retain the documented 96×32, nStart=64, p=2 inputs. The outside-quick-pick replay uses p=97 at 16×4; it is not represented as the default grid. Both journeys reject stored composite 561 and unfinished `170141183460469231731687303715884105727` without replacing the committed wall, then apply the valid replay and export it. Style, randomize/undo and saved/reopened artwork are checked separately. Squares mod 2 at 256×64 supplies the completed stress case and a second cancellable request. No new formula, unbounded grid or release acceptance is implied.

Every artwork PNG is requested through the real HD export control (1280×720). Native readback checks every viewer/export cell against its committed matrix. Browser readback independently decodes the PNG and recovers every residue against the native **complete** field-colour table, including residues absent from that matrix. RGB quantization tolerance is one byte level per channel; alpha, residue identity and zero/nonzero classification are not relaxed. An ambiguous tolerant colour match fails. Browser screenshots also sample unobscured displayed cells; they are not substituted export renders. The inspector asserts an actual displayed cell's coordinates, modulus and residue.

Use the pinned SDK/cache from the repository gate setup and isolated XDG preferences under `$TMPDIR`. Real native rendering needs both defines below; without the runtime-thumbnail define the catalog fixture would retain its pending placeholder rather than qualify the card. The supported port-bound supplemental invocation is:

```sh
flutter run --no-pub -d linux --no-dds --no-devtools \
  --device-vmservice-port="$((AUTOWORK_PORT_BASE + 1))" \
  --host-vmservice-port="$((AUTOWORK_PORT_BASE + 1))" \
  -t integration_test/flows/number_wall_journey_test.dart \
  --dart-define=FORCE_GPU_RENDER=true \
  --dart-define=FORCE_RUNTIME_CATALOG_THUMBNAILS=true \
  --dart-define=NUMBER_WALL_ARTIFACT_DIR="$TMPDIR/native" \
  --dart-define=NUMBER_WALL_SOURCE="$(git rev-parse HEAD)"
```

Run the native command under an owned Xvfb with `-screen 0 1600x1200x24 -nolisten tcp` when needed. Stop only the owned runner after observing its terminal test aggregate; the worker's bounded wrapper performs that cleanup automatically. The integration-plugin warning remains: this is **supplemental native execution**, not a passing `flutter test ... -d linux` driver receipt. The pinned driver rejects `--host-vmservice-port` before tests start; its unbound raw VM listener is not allowed by this task's port policy. Preserve that gate as unavailable, as described in [the runbook](runbook.md#owned-linux-runtime-with-reserved-ports).

Build with `autowork-run timeout 900 flutter build web --no-pub --no-web-resources-cdn`. Serve `build/web` using an owned `python3 -m http.server "$AUTOWORK_PORT_BASE" --bind 127.0.0.1 --directory build/web`, then run the repository Playwright target:

```sh
autowork-run timeout 1000 env \
  PLAYWRIGHT_PORT="$AUTOWORK_PORT_BASE" PLAYWRIGHT_SKIP_WEBSERVER=1 \
  CHROME_DEVEL_SANDBOX=/usr/lib/chromium/chrome-sandbox \
  NUMBER_WALL_CHROMIUM="$AUTOWORK_CACHE/playwright-browsers/chromium-1217/chrome-linux64/chrome" \
  NUMBER_WALL_NATIVE_ARTIFACTS="$TMPDIR/native" \
  NUMBER_WALL_SOURCE="$(git rev-parse HEAD)" \
  npx --no-install playwright test test/playwright/number-wall-journey.spec.mjs \
  --project=chromium --workers=1 --reporter=line --output="$TMPDIR/browser"
```

The executable/sandbox-helper paths describe the provisioned host, not a portable install requirement. Chromium renderer sandboxing is requested; the retained CDP software-GPU record separately reports `sandboxed: false`. No SDK/browser security patch is used. Clean up the owned HTTP server and display. Native output must precede the browser run: a missing matrix is a missing prerequisite, never a skipped success.

Cancellation records distinguish request-to-delivery, cancellation settlement and the post-cancellation observation interval. Native schedules a real 50ms event-loop timer and bounds both delivery and subsequent settlement by a generous two-second debug-host regression budget. Browser retains unchanged parameters and actual displayed cells for a separate two-second observation **before** another replay/export can advance ownership. Measured RSS/JS-heap snapshots accompany the finite 256×64 cell cap; they are not a process/GPU memory ceiling, leak certification or a promise of unlimited zoom.

Recorded 2026-10-25: the native supplemental journey reached its terminal passing aggregate; the one-test production Chromium journey passed in 3.8 minutes. Independent retained-artifact readback decoded 40 PNGs and matched 18,560 exact cells across eight paired artwork states, all primary exports at 1280×720. The default crop includes 414 framed zero windows; worst-grid completion measured 7,127ms native debug and 71,222ms browser release on software graphics. See [the source/hash-bound artifact receipt](../qa/number-walls/2026-10-25/README.md) for exact inputs, command setup, timings, memory samples, cancellation observations and visual classifications. Back/title overlap with backend text and the open HUD covering the inspector remain observed defects, not a clean visual acceptance. Native driver execution remains unavailable under the current port policy; physical-device, hardware-GPU, screen-reader/gallery and human composition acceptance remain separate. No task acceptance or release gate is waived.

### Installed Android Number Walls qualification (NUM-WALL-05)

**2026-10-25: NOT_CHECKED — Android journey, TalkBack, lifecycle and gallery acceptance.** ADB inspection found an attached WayDroid target, not a physical phone. Missing physical-device/operator checks remain pending live work; they do not block independent offline implementation or close Number Walls parent acceptance.

| Identity | Observed value |
|---|---|
| Device | `192.168.240.112:5555`, `WayDroid_x86_64_Device`, ABI `x86_64`, Android 13 / API 33 |
| OS fingerprint | `waydroid/lineage_waydroid_x86_64/waydroid_x86_64:13/TQ3A.230901.001/eng.aleast.20260403.132616:userdebug/test-keys` |
| Installed package | `com.trebuchetdynamics.fractal.forge`, version `1.1.111`, code `111` |
| Installed APK SHA-256 | `3fe12e4b8518dec8f10e53e88a4bbe11133c19a9e418eb37b7d44475e46caa9c` |
| Signing certificate | `CN=Flutter Fractal Forge Upload, OU=Release, O=Trebuchet Dynamics, L=Unknown, ST=Unknown, C=US`; SHA-256 `8d5f69b91dd44476ceaad141f1fa9f6abeccdfa20cd3f7bcdfe709df623878fd` |
| Source binding | Checkout `0314ab988da349d3f281aa5f05cc22022af6b99a`; installed APK source revision **unknown**, not asserted to contain this checkout's Number Walls implementation |
| Renderer/backend | **NOT_CHECKED**; Android/WayDroid identity does not establish Canvas, sampler, Impeller or hardware-GPU execution |
| Accessibility service | `settings get secure enabled_accessibility_services` returned `null`; package enumeration found no TalkBack package |

Identity inspection used `adb devices -l`, device properties, `dumpsys package`, and `pm path`; the installed APK was pulled only to task scratch and verified with Android build-tools 36.0.0 `apksigner verify --print-certs` and `sha256sum`. No app installation, replacement, uninstall, preference mutation or gallery write was performed. The release-signed installed app is not a disposable debug-test fixture.

Pinned Flutter 3.44.6 / Dart 3.12.2 startup attempt:

```sh
flutter test integration_test/flows/number_wall_journey_test.dart \
  -d 192.168.240.112:5555 --reporter expanded --no-dds \
  --device-vmservice-port=20417 --host-vmservice-port=20418
```

This exited **64 before any test ran**: `Could not find an option named "--device-vmservice-port".` It is an unavailable driver check, not a failing product assertion or a passing Android journey. The unmodified planned command below was not run: its VM listeners are not bound to this worker's reserved range. Do not borrow NUM-WALL-02's port exception, patch the SDK or replace a release app to obtain a receipt. The [reserved-port runbook](runbook.md#owned-linux-runtime-with-reserved-ports) explains the related native-driver limitation; supplemental execution must remain distinct from the required driver receipt. Focused `flutter analyze --no-pub integration_test/flows/number_wall_journey_test.dart` passed; static analysis is not installed-device evidence.

#### Android resume and readback checklist (not executed)

1. Use a named install-safe test device/profile and a source-bound candidate; retain APK hash, certificate digest, version/code, source revision, Flutter/Dart versions, device fingerprint/ABI and actual renderer/backend. Keep emulator/WayDroid and physical-device verdicts separate. Preserve the existing release installation and user data; do not uninstall it to resolve a signing mismatch.
2. Reuse `integration_test/flows/number_wall_journey_test.dart`, not a parallel replacement journey. The planned gate is `flutter test integration_test/flows/number_wall_journey_test.dart -d DEVICE_ID --reporter expanded` with the actual ID, under `autowork-run timeout 1100` and permitted listener control. Supply the host journey's `FORCE_GPU_RENDER`, `FORCE_RUNTIME_CATALOG_THUMBNAILS` and `NUMBER_WALL_SOURCE` defines, plus `NUMBER_WALL_ARTIFACT_DIR` pointing to a writable app-private directory on Android, not a host path or the relative Linux default. Retain the terminal aggregate, exceptions, `environment.json`, matrices and PNGs. This fixture writes preferences/presets and uses synthetic 1280×900 and 320×900 surfaces; it neither preserves an ordinary user's settings nor qualifies natural device layout, real keyboard/TalkBack or OS backgrounding.
3. Separately exercise the installed UI at its natural viewport in EN/ES. With the soft keyboard open, enter and Apply prime `97`; reject `561` without replacing the committed wall; exercise a long decimal's pending/unverified and Cancel states without calling it prime. Inspect the editor, backend label and cell inspector for clipping/overflow at enlarged text (2×) and high contrast. Traverse prime editor → Apply → sequence/style/randomizer → inspector using Tab/Shift-Tab and activation keys, then TalkBack next/previous and activation. Record actual focus order, spoken names/values/status, visible focus, reachability, >=48px targets and zero/nonzero cues independent of colour. Synthetic semantics and screenshots do not substitute for these checks.
4. During long validation/grid work and separately during export, background via Home and resume; also navigate away/back. Record committed source/prime/grid/style before and after, cancellation/status timing and any stale completion. Reopen saved settings and verify only certified state is restored. Do not require an interrupted export to survive process death or call an unfinished save successful; record the lifecycle event and actual file outcome.
5. Save an HD PNG through the real export UI. Match the new filename to this run's app-private export and its MediaStore image row (`_id`, `_display_name`, `relative_path`, `width`, `height`, `is_pending=0`), then read the row's content URI back through ADB to task scratch. Decode the **MediaStore bytes**, require 1280×720 and compare every represented cell/zero mask against the retained immutable matrix/style using the host journey's one-LSB RGB tolerance and exact alpha. Local-file success alone is insufficient: `ExportService._mirrorImageToMediaStoreIfNeeded` is best-effort and suppresses platform errors (`lib/core/services/export/export_service.dart`); Android publication is owned by `persistImageToMediaStore` (`android/app/src/main/kotlin/com/fractals/flutter_fractals/MainActivity.kt`). Finally open that exact saved image in Gallery, verify readability and composition, and retain its URI/filename plus readback result without inspecting unrelated media.

All five live checklist outcomes remain **NOT_CHECKED** in this attempt. No Number Walls PNG, gallery visibility, physical-device performance, live accessibility or Android lifecycle pass is claimed. Resume with an install-safe source-bound target and a permitted driver environment; retain missing TalkBack/operator and physical hardware as separate live gaps, not offline blockers.

## Academic evidence verification

Planned, not executed: ACAD-01 adds offline schema/import/coverage checks; ACAD-02 produces actual ResearchForge metadata manifests and failure/screening queues; ACAD-03 requires real human approval before legal acquisition and accepted source-span/renderer review; ACAD-04 continues bounded all-identity assessment; ACAD-05 prevents unsupported/stale claim promotion at existing metadata/admission seams. Exact proposed commands and dependencies are in TODO.md and the library README.

This planning pass inspected current sources and ran only the existing read-only strict catalog doctor: 1,619 rows, 0 errors, 0 warnings. Registry inspection found 376 implemented-flag rows with 6 nonempty reference fields; this is not a live app catalog count or academic verification score. Source provenance/rights, page/equation checks, effective Dart/GLSL/CPU relationships, numerical tests, native/browser/device rendering and release qualification remain separate.

New negative fixtures must cover duplicate titles with different identifiers, preprint/publication revisions, citation/video/code misclassification, inaccessible text, retractions, forged approvals, missing equation spans, stale builder/shader hashes and failed providers. Import/refresh must preserve historical source packages, unchanged bytes and failed-query provenance. Verify exact namespace-selected/processed/remaining ID sets and aggregate counts in code; never infer all-fractal coverage from a green schema/doctor result or an article total. Run the existing research tests/manifest/visual-inventory/strict app doctor guards after authorized implementation. No new academic pipeline tests, live literature sweep, full-text acquisition, Feynman execution or app formula certification ran during planning.

## Independent platform release verification

Planned, NOT_RUN: validate [the accepted lane policy](../../PRD.md#independent-platform-release-policy) using the existing release-script test suites and new focused fault-injection fixtures. Prove that an Android device/signing error, unavailable Windows/Apple host, F-Droid scan error or single publisher failure skips only its lane while an unrelated valid lane reaches its mocked publisher with exact verified artifact identity. Missing credentials must not block unrelated destinations. Common source/commit mismatch, stale/tampered provenance, secret/privacy failure or compatibility failure must stop every affected publication. Test all-skipped, complete, partial, missing lane records and ambiguous-write readback/no-duplicate-retry outcomes. Assert production/completed Play and published non-prerelease GitHub defaults, and no GitLab login/push/dispatch when deferred.

Add positive native-host/real-browser/device qualification through existing `REL-JOURNEY-*` tasks rather than calling mock tests release proof. A prepare-only run must record every lane and real artifact validation while issuing zero publisher calls. A later separately authorized production campaign must read back exact GitHub assets, Cloudflare deployment and Play state; unsupported Apple/F-Droid external outcomes remain explicit, never invented successes. Scope-specific failures are not global success, and global validation must not be disabled to permit a partial release. No builds, qualification, uploads or deployments were run by this planning change.

## MCP-assisted app quality verification

Status: Accepted

The checklist below defines qualification for [the bounded architecture/UI work](spec.md#mcp-assisted-app-quality); [APP-005-7f's source-bound results](#app-005-7f-composed-batch-evidence) distinguish executed checks from remaining gates. The retained static MCP session is executed tooling evidence only, not runtime or visual qualification. Reuse the exact tests named by each APP task. First reproduce the reported source-supported behavior in a focused regression; if current code already handles it, retain passing regression coverage and avoid redundant refactoring.

### Retained MCP capability baseline (APP-001-47)

Evidence owner: candidate `a153169078fc91ff7c4d5b17980a67c7b5a35caa`, retained again in `3022020d78dc5fda9d7b40734a1858b0867b1a8b`. Its completed session inspected source revision `c6350f2b8698f6a4133c0a18728fee3472153dbc`, not this later composition. The prior failed common Flutter gate remains failed history; neither the ACAD-008-74 setup repair nor this documentation reconciliation converts it into a pass.

- Client: existing Python 3.11 environment, MCP SDK 1.26.0, `ClientSession`/`StdioServerParameters`/`stdio_client`; no install, bridge or persistent profile configuration. Server: pinned Flutter 3.44.6 / Dart 3.12.2, SDK-bundled `dart mcp-server`, name `dart and flutter tooling`, version `0.1.4`, negotiated protocol `2025-11-25`.
- Initialize/list_tools succeeded. Exact enabled/returned tools: `roots`, `lsp`, `analyze_files`, `dtd`, `get_runtime_errors`, `widget_inspector`. No fix or lifecycle tool was enabled. Registered URI only: `file:///home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.worktrees/autowork-APP-001-47-r2`; roots add/remove each returned `Success`.
- Discovered schemas: `roots` `{command, uris}`; `lsp` `{command: resolveWorkspaceSymbol, query}`; `analyze_files` `{roots: [{root, paths}], applyFixes: false}`. All five symbol queries below resolved; analysis of exactly the five listed files returned `No errors`, without fixes.

| Area | Resolved symbol | Scoped path |
| --- | --- | --- |
| Home | `HomeScreen` | `lib/features/home/home_screen.dart` |
| Catalog | `FractalCatalogScreen` | `lib/features/catalog/fractal_catalog_screen.dart` |
| Viewer | `FractalViewerScreen` | `lib/features/viewer/fractal_viewer_screen.dart` |
| Settings | `SettingsScreen` | `lib/features/settings/settings_screen.dart` |
| Export | `ExportOptionsSheet` | `lib/features/export/export_options_sheet.dart` |

- Bounded session: 220s overall timeout; initialize/list_tools <=30s, each symbol <=60s, analysis <=90s. All completed; root removed, both context managers exited normally, stderr 0 bytes.
- Current composition is based on `7dbb74f57a0e6296eba6f4ca7b5087cddd8e7dd6`. Catalog sorting, viewer/modal controls and settings have changed since the retained session; its clean diagnostics are not fresh diagnostics for those edits. Home and export-sheet files are unchanged. Fresh checkout-local validation used pinned Flutter 3.44.6/Dart 3.12.2, `flutter pub get --offline --enforce-lockfile` (lockfile SHA-256 unchanged), then `flutter analyze --no-pub` on exactly the five paths above: `No issues found`. This CLI result is not a repeated MCP or runtime session; the runner owns the full merged-tree gate.
- Runtime availability: no explicitly identified owned DTD application/URI was supplied for this inspection. DTD enumeration/attachment, runtime-error retrieval, widget inspection, app launch and real screenshots are **NOT_RUN**. Do not attach to other apps or infer an empty runtime-error list. Final qualification needs an owned authorized debug target and listeners within `$AUTOWORK_PORT_BASE..$AUTOWORK_PORT_BASE+99`; no other-port exception or new product approval is implied.

### Remaining application checks

- Routes: repeated platform links from Home and an embedded-catalog-opened viewer; latest state, exactly one viewer route, one Back to original catalog/filter/scroll, explicit-link restoration precedence, and session remains active until owner closes. A link received beneath a modal/settings/export leaves that operation and current state intact and gives accessible localized busy feedback; retry after dismissal works. Standalone catalog fallback still opens the correct family. Test OS and in-app reduced motion independently on push and pop; keep normal motion.
- Visibility: controlled clock and notification counters prove no hidden auto-explore writes; foreground alone remains paused, explicit visible Resume works, user pause/correction and speed/mode remain preserved, export completion while hidden cannot restart playback, and disposal cancels pending animation.
- Copy/semantics: open the actual theme sheet in EN and ES, inspect labels/descriptions and selected/action semantics, keyboard activate each choice once and confirm persisted selection. Open actual export sheet in both locales, verify resolution labels and selected/custom submissions retain dimensions and validation. No mixed-language labels covered by this slice.
- Composed UI: planner fixtures are 320x568 and 1280x800 logical pixels, text scales 1.0 and 2.0, EN/ES and existing high-contrast/reduced-motion modes. Cover distinct transitions/states once, not their full Cartesian product. No overflow, unreachable primary action, lost keyboard focus or duplicate action semantic stops; inspect actual pixels plus semantics for visual claims. Bind before/after images to matching viewport/state/backend. No invented contrast/performance certification from widget-tree inspection.
- Runtime: MCP widget inspection and error retrieval on an explicit owned available debug target; restore session, navigate and edit/save a 2D and a 3D image using existing journey checks. Run browser and Linux checks when supported; real Android and human mathematical-composition review keep their existing pending tasks. No platform release or qualification verdict is implied by this batch.

Planned final guards: `flutter analyze`; `flutter test`; `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded`; `npx --no-install playwright test test/playwright/web-image-creation-journey.spec.mjs --project=chromium --workers=1`. Use the existing pinned SDK/caches, reserved ports, isolated scratch and named backend. Record exact failures/skips rather than changing toolchains or relaxing acceptance to obtain a pass. All these application commands remain NOT_RUN by this planning session.

### APP-005-7f composed-batch evidence

App inputs: integrated `37235259a2a7dd34b8656093afa5d83e33d4fc9d`; complete pre-change baseline `7dbb74f57a0e6296eba6f4ca7b5087cddd8e7dd6`, as required by APP-001-47. This verification adds `integration_test/flows/app_quality_test.dart`, environment metadata to the existing Playwright journeys, and documentation, not product changes. The identical observation harness (SHA-256 `a8e0398f129ed34c64b6a370253559f2174286366b18d30009e8e6ec51a84fc0`) was injected into an isolated checkout of that full baseline; no selective historical chrome or synthesized before-image was used. Flutter 3.44.6 / Dart 3.12.2 and the provisioned caches were used; candidate `pubspec.lock` stayed at SHA-256 `22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

The new single composed fixture navigates Home → Settings → theme sheet → original catalog → searched Mandelbrot → viewer → export sheet → original search. It verifies reachable Save and retained search, captures the six named states, and records actual camera/parameters, screen-export dimensions, catalog preferences and semantics. Four representative fixtures cover 320×568 EN/1×, 320×568 ES/2×, 1280×800 EN/1×, and 1280×800 ES/1× with in-app high contrast/reduced motion. Preferences are isolated; the default Mandelbrot is paused and unedited. DPR is 1, viewport/text metrics are synthetic, and typography uses native font fallback without test-font substitution.

Both sides ran on owned Linux/Xvfb with TCP disabled; actual OpenGL renderer was **Mesa llvmpipe (LLVM 20.1.2, 256 bits)**, not hardware acceleration. All 48 real PNGs decoded at the expected dimensions. All 24 recorded state pairs matched, including effective view, export dimensions and persisted catalog preferences. All four default-viewer and four default-export pixel pairs were identical. Inspected comparison sheets show Spanish theme cards changing from English (`Dark`, `OLED Black`, `High Contrast`) to localized copy (`Oscuro`, `Negro OLED`, `Alto contraste`); candidate semantics expose selected button actions. Initial export screenshots show the simple sheet, not every customized resolution choice; the existing export-sheet widget regressions own those assertions. Catalog count differences reflect the full historical/current inventories, not an APP UI improvement.

Private task artifacts retain `capture-manifest.json` (source/harness/backend bindings, PNG hashes and pair results), `capture-validation.log`, individual PNG/JSON sidecars, native logs, `mcp-runtime.json` and per-browser-journey `journey-environment.json` files (actual loaded-bundle response hash/URL, declared source, viewport, locale, DPR and CDP GPU details); the worker report identifies their scratch paths. The same-state images support the bounded copy/layout observations only. At 320px/2× the Home title still overlaps header icons on **both** sources; the theme subtitle ellipsizes and more options require scrolling. Propose the Home header collision to the coordinator's existing queue rather than expanding this batch. These are not whole-app visual perfection, measured contrast, physical-device typography or human composition acceptance.

| Check | Observed result |
| --- | --- |
| `flutter analyze --no-pub` | No issues found on the final fixture/app inputs. |
| `flutter test --no-pub --reporter expanded` | Incomplete: the bounded 1,200s attempt exited 124 before a terminal suite aggregate (last counter `+1392 ~1 -1`). The Milnor 960×720 preview timeout passed in its isolated rerun. No full-suite pass is inferred. |
| Ten named changed-path Home/catalog/viewer/deep-link/a11y/auto-explore/settings/export targets | All 398 tests passed in the narrower composed regression run. The worker report retains the exact target list and command. |
| Release web build and existing Chromium image-creation spec, one worker | Build passed with local web resources; both existing journeys passed. Four downloaded PNGs (edited Mandelbrot/Mandelbulb and Gaussian before/paused) decoded at 1280×720. Both actual loaded `main.dart.js` responses matched the built artifact's SHA-256 `f4329d600b66f4018fc2777cef1a49b63fdfa3e2031583e602c4d6a4b0e9d511`. Chrome for Testing 147.0.7727.15 / Playwright 1.59.1; actual CDP renderer ANGLE/SwiftShader Vulkan 1.3.0, driver 5.0.0 (software). EN-US/DPR 1; actual 2D/3D viewport 1280×720, Gaussian 1280×900. No hardware-backend equivalence is inferred. |
| New composed native fixture on baseline and candidate | Both `flutter run` executions completed the composed case and teardown, with no fixture exception; screenshots/semantics retained. Supplemental evidence, not a native integration-driver pass. |
| Existing `user_flows_test.dart` through port-bound `flutter run` | Raw terminal counter `+13 ~1`, including teardown: 12 product cases and the explicit Barnsley Fern default-view skip. The edited 2D/3D journey retained two actual PNGs and state sidecars, independently decoded at 1280×720; favorites/preset and edited-state assertions passed. The integration-plugin warning remains a qualification limit. |
| MCP on the explicit owned debug fixture | Official server 0.1.4, protocol 2025-11-25; discovered schemas, checkout-only roots, explicit DTD/app connection. Three runtime-error samples returned `No runtime errors found`; actual widget trees included Home/viewer/export during navigation. No other apps were enumerated or attached. Contexts, root and owned daemon were cleaned up. |

The named `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` driver gate remains **NOT_RUN under the reserved-port policy**: the pinned command rejects the necessary raw VM-port option before tests start. The [runbook](runbook.md#owned-linux-runtime-with-reserved-ports) documents the supported supplemental route and its limits. Merged-tree full offline guards belong to the coordinator and were not run as a combined gate here. Physical Android/MediaStore, real platform-link delivery, OS accessibility transitions, native keyboard/screen-reader journeys and human mathematical-composition review remain pending; widget/semantics evidence does not waive them. Update this record when the app inputs, harness, SDK/backend, fixtures or remaining gate results change.

## Recursive sine-warped sphere verification

Status: Accepted

The source study supplied the plan; the module/kernel fixtures and scoped Linux/browser journeys now exist. [SINEWARP-002-47 qualification](../planning/sine-sphere-qualification.md) records executed backend-specific checks, retained real captures and remaining limits. Use [the source formulas and independent seed](../../research/recursive-sine-sphere.md) and [implementation contract](spec.md#recursive-sine-warped-sphere). Cover simultaneous cyclic versus in-place updates, two scaled iterations, nonzero phase, depth-zero/strength-zero sphere, finite parameter clamps, enclosure/Lipschitz bounds, finite normals and convergence residuals. Use independent double-precision fixtures, shader/source uniform mapping and actual impellerc compilation; none alone proves GPU imagery.

Register the single new stable identity and shader through existing module/metadata contracts. Preserve all prior IDs, 3D pan/rotation, presets, EN/ES semantics and export behavior. Focused targets: `flutter test test/modules/recursive_sine_sphere_test.dart test/modules/raymarched_3d_pan_target_test.dart test/catalog/catalog_id_integrity_test.dart --reporter expanded`; `flutter test test/shaders/recursive_sine_sphere_kernel_test.dart`; `flutter analyze`. The coordinator owns the separate full-suite gate. Compilation and uniform-setting fixtures alone do not qualify imagery.

Run `flutter test integration_test/rendering/recursive_sine_sphere_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` on an available authorized backend. It draws the shared production kernel, compares independent ray depths, reads full-frame convergence/silhouette classifications, captures sphere/default/detail/max states, restores edits through the preset store, and compares decoded real file exports including transparency. The native integration binding disables the ticker; it cannot certify advancing animation. The scoped `sine sphere` case in `test/playwright/web-image-creation-journey.spec.mjs` checks actual advancing animation, reduced-motion freezing, rendered restoration across reload and repeated HD downloads. Backend labels and source/file hashes accompany the retained evidence; there is no second test marcher.

The current Linux captures explain, rather than conceal, budget-exhausted pixels; default/detail framing and finer finite image detail pass, not universal convergence. Maximum settings also clip and have one explicitly bounded float-threshold silhouette discrepancy. Keep miss, tangent, stagnation and budget exhaustion separate. Run on other available Linux/browser targets without shared SDK mutations or port-policy changes. Physical Android, hardware-browser qualification and human composition/source review remain pending. No copied source-video artwork may substitute for app captures.

## Plan-gap completion checks

Status: Accepted

These are planned checks, not execution results. [Academic approval preparation](spec.md#decision-ready-academic-review-package) must validate selected paper/identity membership, stable IDs, authors/version/source/rights provenance, explicit unknowns, byte-preserved original pilot inputs and blank actual approval fields. Add only a focused `test/research/test_academic_review_package.py` fixture/validator extension; reuse existing library and identity checks. Cover empty reviewed aliases, reused reviewed mappings, explicitly unreviewed proposals, unresolved/ambiguous matches and false approval rejection. Assert the original reviewed-alias file remains byte-identical and no proposal silently acquires an approval actor or approved identity/paper status. Do not download full text to make the package look complete.

[Number Walls replay validation](spec.md#number-walls-replay-validation-boundary) adds composite/Carmichael, oversized, unfinished and valid outside-quick-pick fixtures at import/link/restoration boundaries, plus stale completion after module switch. Assert prior committed settings/grid remain and startup pending state is honest. Run the existing NUM-WALL-02 native/browser state targets and include a real replay case in NUM-WALL-04; valid round-trip alone is insufficient.

[Sine-sphere intersection checks](spec.md#sine-sphere-intersection-oracle) add independent analytic sphere rays and independently bracketed warped rays, then actual production hit/silhouette/depth samples. Bind tolerances, resolution, camera, field params and backend; distinguish CPU reference execution from actual GPU evidence. A repeated shader mistake in viewer and exported PNG must not pass the oracle.

[Native export commit checks](spec.md#native-export-commit-boundary) inject partial stage-write failure, commit/replace failure, pre/post-commit cancellation and colliding existing output into single, batch and contact-sheet flows. Assert unchanged previous destinations on failure, no incomplete final filename, no premature item-success, only owned-stage cleanup and a decodable successful retry. A recreated service must not treat a leftover stage file as exported or delete unrelated files. Extend `test/export/export_service_test.dart` and `test/export/batch_export_service_test.dart`; run `flutter analyze` and existing export/journey guards. Never perform destructive full-disk tests or real MediaStore/service calls for an offline fixture.

### APP-001-47 immutable pre-APP-002-e0 replay manifest

Preserve the original inspected source `c6350f2b8698f6a4133c0a18728fee3472153dbc` separately from this attempt's pre-implementation composition `7dbb74f57a0e6296eba6f4ca7b5087cddd8e7dd6`. Use the latter for the next APP-002-e0 before/after comparison; do not relabel the historical MCP session as inspecting it. Owned inputs are the complete tracked files at that revision, including `lib/`, `shaders/`, `assets/`, `pubspec.yaml`, `pubspec.lock` and EN/ES localization sources. No app code or dependency inputs are changed by APP-001-47.

Replay with clean, isolated app preferences (no active viewer session or incoming link), dark theme, time/animations paused, default module parameters and no unsaved edits. This is an input recipe, not captured state:

| State | Replay inputs |
| --- | --- |
| Home | Initial launch, embedded catalog visible; no modal or restored viewer |
| Catalog | Unfiltered combined core/performance catalog, grid view, empty search, no category/collection/dimension filter, scroll offset 0 |
| Viewer | Select `mandelbrot`, default camera/palette/parameters, playback paused; record effective values from the pinned revision |
| Settings | Open Settings from Home, then theme sheet; close between captures |
| Export | From that default viewer open Export options, no submission; record effective preset/dimensions before comparing |

Viewports: 320x568 and 1280x800 logical pixels. Representative fixtures: narrow EN at text scale 1.0; narrow ES at 2.0; wide EN at 1.0; wide ES at 1.0 with high contrast/reduced motion. Use the same state, locale, text scale, theme, accessibility settings and backend on both sides. Record actual device/backend, device pixel ratio, viewport, selected module, effective parameters, filter/scroll and sheet state alongside images; cover distinct transitions rather than the full Cartesian product.

Baseline pixels were **NOT_RUN during APP-001-47**, when no owned authorized runtime target was identified. APP-005-7f subsequently replayed this exact immutable source on owned Linux/Xvfb and retained 24 genuine baseline PNGs; see [the paired result and limitations](#app-005-7f-composed-batch-evidence). Never synthesize before-images, use another revision's pixels silently, or count this input manifest alone as runtime/visual acceptance.

## Optional looper randomizer verification

Status: Accepted

Planned checks for the [bounded random-point contract](spec.md#optional-randomized-camera-looper-points): seeded 2D/3D generation, finite/deep-zoom/module-minimum bounds, rejected anchors and clipped/no-change outcomes; trajectory-bearing active views or any stored point disable/reject every random-point action with no state mutation and localized explanation, including eligibility changes after the sheet opens; selected-point-only replacement; A-before-B and explicit optional-point append; unchanged params, other points, duration and live viewer; stop-without-auto-restart preview; reset on module switch; export-busy rejection and immutable in-flight plan. Use existing controller suites and localized sheet semantics/overflow tests at 320/360 widths and 1/2/3 text scales. Extend the viewer's looper regression to drive Randomize A/B, add a random optional point, preview, then decode the actual GIF and reconcile its sampled states/frame limits against the captured plan. Include manual-only operation, cancellation and failed-share/save preservation regressions. Do not substitute RNG resampling or widget presence for composed preview/export proof. Feature/device checks remain NOT_RUN; run ordinary offline guards before integration and retain separate device qualification.

## Fibonacci prime-degree Julia verification

Status: Local implementation checks recorded; real-target qualification pending.

Contract: [spec](spec.md#fibonacci-prime-degree-julia); [FIB-PRIME-02](../../tasks/items/FIB-PRIME-02.md) and [FIB-PRIME-03](../../tasks/items/FIB-PRIME-03.md). The retained independent mathematical review is not app/device qualification.

- FIB-PRIME-01 model tests exist and cover simultaneous old-state updates, k=0/final-cap indexing, nonzero-c degrees, every finite prime marker/F4 exception/F19 counterexample, c=0 unit disk, three-cycle, single-large collapse, sufficient both-large growth, invalid inputs and cap-versus-numeric uncertainty.
- FIB-PRIME-02 adds real runtime-effect draws and decoded PNGs through the registered module, independent sequence-history pixel comparisons, native full-frame CPU checks, immutable GPU/CPU export capture, cancellation/no-commit and visible EN/ES CPU-alpha refusal. A landscape/split-pane regression binds capture to the actual boundary, not screen size; family CPU passes preserve that aspect ratio. Edited c/N/bailout/view bindings and the supported 1e-6/1e-7/1e-9 camera inputs are exercised. N is never silently increased by generic renderer/gesture refinement.
- Selected materialized default: c=-0.2+0.25i, N=45, bailout=4, pan=(0,0), zoom=1. On the host Skia raster runtime-effect path, the 64×48 opaque decoded PNG has 8 RGB bands, 771/3072 dark finite-cap pixels (25.10%), luminance range 17.59–203.72 and standard deviation 73.24 (Rec.709 byte-weighted luma, not a WCAG contrast claim). All 3072 samples match the independent double-precision sequence-history oracle within one RGB byte. The c=0 analytic preset also has zero disagreements; it was not the sole rendered candidate. These measurements justify useful nonblank framing, not aesthetic/hardware qualification.
- Opaque export fixture: c=-0.3+0.3i, N=11, bailout=4, pan=(0.2,-0.1), zoom=1.4, 32×24 GPU and CPU PNGs. Boundary comparison allowance is at most 1% of pixels with a channel difference greater than one byte (7 pixels at 32×24); actual disagreements are printed by the test. Numeric diagnostics are finite opaque magenta; finite-cap dark is uncertainty, not proven interior. Only the GPU path may make finite-cap pixels transparent. No CPU alpha-parity claim.
- Local commands: `flutter test --no-pub test/models/fibonacci_complex_model_test.dart test/modules/fibonacci_complex_test.dart test/cpu/fibonacci_complex_cpu_test.dart test/export/fibonacci_complex_export_test.dart test/catalog/catalog_id_integrity_test.dart test/modules/animation_capability_audit_test.dart test/modules/readme_catalog_claims_test.dart test/screens/settings_screen_a11y_test.dart --reporter expanded`; `flutter gen-l10n`; format touched Dart; `flutter analyze --no-pub`; `/usr/bin/python3 -m pytest test/research/test_academic_coverage.py -q`; Linux/web release builds with `--no-pub`. Use pinned Flutter 3.44.6/Dart 3.12.2 and unchanged lock. Set `FIBONACCI_EVIDENCE_DIR="$TMPDIR/fibonacci-evidence"` on the focused test command to retain actual draw/export PNGs; replay inputs and numeric tolerances live in those tests. Local exit records belong to the worker report. The unchanged full offline gate is reserved for the coordinator's merged tree, not claimed by these checks.
- FIB-PRIME-03: implement `integration_test/flows/fibonacci_complex_journey_test.dart`; use `flutter test integration_test/flows/fibonacci_complex_journey_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` on an owned authorized target. On an available installed Android device use the same target with the actual device ID, recording device/backend/build, EN/ES, narrow/large-text/high-contrast focus and gallery PNG readback. Add a Fibonacci case to existing `test/playwright/web-image-creation-journey.spec.mjs` and run `npx --no-install playwright test test/playwright/web-image-creation-journey.spec.mjs --project=chromium --workers=1 --grep Fibonacci --reporter=list` with the existing configured owned host and authorized listener range. Do not alter ports, download tools or infer target access from this plan. Check real catalog->edit c/N/view->save/reopen->PNG, with prime/finite-cap legends and actual decoded outputs. All live checks are NOT_RUN; unavailable targets stay open separately from offline code acceptance.

No speedup/fps or live visual-quality claim follows from these offline tests/builds. Hardware/source reference licensing and academic approvals remain independent, with no paper acquisition or source-approval promotion in this batch.

## Finite Besicovitch / Perron tree

`test/models/perron_tree_model_test.dart` checks the translated-leaf fixture, independent interval-union area bounds, sampled directional witnesses, immutable offsets and numerical input limits. `test/modules/perron_tree_test.dart` draws the real registered shader, encodes and decodes its PNG, and compares geometric pixels with a separate barycentric oracle, checks static output, style/transparency/PNG readback, camera extremes, and the EN/ES shader-only notice. CPU dispatch must refuse synthetic substitution. The analytic full-angle argument and current limits are in [the construction owner](../../research/besicovitch-shader.md#finite-implementation).

Run `flutter test --no-pub test/models/perron_tree_model_test.dart test/modules/perron_tree_test.dart --reporter expanded`. Optional `PERRON_PREVIEW_DIR` saves actual shader PNGs and named host draw/readback samples at increasing depths. These are host raster checks, not hardware GPU, performance parity, installed-device acceptance or a complete image-export journey. Preserve separate Android, browser and Linux journey gates, and test direct export/fallback failures rather than showing a substitute image.

Perron luminous readability: the module regressions also reject clipped overlap centers at depths 0/3/5 with default/maximum glow, verify premultiplied channels and transparent-to-opaque composition, and retain the independent geometric pixel oracle. Compare same-size shader PNGs for exposure; lower luminous occupancy is not a mathematical area change. This is a styling-only patch; rerun targeted model/module/shader and Chrome checks, and retain separate physical-device and complete export-journey gates.

### BESICOVITCH-01 source-bound reconciliation

Baseline: `f7c3ee1c338a337dd175b3684ba9b8c8add457ec`. This pass preserves the integrated model, module, shader and model tests. It extends the existing coverage case to decode the shader's PNG before checking geometry, rather than accepting a PNG signature alone. It does not implement another Perron tree or qualify a limiting set.

Mathematical checks precede rendering claims:

- **Translations:** [the model](../../lib/core/models/perron_tree_model.dart) uses H=1/sqrt(3), N=2^d, delta=2H/N. At stage k, adjacent groups contain 2^k leaves and hearts of height h=a^k. Alignment contributes -2^k delta(1-h), and merging contributes -2(2^k delta h)(1-a). Their sum is exactly the model's -2^k delta[1+a^k(1-2a)], applied to the right group (bit k set). Leaves are translated, never scaled. The independent two-stage fixture at a=.75 gives [0,-H/4,-5H/8,-7H/8].
- **All directions, not just samples:** leaf j retains slopes [-H+j delta,-H+(j+1)delta]. These closed intervals partition [-H,H], or angles [pi/3,2pi/3]. Fan rotations 0, 2pi/3, 4pi/3 give [pi/3,2pi/3], [0,pi/3], [2pi/3,pi] modulo pi. For any angle in a leaf interval, its upward unit vector has y in [0,1]. Every point of the segment from the translated apex therefore satisfies that leaf's two slope inequalities. Translation, recentering and rigid scene rotation preserve length and direction coverage. The sampled witness test is a regression, not the continuous proof.
- **Finite area:** Wigderson, *The Kakeya Conjecture*, Mathcamp 2017, [section 2, printed pages 4–5](https://ywigderson.math.ethz.ch/math/static/KakeyaNotes.pdf), derives the heart/ears bound. After d stages, the heart contributes H a^(2d), and stage k ears contribute at most 2H(1-a)^2 a^(2k). Summing gives area/H <= a^(2d)+2(1-a)^2 sum(k=0..d-1,a^(2k)) <= a^(2d)+2(1-a)/(1+a). The finite sum also covers a=.5 and a=1 by continuity. The [model test](../../test/models/perron_tree_model_test.dart) independently integrates affine interval unions at every endpoint crossing for d=0..5 and a=.5/.75/.8/.99/1. Each leaf has area H/N>0. Three fans have union area at most three times the single-fan bound, not necessarily equal to it. Neither glow nor pixel counts enter this argument. No Pal joins are implemented, so no continuous needle-motion claim follows.

Fresh offline evidence uses Flutter 3.44.6 (framework `ee80f08bbf`, engine `83675ed276`) / Dart 3.12.2 on Linux x86_64. The exact focused command above passed **12 tests**. A verbose rerun of the decoded-PNG case confirmed `flutter_tester` with `--enable-software-rendering --skia-deterministic-rendering`: software Skia, not a hardware GPU. This compiles and draws the actual registered fragment program. The decoded 240×200 geometric PNGs at depths 0/3/5, a=.8, rotation 23 degrees agree with the independent vertex-cross-product oracle away from antialiased boundaries (over 500 stable samples and over 10 interior hits per depth). The oracle shares model translations, but not shader half-plane evaluation; translation correctness is established separately above. Other existing cases check time-invariant captured parameters, style separation, premultiplied transparency, overlap color, extreme cameras, finite input handling and the localized CPU-only notice.

Production source bindings at that baseline (Git blob IDs):

| Source | Blob |
| --- | --- |
| `lib/core/models/perron_tree_model.dart` | `9a11230f6a1eef7b0e92c4aba9883128568123e2` |
| `lib/core/modules/fractals/perron_tree_module.dart` | `7ba8cc1f11aa493a5f81a276b5bf33c7a2697205` |
| `shaders/ifs_and_geometric/perron_tree_gpu.frag` | `495cceefef763982882d9210b0c1d8124eefc63f` |

With `PERRON_PREVIEW_DIR` set to an owned scratch directory, the existing fixture also produced geometric, luminous, transparent and 960×720 showcase PNGs. Its 512×512 host-raster draw/readback samples were:

| Depth | Three samples (microseconds) |
| --- | --- |
| 0 | 64755, 63620, 66585 |
| 3 | 325963, 331156, 333235 |
| 5 | 1161437, 1167509, 1153311 |

The metric includes program lookup, shader creation, draw, image creation and RGBA readback. These are three host samples, not steady-state frame times or measured hardware-GPU performance. They do **not** support an interactive-performance claim. Scratch images/timings are reproducible diagnostic artifacts, not a durable device receipt.

The module declares static animation and ignores time in its shader. Existing same-state output tests cover offline invariants, not a complete Perron viewer/export journey. `flutter test --no-pub test/export/viewer_export_session_test.dart --reporter expanded` also passed **9 tests**, including freeze while the sheet/export is active and revocation of automatic resume on visibility loss. Retain installed Android, browser and Linux browse/customize/understand/export journeys, decoded saved-file comparison against the frozen edited camera/parameters, OS/in-app reduced-motion and assistive-technology checks, human mathematical-composition review, and named hardware-backend timings as separate pending qualification. The coordinator still owns the unchanged common offline gate on the merged source. Historical research NOT_RUN statements remain research history, not current implementation status or waived checks.

## Modal and live controls consistency

Catalog ordering regression: `test/golden/catalog_golden_test.dart` preserves the existing catalog images and explicitly checks the relative positions of equally named Anti-Buddhabrot variants. Adding modules must not shuffle equal display names; the comparator breaks ties with stable catalog IDs. The delivery reproduction failed on the candidate and passed on the original HEAD under the same fixture; the tie-break repair passed all four existing golden cases without updating their images.

All 24 direct modal launch sites were inventoried; all 16 bottom-sheet launchers now explicitly request safe areas and scroll control. Shared sheet/dialog styling follows the selected theme, with desktop width caps of 720/560 logical pixels. Preserve the single IME-padding owner, exact selectable options, palette selection visibility, controller dismissal lifetime, explicit medium-impact Copy/Share feedback, and fullscreen batch cancellation/error behavior.

The isolated combined modal/control/accessibility selection passed 751 cases with one optional private capture fixture skipped; viewer-screen/view-controls tests and the web release build also passed. Review found dropped Share haptics; both actions were restored with red/green platform-channel regressions, followed by passing canonical focused tests and analyzer. Capture-only helpers remain private: component raster previews use substituted fonts/synthetic viewport metrics and do not qualify production typography, a physical keyboard/IME or screen-reader/tactile behavior. Retain the existing independent device/browser journey gates.

## Milnor-inspired Brieskorn polynomial orbit

See [the mathematics owner](../../research/milnor-brieskorn.md). `test/modules/milnor_brieskorn_test.dart`, `test/modules/milnor_brieskorn_render_test.dart`, `test/helpers/milnor_brieskorn_oracle.dart` and `test/shaders/milnor_brieskorn_shader_test.dart` cover registration, exact/binomial orbit fixtures, the coefficient-aware escape bound, finite-update semantics, independent pixel classification, palettes, captured-state roundtrips, transparency, extreme inputs and EN/ES unsupported-CPU notices. Non-escape within the budget is not proven boundedness; one critical orbit is not a connectedness locus, and this is inspired dynamics rather than exotic-sphere geometry.

The final combined canonical check passed 46 selected shader, mathematics, public-count, shared-modal, Share-feedback and live-HUD tests, plus three academic-coverage tests and a clean analyzer. Earlier integrated attempts exposed stale public/localized counts; those failures were retained and the source counts were reconciled before the passing rerun. Fresh canonical 960×720 previews were decoded and bound to the unchanged shader hash. This focused pass does not replace the full common integration suite.

The isolated focused module/metadata/catalog/shader run passed 292 cases with six existing skips; actual production FragmentProgram readback matched 9,223 margin-stable oracle samples, including 738 near-boundary samples. Academic coverage tests passed three cases. Linux debug build and SkSL/GLES/GLES3/Vulkan shader compilation passed. These are candidate-native/compiler checks, not a full common integration gate or hardware GPU qualification. Chrome attempts stalled before tests started and remain unverified. `MILNOR_PREVIEW_DIR` optionally saves actual 960×720 shader PNGs and replay states. CPU precision, physical-device behavior and complete export journeys remain unsupported or unqualified as stated; no publication follows from these checks.
