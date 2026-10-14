# Verification plan

## Automated checks

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
| Linux | Extend `integration_test/flows/user_flows_test.dart` and the existing export tests to save/decode real artifacts. Run `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` plus the exact added export target. | Unverified |
| Android | Exercise the same flow on a named Android device and verify the actual MediaStore destination and visible/readable exported image. Record the selected device ID and the exact integration command. Emulator/software rendering and physical-device results remain separate. | Unverified |

Existing widget, compiled-shader, golden, and browser smoke results remain useful lower-level evidence. They do not close this complete journey. Unsupported environments or missing devices are reported as gaps, never substituted with fabricated results. macOS/Windows, video export, and whole-catalog mathematical certification are excluded from this new gate.

## Limits and outstanding coverage

Real-device MediaStore and wallpaper verification, real-device gesture feel/deep zoom, and broad visual audit work remain listed in `TODO.md` and the current platform/audit documents. The visual-inventory validator checks ID counts, references, and shader paths; it does not prove GPU image quality, a first viewer frame, or native CPU-formula coverage. The inventory records capture/runtime-preview evidence for 187 of 1,028 Explore rows; 841 remain uncaptured. All 200 research definitions have no app renderer. First-view evidence is recorded for 14 Explore rows; `cpu_formula` is `not audited` in 1,145 of the 1,228 rows. These totals describe recorded inventory evidence, not a fresh GPU or artifact qualification. Historical run counts in `PRD.md` are dated snapshots, not current verification receipts. No claim is made here that these checks ran during documentation maintenance.

## Gaussian moat visualization

Status: Accepted

Source: [Accepted feature](../../PRD.md#gaussian-moat-walking-visualization) and [bounded specification](spec.md#gaussian-moat-walking-visualization). All feature checks below are planned, not executed.

- Mathematical fixtures: ordinary-prime norms off-axis; axis primes congruent to `3 mod 4`; origin/units/composite norms excluded; all signs and conjugates; bounded sieve limits; invalid/oversized inputs; points outside the computation domain. Expected values must be independently specified, not generated by the predicate under test.
- Graph fixtures: inclusive squared-distance equality, just-outside steps, distinct endpoints, deterministic small components, visited-path independence, unreachable targets, trapped walk versus full component, and conservative boundary-truncation status. No viewport-only or trapped-path assertion proves a global moat.
- UI fixtures: catalog identity `gaussian_prime_lattice`, default domain/step display, tap/coordinate round trips after pan/zoom and pane resizing, valid/invalid steps, undo/reset, module switch, parameter changes and stale-result cancellation. Preserve existing favorites/presets and other module gestures.
- Accessibility: keyboard selection and movement alternatives, useful coordinate/count/status semantics, non-color-only states, high contrast, EN/ES, 320px width and enlarged text. Provide reduced-motion behavior if transitions animate.
- Export: download/save the actual PNG containing exact points, selected path and enabled component overlay. Decode it, verify selected dimensions, and compare the represented edited state. Check capture placement, compare/Fourier panes and incompatible visual effects rather than relying on widget presence.

Planned unit/widget targets: `test/modules/gaussian_moat_model_test.dart` and `test/features/viewer/gaussian_moat_walk_test.dart`. Planned journey: `integration_test/flows/gaussian_moat_journey_test.dart`. Existing regression anchors: `test/modules/tenth_wave_fractal_additions_test.dart`, `test/modules/module_registry_widget_test.dart`, `test/fractal/fractal_renderer_gesture_test.dart`, `test/features/viewer/every_module_viewer_walk_test.dart`, and `test/export/`.

Commands after implementation: `flutter test test/modules/gaussian_moat_model_test.dart test/features/viewer/gaussian_moat_walk_test.dart --reporter expanded`; `flutter analyze`; `flutter test integration_test/flows/gaussian_moat_journey_test.dart -d linux --reporter expanded`; use the same journey on a recorded Android device with `-d <device-id>`. Extend the existing production-build Playwright runner for a real web PNG download. Record its exact new target and command when created; no invented runner command is an acceptance receipt.

Measure capped-domain generation/component duration and memory on each target; record source, device/browser, backend and input bounds. The [refined hard workload and scheduling limits](spec.md#workload-and-scheduling-limits) define planned bounded execution; they are not measured latency promises or a changed Play release gate. No runaway task, stale paint or unbounded allocation is acceptable. A browser loading timeout is infrastructure failure, not mathematical RED or GREEN. Unit, browser, emulator and physical-device evidence remain separate.

## Prime-walking growth and quaternion slice checks

Status: Accepted

Sources: [Gaussian growth design](spec.md#bounded-radius-growth-and-visual-direction) and [quaternion companion](spec.md#prime-norm-quaternion-companion). These checks are planned and have not run.

Growth: test manual radius scrub, play/pause, monotone components at fixed domain, start-prime retention, invalid path resets, superseded-result rejection, reduced-motion manual stepping, and explicit truncated status throughout boundary-limited animation. Preserve existing 2D gestures and export the selected radius/state, not a racing frame.

Quaternion fixtures: independently specified prime/composite norms, zero/units, signs, permutations, nonzero fixed `d`, invalid/oversized inputs, exact 4D squared distance with fixed `d`, inclusive threshold and truncated slice boundaries. Assert that graph connectivity is camera-independent and explicitly slice-only. Test depth-overlap selection, projection round trips, rotation/pan alignment, coordinate-list/keyboard alternatives, EN/ES disclosures, dark/high-contrast/narrow/enlarged-text states and navigation cancellation.

Planned targets: `test/modules/prime_norm_quaternion_test.dart`, `test/features/viewer/prime_norm_quaternion_walk_test.dart`, `integration_test/flows/prime_norm_quaternion_journey_test.dart`. Run `flutter test test/modules/prime_norm_quaternion_test.dart test/features/viewer/prime_norm_quaternion_walk_test.dart --reporter expanded`, `flutter analyze`, and that journey on named Linux/Android targets. Extend the existing production web runner and record its actual target. Decode saved/downloaded PNGs, checking dimensions, selected slice, projected points and enabled walk/component overlay. Report emulator and physical-device evidence separately.

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
