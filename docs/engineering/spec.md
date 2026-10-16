# System specification

## Scope and status

This document describes the current Flutter application architecture. Product intent is in [`../../PRD.md`](../../PRD.md); historical and planned work remains identified in [`../../TODO.md`](../../TODO.md).

## Components and data flow

- `lib/main.dart` launches `DeferredStartupApp`; `lib/app/startup.dart` initializes services, and `FlutterFractalsApp` installs Provider dependencies.
- `ModuleRegistry` assembles `FractalModule` instances from declarative escape-time configs and dedicated builders.
- The catalog opens a selected module in `FractalViewerScreen`. The viewer's `FractalController` owns current module parameters and view state.
- Renderer policy selects a supported GPU path, an extended-precision GPU path, or CPU precision where a native CPU formula is available. GPU shaders are declared as assets in `pubspec.yaml`.
- Viewer features use the same controller state for controls, presets, history, export, wallpaper, and sharing.

## Rendering interface

Each module supplies a stable ID, shader asset, parameter definitions, presets, and a uniform setter. Shader uniform order and types are an interface contract between the module builder and its GLSL shader. Register shader assets under `flutter.shaders` in `pubspec.yaml` and cover module/shader compatibility with tests.

Rendering follows the capability policy in `lib/features/renderer/policy/`. Do not label a synthetic fallback as CPU precision. CPU refinement is available only when a native CPU formula supports the module. The renderer uses asynchronous Flutter shader/GPU operations and tiled CPU rendering; long-running CPU work must remain off the UI thread and support cancellation where the existing renderer contract provides it.

## State and persistence

Provider supplies application dependencies. `ChangeNotifier`-based controllers expose mutable view state to widgets. Shared preferences and the project's storage services persist supported user settings and presets. Module IDs remain language-independent; localized display names are presentation values, not persistence keys.

## Failure behavior

- Shader loading or compilation failures must remain visible through renderer diagnostics or the UI's loading/error state; do not silently report a successful render.
- GPU health and precision policy can route eligible modules to a supported fallback. Unsupported precision must remain explicitly unavailable rather than implying correctness.
- Export, share, wallpaper, and platform integrations depend on the target platform. Their failure must not corrupt the viewer's current fractal state.
- Platform features and browser parity vary. See [`rendering/renderer_backend_matrix.md`](rendering/renderer_backend_matrix.md).

## Security and compatibility

The repository's privacy policy states that fractal processing is local. Do not add analytics, account, cloud-sync, or camera-data collection without approved product scope. Keep signing material and service credentials outside source control. Android, desktop, and web behavior are separately constrained by Flutter plugins and renderer support; consult the backend matrix and platform build configuration before claiming parity.

## Interfaces not present

The app has no repository-owned HTTP API, database migration interface, or server deployment contract. The web preview is a static Flutter build published through the separately documented deployment procedure. No OpenAPI document applies.

## Gaussian moat walking visualization

Status: Accepted

Source: [Accepted feature outcome](../../PRD.md#gaussian-moat-walking-visualization). The owner requested planning and backlog persistence. No implementation, automatic execution, new dependency or publication is authorized by this section. The bounded implementation choices below are reversible engineering decisions inside that outcome.

### Local execution authority

The owner now explicitly prioritizes `GAUSS-MOAT-001`, authorizes `GAUSS-MOAT-01-MAP` implementation, relevant checks and a scoped local commit, and asks for dependency-ready continuation. Preserve unrelated edits and any live worker. This supersedes the earlier planning-only execution restriction for authorized local slices, not their mathematics or acceptance. The parent coordinates `GAUSS-MOAT-02-WALK` and `GAUSS-MOAT-04-GROWTH` after checked implementation and required review. Keep `GAUSS-MOAT-03-QUALIFY` live/platform qualification distinct and unclaimed until observed. Quaternion scope/IDs remain preserved; do not silently change the focus before the Gaussian milestone's frontier is reconciled. No push, release, deployment or recurring timer is authorized.

### Current evidence and integration boundary

The existing `gaussian_prime_lattice` entry is defined in `lib/core/modules/builders/escape_time_catalog/batch_26_tenth_wave_research.dart:239–267`. Its shader is `shaders/number_theory/gaussian_prime_lattice_gpu.frag`, declared in `pubspec.yaml`. The shader's `primeInt()` tests odd divisors only through 127; its scale clamp does not bound coordinates after pan/zoom. Do not derive authoritative graph vertices from that shader. The old `f0786_gaussian_integer_lattice_fractal` research-ledger path is not a live module, and `gaussian_prime_spiral` is only a planning candidate.

`ModuleRegistry._buildAll()` gives existing catalog IDs precedence over duplicate custom builders. `CatalogRepository.fromRegistry()` already owns discovery. Reuse the current module rather than create a duplicate registration. Reuse `FractalController.selectModule()`, `updateParam()` and reset lifecycle; keep walk history transient, not in shader uniforms or existing persisted preset schemas.

Graph evidence: fresh scoped code-only Graphify graph; `ModuleRegistry` at `lib/core/modules/module_registry.dart:64`, `FractalRenderer` at `lib/features/renderer/widgets/renderer/fractal_renderer.dart:107`, and `FractalCanvas` at `lib/features/renderer/widgets/canvas/fractal_canvas.dart:6`. Extracted `FractalCanvas` inherits `CustomPainter`. Queries: `ModuleRegistry buildEscapeTimeCatalogModules FractalModule`, `FractalViewerScreen FractalRenderer FractalCanvas`, `_wrapWithGestures _onJuliaDualTap FractalCanvas`. Coverage is partial: 272 copied Dart files; shaders, docs, external proofs and controller semantics were read separately. The graph has 20 self-loops and duplicate-label normalization warnings; source corroboration governs behavior claims.

### Smallest complete design

1. Add a module-specific exact Dart lattice model and a small painter/interaction mode. Reuse app components, theme, catalog identity and navigation. Do not add a generic graph framework, server, external prime API or dependency.
2. Engineering defaults: compute the square `[-B, B] × [-B, B]`, initially `B=32`, with a hard cap `B=128`. The viewport can pan/zoom without silently expanding computation. Display the current domain and explicitly uncomputed out-of-domain space in exact walk mode.
3. Off-axis `a+bi` is prime iff the integer `a²+b²` is ordinary prime. On either axis, the absolute nonzero coordinate must be ordinary prime and congruent to `3 mod 4`. Origin and units are excluded. Include all signs, conjugates and axis primes. A bounded ordinary-prime sieve up to `2B²` is sufficient; do not use floating-point primality or approximate shader classification for this mode.
4. Represent the step limit internally as integer squared distance `k`, initially `k=2`, bounded to `1..100`. Present maximum Euclidean distance `sqrt(k)` and its squared value clearly. Connect distinct prime points iff `Δa²+Δb² <= k`; equality is legal. Use bounded integer arithmetic consistently on native and web.
5. Compute neighbors from bounded displacement offsets and point membership, not a stored all-pairs graph. Keep one bounded component search separate from the visited path. Apply the chunk, cancellation and job-count limits below; do not add speculative worker infrastructure.
6. A selected prime starts a self-avoiding path. Preview candidates and commit via Step. Show legal next moves; reject composites, out-of-domain points, repeated points and overlong steps without altering the path. Offer undo and reset. Changing domain or step limit resets the path with explicit feedback so stale steps never appear valid.
7. A component overlay shows the entire reachable cluster from the starting prime, independent of path history. A trapped chosen walk is not a maximum-path result. Any possible allowed displacement from a reached point outside the domain marks the result truncated/unknown beyond bounds. Otherwise say exhausted within the computed domain. Neither state is a certificate of the infinite theorem.
8. Map input and painter coordinates through one tested transform, including pan, zoom, pane dimensions and orientation. Preserve ordinary gestures. Provide a keyboard-accessible list/control alternative and textual coordinate, path-length, component-count and boundary status; do not depend only on color or create one semantics node for every plotted point.
9. Place the exact plot and overlays inside the actual export capture boundary. `FractalRenderer` currently captures at its `RepaintBoundary`; a viewer-level overlay outside it is not automatically exported. Keep compare/Fourier panes, CPU fallback and visual effects explicit: support and test correct alignment, or disable incompatible walk-mode controls with an explanation. Never silently show a different exact graph.

### UI layout and interaction contract

This refinement supplies engineering details for the existing accepted tasks. It does not approve implementation or alter global task priority. Reuse `FractalControlsHud`, existing viewer toolbar/actions and `AppBottomSheet` styling; do not add a second viewer shell. The Gaussian entry exposes **Explore** (existing shader) and **Walk** (exact bounded data) modes. Quaternion access is one **Quaternion slice** action from this experience, not another Gaussian/Julia catalog entry. Returning from the companion restores the Gaussian view; graph histories are transient and are not silently saved as shader presets.

- Narrow layout (available width below 768 logical pixels): keep the plot central. Show a compact, wrapping top status with current point, maximum jump `R=sqrt(k)`, steps and boundary state. Place **Step**, **Undo**, **Reset walk** and **Controls** in a bottom safe-area strip, allowing two rows. Controls expand the existing HUD; advanced domain/slice inputs and **About the math** use an `AppBottomSheet`. Scroll panel contents when height/text scale is constrained, not the primary status off-screen. Keep essential actions reachable at 320px width and 2× text scaling. Plot taps behind an open sheet are blocked.
- Wide layout (768px and above, when content fits): reserve a 280–320 logical-pixel side panel for the same controls and details. The plot uses the remaining pane's actual dimensions. Fall back to the stacked/scrollable layout when enlarged text makes the panel unusable. Do not stretch touch targets or duplicate the controls in both HUD and panel.
- Always visible: mode/title, selected coordinates, current jump bound, path steps (edges, not vertices), component completion state and domain-limit badge. Hide a final component count until the search completes; while computing, say **Computing**, optionally with a clearly labeled visited-so-far count. **Truncated — outside domain unknown** must remain visible, not only in an About sheet.
- Controls: maximum-jump slider/stepper, **Show component** toggle, optional grid toggle, and **Reset view** separate from **Reset walk**. Domain `B` and quaternion slice `d` use validated integer fields with **Apply**; no computation fires for every keystroke. Gaussian growth adds **Play/Pause** and manual radius scrub; quaternion initially uses manual camera rotation. Keep existing export access. Explain unavailable effect/compare/Fourier combinations in place rather than silently misaligning the graph.
- States: initial/computing, ready, candidate-invalid, chosen-walk-trapped, finite-search-complete, truncated, paused and error. A failed or cancelled search never retains an old component overlay as if it were current. Clear stale graph overlays, keep the last valid background plot where its input key still matches, and show retry/reduce-domain feedback on error.

**Selection is not movement.** A short tap/click selects a candidate and previews its coordinates, squared distance and eligibility. **Step** commits exactly one legal, unvisited prime. Invalid candidates produce a reason and leave root/path/history unchanged. Root selection uses **Set start** and clears the old path with feedback. Default Gaussian start is `1+i`; root means one visited vertex and zero steps. No origin vertex is invented. Undo removes one committed edge/vertex, restoring eligibility; at the root it is disabled. Reset walk returns to that valid root without changing camera, domain or radius. Reset view changes only camera.

In Walk mode, drag/pinch/wheel gestures navigate; their pointer sequence cannot also select a point. Reuse the renderer's existing movement/gesture discrimination, not a second conflicting gesture detector. Tap mapping uses the actual plot pane, not the full screen, excluding HUD/safe-area offsets. Changing camera, palette or component visibility preserves the path. Applying a new domain, radius or slice pauses growth, cancels stale work and resets the transient path with a status announcement; preserve the root only if it remains valid, otherwise require a valid start. Merely typing invalid input changes no graph state.

Keyboard/screen-reader path: Tab reaches labeled controls and a bounded, scrollable legal-next-points list; Enter/Space selects through native control behavior, and the separate Step button commits. Do not create thousands of focusable plot dots. List rows expose coordinates, norm/distance and legal/visited state, with a text reason for disabled movement. Preserve focus after selection/undo/reset and restore it when a sheet closes. Status announcements occur on committed changes or completion, not every animation frame. Use shapes/lines/text in addition to color, existing high-contrast tokens, minimum 48 logical-pixel action targets and localized EN/ES text.

### Workload and scheduling limits

These are planned hard workload limits and engineering scheduling budgets, not measured performance results or inherited store-release thresholds. Keep the existing bounds; a request above them is rejected before allocation and explained, never silently clamped or expanded during pan/zoom.

| Limit | Gaussian map | Fixed-d quaternion slice |
|---|---|---|
| Default / maximum domain half-width | `B=32` / `B=128` | `B=6` / `B=12` |
| Candidate lattice positions at maximum | 66,049 (`257²`) | 15,625 (`25³`), not a full 4D cube |
| Ordinary-prime sieve maximum norm | 32,768 (`2B²`) | 576 (`3B²+d²`, with `abs(d)<=12`) |
| Default / maximum squared step | `k=2` / `k=100` | `k=2` / `k=16` |
| Nonzero neighbor offsets at maximum | 316 | 256 |
| Conservative candidate-offset probe bound | 20,871,484 | 4,000,000 |

The counts were calculated from the finite domains and squared-distance predicates during planning. Actual prime vertices and searches can be smaller. Reuse dense membership/index arrays, a bounded queue/visited set and one ordinary-prime sieve per current domain. Do not store all-pairs edges or an all-radius component cache. Keep at most the current model/result, one active computation and one replacement input; superseding input replaces that pending input rather than appending jobs. Path/visited storage cannot exceed the valid point count. Cull painting to the viewport, batch exact points, and draw only local legal-move links plus the chosen path. Avoid a blur operation per dot; glow is styling, not an accuracy requirement. Never drop selected/component vertices silently to satisfy a paint budget.

Implement cooperative chunks for generation and neighbor search: yield after at most 1,024 candidate/neighbor probes or 8ms of elapsed chunk time, whichever arrives first. Check cancellation/input identity before each chunk and before publishing. These budgets bound scheduled work, not an assertion that a browser or OS will wake within 8ms. Native work may reuse the existing isolate pattern when profiling requires it; web cannot call unsupported isolate APIs. No new worker dependency or generic executor is planned. Record chunk timing, total time, peak retained point/result counts and input-to-cancel feedback on named targets. If a cap is slow, keep visible progress and a Reduce domain action; optimize the bounded implementation rather than raise caps or fabricate a timing pass.

Maximum-jump dragging previews the numeric value; compute on release or keyboard commit, not for each pointer update. Automatic growth advances only after the previous result finishes and a minimum 500ms display dwell. It never builds a timer backlog and stops at the maximum radius. Start from the current `k`, then use ascending integer-radius presets within the cap; preserve the selected valid root and reset the path. Pause retains the last completed state; a paused in-flight result is cancelled/discarded. Resume starts from the next eligible radius, not a replay of queued ticks. Navigation, app backgrounding, opening export and reduced-motion activation pause growth. Reduced motion disables automatic play but permits manual scrub/step.

Export freezes a completed input/result snapshot, including `B`, `k`, root, path, component-toggle state and quaternion slice/camera when applicable. Pause growth before capture. While a matching graph is computing, disable export with a reason or wait for it through the existing cancellation path; never combine new radius text with old graph pixels. Controls/status chrome stays outside the image, while plot, path/component overlay and domain outline stay inside the actual capture boundary. Preserve current export dimension/byte guards. No new metadata format or animation/video export is required.

### Research and mathematical limits

- [MathWorld Gaussian Prime](https://mathworld.wolfram.com/GaussianPrime.html) supplies the exact off-axis and axis predicates.
- [Eric Rowland video](https://www.youtube.com/watch?v=Cs12E2R3ZLw) supplies the educational walking metaphor, not a correctness oracle.
- [OpenAI manuscript](https://github.com/openai/math/tree/main/preprints/Bounded-Step-Walks-on-Gaussian-Primes-September-26-2026) claims a finite uniform component bound for every fixed finite step limit; its bound is nonexplicit.
- [OpenAI Lean implementation](https://github.com/openai/math/blob/main/lean/OAI/NumberTheory/GaussianMoat/Main.lean) contains `fullMain`.
- [External verification report](https://erdosproblems.ai/wiki/problems/number_theory/E0952/claims/2026_09_26_openai) reports a successful formal build and axiom check. This planning pass did not rebuild Lean, audit the entire proof, or establish peer review. Explain the attribution to Gordon/Motzkin rather than Gauss.

This bounded visual exploration is not an animation of the full information-theoretic proof. Exclude unlimited search, automated proof certificates, longest-path optimization, autonomous walker/path-finding AI, new persistent walk formats and record-moat claims.

### Ordered delivery and verification

- Now within this feature: `GAUSS-MOAT-01-MAP` delivers an exact bounded map through the existing catalog/viewer identity. It proves primality, boundedness and coordinate alignment before trusting paths.
- Next: `GAUSS-MOAT-02-WALK` adds legal walking, full-component overlay, honest boundaries and capture inclusion. Depends on the exact map.
- Next: `GAUSS-MOAT-04-GROWTH` adds bounded jump-radius animation with cancellation, pause and honest search-limit labels. Depends on walking/component mode.
- Then: `GAUSS-MOAT-03-QUALIFY` proves the actual Android/web/Linux journey, EN/ES, keyboard/semantics, cancellation and exported artifacts. Depends on walking and growth mode. Existing global selection is unchanged.

Planned targets: `test/modules/gaussian_moat_model_test.dart`, `test/features/viewer/gaussian_moat_walk_test.dart`, and `integration_test/flows/gaussian_moat_journey_test.dart`. These files do not yet exist. Run `flutter test test/modules/gaussian_moat_model_test.dart test/features/viewer/gaussian_moat_walk_test.dart --reporter expanded`, `flutter analyze`, and the platform journey commands in [the verification plan](test-plan.md#gaussian-moat-visualization). Preserve existing registry, gestures, viewer and export tests.

Skill application: spec-driven-development records observable boundaries; planning-and-task-breakdown produces dependent outcome slices; documentation-and-adrs records the exact-data versus approximate-shader decision here without another ADR; frontend-ui-engineering supplies coordinate mapping, keyboard/semantics, localization and export acceptance. All feature behavior checks remain planned/unrun.

### Bounded radius growth and visual direction

Source: the owner's follow-up `/autoresearch_plan` requests radius growth and a quaternion companion. Keep `B` for the computation half-width and `R=sqrt(k)` for maximum jump length; they are different controls. The origin is not prime. Start components at a selected valid prime (default `1+i`), never at an implicit origin vertex.

Add manual scrub plus play/pause for a bounded increasing schedule of `k`, with integer-radius presets using `k=R²`. Keep the same computation domain throughout a run. The starting-prime component is monotone with increasing `k` in that same finite graph; test this property. Each radius change clears the transient chosen path with feedback, recomputes the full component, and preserves the start if valid. Pause/cancel on navigation or input changes; superseded computations cannot paint. Reduced-motion mode defaults to manual stepping. Do not imply that the theorem makes the displayed component closed: mark boundary-limited growth as truncated.

Use existing dark/surface tokens, small luminous points, a restrained reachable-cluster accent and thin local legal-move/path edges. Optional faint grid/norm guides must not overwhelm points. Dimmed points are unreachable in the computed graph, not globally inaccessible. Limit drawn edges to selected-point legal moves and the chosen path; a dense all-edge glow mesh is not required. Mathematical coordinates remain primary; transformations are display-only. The lattice is not advertised as a proven self-similar fractal. Additional density, component-ID and minimum-connection-radius coloring are deferred alternatives, not prerequisites.

## Prime-norm quaternion companion

Status: Accepted

Source: the owner's follow-up `/autoresearch_plan` asks for Gaussian 2D walking followed by a higher-dimensional Lipschitz-integer analogue. This accepts the bounded prime-norm prototype described below, not a complete classification of quaternion primes or a theorem extending the Gaussian moat result. Implementation and publication remain unrun.

### Definitions and minimal scope

A Lipschitz integer has integer coefficients `q=a+bi+cj+dk`; its norm is `N(q)=a²+b²+c²+d²`. For this companion, keep exactly the integer points whose norm is an ordinary prime. Call it **Prime-norm quaternion slice** and disclose the predicate. Do not claim that any nonzero quaternion is prime, that this classifies all Lipschitz irreducibles, or that it includes the half-integer Hurwitz lattice.

[Oliver Knill's Harvard note](https://people.math.harvard.edu/~knill/primes/goldbachh.html) distinguishes Lipschitz and Hurwitz integer lattices and noncommutative factorization. [Hurwitz quaternion reference](https://en.wikipedia.org/wiki/Hurwitz_quaternion) states the prime-norm/irreducibility criterion for Hurwitz integers. Neither source proves a moat theorem for this prototype. Quaternion Julia/Mandelbrot fractals already exist in the app; their iteration shaders are not quaternion-prime predicates and must keep their current IDs and meaning.

Engineering defaults: begin with the fixed slice `d=0` and display `(a,b,c)` in a rotatable 3D projection. Compute `a,b,c` in `[-B,B]`, initially `B=6`, capped at `B=12`. The integer slice selector is limited to `d=-12..12`. Sieve ordinary primes up to `3B²+d²`. Restrict squared jump distance to `k=1..16`, initially `k=2`. Origin and norm-one units are excluded. Validate bounds before allocations and reject noninteger/overflowing inputs.

The graph is the **induced fixed-d slice graph**. Adjacency is inclusive `Δa²+Δb²+Δc²+Δd² <= k`, with `Δd=0` because all displayed vertices share one slice. Do not imply a walk can cross hidden slices or that a disconnected slice proves disconnectedness in 4D. Camera projection affects display only, never neighbor distances. Projection overlap requires depth-aware selection or an explicit coordinate-list alternative; a screen-space near pair is not automatically an edge. Changing `d`, domain or step clears invalid path/component state.

Reuse the ordinary-prime sieve only when the provider boundary is already justified by the Gaussian slice. Keep dimension-specific predicates and transforms explicit; avoid a generic n-dimensional graph engine. Use bounded neighbor offsets, not all-pairs edges or a full `[-B,B]^4` enumeration. Reuse existing app navigation, themes, rotation controls and capture patterns for a companion view reached from the Gaussian-prime experience. No third-party 3D engine, new backend, fake shader placeholder, duplicate Julia module or extra persistence format is required. Norm-based color with a textual legend is the default; optional slow rotation must respect pause and reduced motion. Reuse bounded radius-growth mechanics only where behavior matches.

### Quaternion layout and picking details

Reuse the narrow/wide control placement and state model above. The companion title is **Prime-norm quaternion slice**, with `d`, domain and the **fixed-d slice only** qualification visible. Put the slice selector and norm-color legend in Controls. Default is a manually rotatable orthographic 3D projection with axis triad and Reset view; full 4D projection and auto-rotation are deferred. Prime coordinates/norms remain exact independent of camera.

Picking uses projected distance inside the normal touch hit region, then frontmost camera depth, then lexicographic original coordinates for deterministic ties. Show the selected original `(a,b,c,d)` before a Step can commit. Overlapping points also remain selectable through the coordinate-list alternative; camera rotation cannot change graph membership or silently add an edge. No hidden-slice bridge is inferred from overlap. Drag rotates, two-finger/right-button pan and zoom follow existing 3D conventions; drag end never commits a step. **Reset walk** preserves the camera. Applying a slice change resets graph/path and pauses any work; a projected dot with norm no longer prime is not a valid retained root.

### Source and graph evidence

The scoped Graphify graph contains `quaternion_julia_3d_module.dart` and `FractalViewState` (`lib/core/models/fractal_view_state.dart:22`), with existing vector-math/module dependencies. Query `quaternion_julia_3d FractalViewState FractalCanvas` returned a truncated neighborhood, so it is not complete quaternion integration evidence. Source inspection of `lib/core/modules/fractals/quaternion_julia_3d_module.dart:37–42` confirms a 3D Julia module and its shader, not a prime-cloud implementation. Graph scope remains code-only with self-loop/duplicate-label warnings; no inferred edge certifies new UI behavior.

### Ordered scope and checks

- `QUAT-NORM-01-SLICE`: open the bounded, correctly labeled fixed-d prime-norm slice; independent norm/predicate and projection fixtures. Depends on `GAUSS-MOAT-01-MAP` for the checked ordinary-prime provider and existing entry's companion seam, not on unrelated Gaussian live qualification.
- `QUAT-NORM-02-WALK`: legal nonrepeating slice walking, reachable component, norm coloring, explicit 3D/4D limits and PNG capture. Depends on the slice and `GAUSS-MOAT-02-WALK` for the checked interaction/capture behavior to reuse without a generic framework.
- `QUAT-NORM-03-QUALIFY`: native/browser journey, rotation/picking/depth fixtures, accessibility/localization, capped computation and decoded exports. Depends on quaternion walking.

Planned tests: `test/modules/prime_norm_quaternion_test.dart`, `test/features/viewer/prime_norm_quaternion_walk_test.dart`, and `integration_test/flows/prime_norm_quaternion_journey_test.dart`. They do not yet exist. Exclude full 4D graph/projection, half-integer Hurwitz walking, factorization certificates, unrestricted cubes, and a generalized quaternion moat claim. These remain explicitly deferred, not silently executable follow-ups.

### Autoresearch execution configuration (not started)

This config is a bounded implementation/verification handoff, not permission to run an optimization loop during planning. Scope follows the named tasks; preserve existing provider, renderer and export boundaries. Use the repository-pinned Flutter 3.44.6 toolchain. Do not increase a metric by replacing independent fixtures with implementation-derived expectations or weakening any boundary check.

```text
Goal: Deliver accurate bounded Gaussian-prime walking, radius growth and a prime-norm quaternion slice through the existing app experience.
Scope: lib/core/modules/**, lib/features/viewer/**, lib/features/renderer/**, lib/l10n/**, test/modules/*gaussian_moat*, test/modules/*prime_norm_quaternion*, test/features/viewer/*gaussian_moat*, test/features/viewer/*prime_norm_quaternion*, integration_test/flows/*gaussian_moat*, integration_test/flows/*prime_norm_quaternion*, test/playwright/**; only task-required integration seams.
Metric: required_prime_walking_test_targets_passing (0..4; passing complete targeted suites, not raw case count)
Direction: higher_is_better
Verify: python3 -c 'import pathlib,subprocess,sys; ts=["test/modules/gaussian_moat_model_test.dart","test/features/viewer/gaussian_moat_walk_test.dart","test/modules/prime_norm_quaternion_test.dart","test/features/viewer/prime_norm_quaternion_walk_test.dart"]; rs=[subprocess.run(["flutter","test","--no-pub",t,"--reporter","expanded"],capture_output=True,text=True) for t in ts if pathlib.Path(t).is_file()]; [print(r.stdout+r.stderr,file=sys.stderr) for r in rs]; print(sum(r.returncode==0 for r in rs))'
Guard: flutter analyze --no-pub && flutter test --no-pub
Iterations: 10 per authorized slice, checkpoint before proceeding to dependent work
```

Observed planning baseline: `0` of these four required targets pass because none of their files exists. The numeric Verify command was dry-run against the current checkout and returned `0`; it did not execute missing tests. Target: `4`, plus separately recorded browser/native journey, accessibility, measured capped-computation and decoded-PNG acceptance. A metric of `4` alone does not close either product goal. The future Flutter Guard and all feature behavior tests are unrun. The executed planning guard is canonical `goals.py validate`, not application qualification.

### Refinement evidence and task binding

The 272 indexed Dart inputs still match the earlier scoped Graphify copy byte-for-byte. Query `FractalControlsHud ExportOptionsSheet AppBottomSheet` returned an untruncated HUD/viewer/renderer neighborhood, including the extracted `FractalControlsHud` definition at `lib/features/viewer/chrome/fractal_controls_hud.dart:25`. AppBottomSheet is outside that graph; direct source at `lib/shared/widgets/app_bottom_sheet.dart:10–47` confirms the existing themed, landscape/safe-area-aware container. Graph topology does not prove the proposed layouts or budgets. Shader/doc semantics, self-loop/duplicate-label warnings and quaternion-query limits remain explicit.

The seven existing tasks own these contracts: MAP/SLICE own bounded generation, layout and transforms; WALK owns selection/commit, complete components, cancellation and capture; GROWTH owns the single-result playback schedule; QUALIFY owns rendered accessibility, instrumented limits and real exports. No task IDs, priorities, statuses, dependencies or active ownership change in this refinement. Exact per-task acceptance examples are in [the verification matrix](test-plan.md#prime-walking-refined-acceptance-matrix). All application checks remain planned/unrun; no task closes from this documentation pass.


## Viewer chrome footprint and action consistency

Status: Accepted

Source: the owner's `/autoresearch plan` request: back button is too intrusive and the three-dot menu needs a circle. The supplied Android screenshot shows a wide dark Back to catalog pill, a separate title pill, a tall action rail and unbacked overflow dots. Screenshot evidence establishes appearance only, not logical target dimensions, overlap hit testing or device behavior. This section authorizes planning/backlog changes, not implementation or timed scheduling.

### Bounded correction

- VIEW-UI-01: replace the persistent text-heavy Back to catalog pill with a compact circular arrow control. Keep the localized full label as tooltip and semantics; retain its stable key, direct catalog-pop behavior, absence when no route can pop, capture-mode suppression and export-disabled behavior. System Back must still dismiss overlays/cancel export according to existing tests. Do not make the hit target smaller to reduce visual obstruction: at least 48 logical pixels, and preserve 56px large-target mode. Keep the existing theme/high-contrast focus treatment. Place the title without colliding with the compact back control, safe-area insets or right rail. Exact title relocation beyond collision correction remains Proposed.
- VIEW-UI-02: put the existing three-dot PopupMenuButton in a circular dark surface consistent with the adjacent actions, including disabled, pressed, hover and keyboard-focus states. Reuse the current popup and callbacks; no new menu framework or dependency. Preserve export/share-link/share-image and supported wallpaper entries, keys, semantic/focus ordering, platform availability and exporting disablement. Verify menu dismissal restores focus and invokes no action.
- Additional screenshot findings: the rail is dense and visual weights are similar. Grouping/reducing visible actions is Proposed, not part of these two corrections. Preserve looper, Fourier and report direct-access guarantees and the existing secondary-only overflow decision in BLOCKERS.md. The referenced historical card t_4fdf9ad0 is not present on the current board; do not fabricate its status or recreate it. No renderer, gesture, mathematical label, persistence or export-pixel changes.

### Verification and success criteria

Use real viewer/widget RED/GREEN checks, plus before/after application screenshots at the same viewport and fractal state. Assert compact back and overflow circular surfaces, at least 48px hit areas (56px in large-target mode), unchanged callbacks/route behavior, EN/ES labels, keyboard activation and visible focus. Test logical widths 320/768/1024/1440, portrait/landscape, text scales 1/2, long module titles, high contrast, safe-area insets, open HUD, fullscreen, export-busy and capture modes. The title and controls must not overlap or overflow. Reduced motion must remain honored; no button animation is required by this task.

Metric: corrected screenshot defects with passing interaction/layout coverage, target 2/2. Baseline: two owner-reported visual defects; no current executed corrective tests. A source-only proxy is currently 0/2: back uses TextButton.icon at fractal_viewer_screen.dart:1930 and the overflow at fractal_view_controls.dart:671 has an unstyled icon. These facts explain the screenshot but are not fresh runtime qualification. The actual quality Verify is the new focused regression set added to `test/fractal/fractal_viewer_screen_widget_test.dart` and `test/fractal/fractal_view_controls_test.dart`; it is planned, NOT_RUN. Guard: `flutter test test/fractal/fractal_viewer_screen_widget_test.dart test/fractal/fractal_view_controls_test.dart --reporter expanded` and `flutter analyze`; both are NOT_RUN in this planning pass. Suggested bound: two implementation/check iterations per correction, four total, stop after acceptance; no optimization loop is started.

Reuse the existing P2-2 Overflow menu TODO entry by binding it to VIEW-UI-02, rather than creating a parallel migration of non-critical actions. Append these two bounded tasks to Next; preserve all existing task objects/order/focus and active workers. VIEW-UI-01 and VIEW-UI-02 are independent corrections, not artificially sequential. Real Android/browser/Linux UI and native screen-reader behavior stay unqualified until separately exercised.

Graph evidence: fresh seven-file code-only Graphify graph under `/home/xel/.hermes/profiles/fractal/cache/scratch/viewer-ui-plan-8b970285/graphify-out/graph.json`. Query `_ViewerOverflowMenu FloatingActionButtonWidget FractalViewerScreen` found source-correlated nodes at fractal_view_controls.dart:642,716 and fractal_viewer_screen.dart:130. The query truncates; renderer/export internals, full theme/service dependencies and semantic docs are unindexed. Source corroboration: back control at viewer_screen:1922-1958; popup at view_controls:657-713; adjacent controls retain focus/keyboard/hit-area paths at view_controls:810-891. Graph relationships do not prove rendered appearance or behavior.

Skill application: frontend-ui-engineering separates screenshot observations from source behavior and defines compact appearance without shrinking accessible targets. Planning-and-task-breakdown binds two independently testable corrections and reuses the legacy overflow entry. Documentation-and-adrs records the scope and Proposed action-hierarchy change in the existing spec instead of inventing an ADR. Existing repo-docs concurrency and STE-inspired rules preserve unrelated edits and uncertainty.


## Local MAP completion and canonical adoption boundary

The existing MAP ledger record is done for the locally committed and independently reviewed slice at `6e671957a30ea7b44a80f8cfc4a8d5d31c73dd73` (original card t_a925ef4e, review run 96). Canonical HEAD still lacks the model/plot files. The unchecked live body was corrected to match that local completion; this is not integration, milestone completion or platform qualification. Preserve the reviewed branch and require exact reviewed predecessor inputs for WALK/SLICE admission. The current viewer-first planning focus is recorded in PRD.md#quality-first-planning-priority. No acceptance metadata is restored over a changed nested scope: viewer styling is accepted only within its existing two-correction contract, quality discovery remains Proposed, and OpenAI candidates remain Proposed.
