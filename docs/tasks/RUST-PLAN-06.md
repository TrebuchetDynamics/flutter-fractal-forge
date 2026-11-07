# Reachable Rust kernels and exact native transport frontier

## Brief and authority

RUST-PLAN-06 completes **Plan round: 5 of 10** for
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md). Status: Accepted within the
[owner-approved migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
This is the focused Plan For Me continuation, not implementation or a backlog sweep.
All choices below are **planner calls**, not new owner decisions. The goal remains
**unmet**. Preserve every earlier ID, closure, baseline and authorization gate.
No per-field or whole-session owner switch occurs in this batch.

Inspection base: `44461bbff61c15574e6ce07ad6d3387ce2338eba`; checkout initially clean.
The supplied executable reports prepare API 4. Read-only preparation of this checkout
and the canonical consumer reports READY, without conversion actions or pending
migration. The consumer has a live coordinator lease; read-only status shows zero
running workers and zero candidates awaiting integration. This isolated checkout is
the sole writer for this batch. Canonical main is older than the execution branch;
a local planning commit is not delivery to main. Preserve the owner's first Now task,
ACAD-013-4142ef42, at rank 1000. Initial validation: 143 tasks, 21 goals, no drafts or
pending records. Legacy prepare diagnostics are not task-validation errors and are
outside this single trigger. No RUST-PLAN-06 slot report or saved ledger patch was
found. There is no proposal to replay or reason to undo newer verified closures.

## Finished evidence and limits

Read the four records, receipts, component notes and actual `attempt-1/report.json`
files in place under `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/`.
Private reports were not copied into this checkout. Results below are **reported
execution**, not tests rerun during planning. All four records are already
`coordinator_verified`; their candidate commits are ancestors of this checkout.

| Task / candidate | Reported result | Proof limit |
|---|---|---|
| RUST-M2-GRID / `defaabad045d9cb199455361651b6067f5d69655` | Isolated arithmetic provisioning succeeded, adding only num-bigint 0.4.6 and its required three-package closure. Five grid tests include 971 independent cases/fingerprint 196b53dc; 35 workspace and eight Dart tests passed. | Exact six-sequence arithmetic and bounded resumable grids, not prime certification, app routing or wall-clock responsiveness. |
| RUST-M2-FRAME / `507d9b580e2d37edf79d01b65d33cbf96f1d659f` | Twelve frame/grid/prime tests, 38 workspace tests plus private-frame compile-fail doctest and 15 Dart oracles passed. | Certified immutable frames and actual previous-proof/grid reuse. No executor/native delivery. Preserve its crate-private grid handoff. |
| RUST-M2-INGRESS / `393f183012b9f338786111f10a4921bc37421659` | Sixteen focused tests, 49 workspace tests including doctests and 22 Dart oracles passed. All 68 original events compare twice; drift at 47/67 is rejected. | Inert session request ownership and core parity, not full M2. Preserve its crate-private frame restyle helper and MAX-2/MAX-1/MAX terminal-revision reservation. |
| RUST-M2-EFFECTS-BRIDGE / `6e4f1f90b7fea100accc6405f64b24a380fd7a59` | Three effect plus four session bridge tests, 33 workspace tests, identical complete five-file FRB inventories, analyzer/adapter checks, Linux/APK scalar-fixture and both Web flag builds passed. | Eleven generated effect methods/getters, not executed native effects. Existing four-module fixture never calls them. No installed/browser/hardware proof upgrade. |

The reports have no final setup/environment failure requiring recovery. Their
historical component notes describe their own delivery boundary, not a reason to
reopen them after later consumers landed. Previous Linux/Waydroid scalar execution
in [RUST-PLAN-05](RUST-PLAN-05.md#finished-evidence-and-limits) remains limited to four
modules. Rejected large stale input operands do not prove successful high-u64 output.

## Source observations and selected cut

- `session.rs:26–32,250–261` still rejects trajectory presence and supports only
  seven named modules. The original replay has no trajectories, randomization,
  undo, animation or physical gestures. Do not remove those rejection tests or
  call all 68 events a complete controller port.
- `attractor_trajectory_settings.dart:44–127,145–225` defines version 1/rk4, finite
  seeds, `0 < stepSize <= 0.1`, retained samples <=20000 and total steps <=25000.
  Only thomas_attractor/thomasOblique, four_wing/xz and lorenz_2d/xz are compatible;
  the legacy Thomas alias is not. The model owns RK4, projections, burn-in,
  immutable samples/bounds and per-step finite safety checks. Existing short-step
  oracles use absolute tolerance 1e-12 and convergence distance <1e-4. Do not demand
  bit-identical long chaotic orbits or claim a new mathematical result.
- `gesture_handler.dart:325–431,527–591,675–706,926–937` owns inverse camera mapping,
  focal zoom/pinch math, 3D target/tilt conventions and wheel `exp(-dy * 0.001)`.
  **2D screen mapping deliberately uses rotation zero**, even when stored rotZ is
  nonzero. Pan and zoom momentum already have elapsed-time pure helpers and
  schedule-invariance tests. Port a testable numerical seam first, not recognizers,
  widget capture, interaction callbacks or timers.
- `session_number_wall.rs:71–192` already supplies begin/advance/cancel and a
  Rust-local revocable guard. Frame stepping is bounded, with no executor. The
  bridge exposes neither these operations nor exact frame/status getters. Its
  current mutex serializes snapshot/batch/shutdown. Reuse that lifecycle; never
  hide a complete mathematical job in synchronous apply_batch.
- `run_state_session_smoke.py:14–17,41–71` and its tests enforce original hashes,
  complete ordered records and derived provenance. The current four-module target
  has fixed projected hashes. Preserve that mode and target byte-for-byte. An
  additional seven-module mode can include both forced kaleidoscopes and Number
  Walls. Read-only size calculation using the existing lexical-number serializer,
  provenance shape and zlib/base64 protocol yields **12288/32768 bytes**, including
  RUST_CORE=true. This is a reachable input-size calculation, not a build/test pass.

**Planner call:** save four building tasks and one successor, five new tasks total.
Pure kernels can be proved without changing session ingress. Exact bridge transport
then supplies a real input seam for an extended native fixture. Reject a full
controller rewrite, a new runtime/dependency or per-field app routing. Reject
scheduling installed tests against the old scalar target: it cannot prove the new
methods. Randomization/undo and animation require their own source-derived state
contracts and are retained below, not silently treated as delivered by kernels.

## Decided kernel contracts

### Trajectory kernel

RUST-M2-TRAJECTORY owns a pure `trajectory` module and one public test seam. Reuse
serde/serde_json and standard-library owned immutable storage, without a new cache
framework or dependency. Provide validated settings JSON encode/decode, exact enum
spellings, defaults/compatibility, RK4 integration, projection, and an incremental
trajectory job. Numeric JSON round trips preserve values and schema, not Dart's
incidental string formatting/cache-key spelling. LRU policy and session storage are
later consumers. No public field combination may bypass validation.

Generation uses the existing derivatives and operation order. Distinguish integrate's
finite-only check from generation's finite and absolute-coordinate <=1e12 check.
A planner-selected maximum of 256 integration steps per advance matches the Dart
async default; yield during burn-in and retained work. Account for projected bounds
incrementally, so finalization does not hide an unbounded sample scan. Check Rust-local
cancellation at steps and final publication; no partial trajectory escapes. Synchronous
helpers drive the same kernel. Preserve tests for absent/malformed/legacy/incompatible
settings and all safety caps. Session/bridge continue to reject trajectories until
later complete ingress and snapshot work qualifies them.

### Physical camera kernel

RUST-M2-PHYSICAL owns a pure `physical_view` module, not an event state machine.
Use scalar arrays and existing ViewInput/normalization types. Expose explicit pure
operations for pixel-to-world delta, 3D target delta/orbit tilt, focal zoom/2D pinch,
wheel target, double-tap target and elapsed-time pan/zoom momentum. Inputs carry
viewport/focal/start/current values, dimension, rotation-lock decision and module
horizontal orbit sign; no clock, widget or callback dependency. Preserve source
soft rubber-band strength 0.5 before the existing hard normalization. Preserve
safe zoom floors, 2D zero screen rotation, 3D height-versus-min-dimension scaling,
67.5-degree x tilt cap and module orbit direction. Rotation lock suppresses gesture
rotation, not direct rotation commands.

Momentum retains pan decay 0.95/cutoff 0.1 and zoom decay 0.92/cutoff 0.0001,
16000-microsecond reference frames and zoom travel factor 0.016. Port existing
cadences/tolerances (pan 1e-8 schedule/1e-10 one-step, zoom 1e-12), zero/negative
elapsed behavior and zoom nonfinite behavior. Test composed finite input transforms
against source equations with absolute tolerance 1e-12 for ordinary-sized fixtures,
then hard-normalize through the existing module bounds. Do not silently add new
acceptance for nonfinite pan velocities beyond the Dart source contract.
Recognition thresholds, pointer handoff, keyboard dispatch, tap classification,
velocity history, delayed-completion ownership and actual Session physical-input
commands remain later work. This kernel alone does not move physical-input ownership.

## Exact bridge and native fixture contracts

### Bounded Number Walls transport

RUST-M2-WALL-BRIDGE extends the existing opaque API. A separate opaque guard can be
created active/inactive and monotonically revoked without acquiring the session
mutex. Begin consumes one fresh typed command, clones that guard and returns an
optional opaque owned request containing the private core token. No arbitrary
token, revision, identity, grid or certificate constructor is exposed. Request
arguments for advance/cancel are borrowed so a caller can retain them across steps.
Immediate/inactive begin follows the existing core behavior and returns no request.

Advance/cancel validate supplied u64 identity/revision, delegate once to core and
return detached typed progress plus the same-lock snapshot. Each advance performs
**one** existing bounded step; no drain loop, sleep, foreign callback, new async
runtime or background thread. Zero work checks revocation. Use u32 work/budget
inputs and checked conversion, not a float. This is a transport seam, **not the
production off-UI executor**. Explicit fixture driving is allowed; an app route
must wait for executor qualification.

Snapshots expose pending presence, typed exact status and optional opaque retained
frame. Frames expose detached params, sequence/modulus/dimensions/origin/support
and the complete grid as one nested decimal-string collection, not per-cell FFI.
Only certified core frames create these handles. Reuse current error/lifecycle,
request supersession, guard, revision-reservation and rollback rules; shutdown
drops pending work, rejects session calls and leaves retained read-only handles
valid. A stale old handle cannot cancel or publish over a successor. Preserve all
existing sync methods and deferred mixed-batch rejection. Add no core semantics.

Regenerate the complete existing five Rust/Dart outputs twice using FRB 2.11.1 and
cargo-expand 1.0.127; retain equal SHA-256 inventories. Use opaque named methods and
simple enums to avoid undeclared Freezed/collection dependencies. API names and
internal layout are worker-reversible within these shapes and behaviors.

### Extended native fixture producer

RUST-M2-EXTENDED-FIXTURE consumes that transport plus the landed effects bridge.
Add `--extended` before the launcher's `-- COMMAND` separator and a separate
`rust_state_extended_smoke_test.dart` target. Default invocation still emits the
original four-module bytes/hashes. Extended mode projects seven **complete** source
records per envelope in original order; retain exact number lexemes, original
hashes, derived source-set/projection provenance, define-override/inherited-define
rejection and the 32768-byte Flutter-encoded aggregate guard including caller flags.
Never truncate records or raise the budget to make an input fit.

The new target calls all eleven effect constructors/getters and proves forced →
forced → ordinary hidden restoration, rollback and retained values. It explicitly
begins/steps/cancels Number Walls work, compares canonical settings and every grid
cell with the existing Dart frame/model oracle for small exact cases, tests invalid/
composite/unverified retention, supersede/revoke/navigation and wrong/stale identity,
and retains/disposes native handles correctly. Assert pending/terminal revision
changes, independent sessions, duplicate shutdown/post-close behavior and detached
frame readability after navigation/close. No sleeps or fabricated expected results.
Keep default-off/rendering=false and no app/renderer route. Large stale operands
remain input-only evidence. Do not add a public identity setter for high-u64 outputs.

This task owns Python projection/protocol tests, target analysis and Linux/Android
compilation only. Tests inside the compiled target are **unexecuted native assertions**
until later installed Linux and Waydroid runs record terminal results. Do not run
native installation/journeys in this producer or call compilation native success.
Keep both Web root flag builds as regression, not browser/WASM proof.

## Saved executable batch

| ID | Observable outcome | Source-backed prerequisites | Placement |
|---|---|---|---|
| RUST-M2-TRAJECTORY | Validated settings, bounded RK4/projection/immutable trajectory kernel | Original Dart settings/model and tests | Now, below owner-first work |
| RUST-M2-PHYSICAL | Pure physical camera and elapsed-time momentum math | Landed RUST-M2-NORMALIZATION and original gesture/momentum oracles | Now, below owner-first work |
| RUST-M2-WALL-BRIDGE | Generated typed request/guard/progress/exact-frame transport | RUST-M2-INGRESS and RUST-M2-EFFECTS-BRIDGE | Now, below owner-first work |
| RUST-M2-EXTENDED-FIXTURE | Source-bound seven-module effects/frame native target and offline build proof | RUST-M2-WALL-BRIDGE and RUST-M2-EFFECTS-BRIDGE | Next |
| RUST-PLAN-07 | Reconcile these results and expand the next reachable whole-session/runtime frontier | Every new building task above | Next, Plan round: 6 of 10 |

Kernel modules and the bridge have independent outcomes. The two kernel tasks both
export through core lib.rs; this cold-file overlap is disclosed, not a prerequisite.
The fixture genuinely consumes the new bridge API. No overlap-only dependency or
resource is added. Scheduler hot-file, resource and protected-path admission still
applies; no execution concurrency is promised. Only the bridge owns generated files.
Every worker owns its designated component result note, not tasks/ or shared history.

## Remaining proof and continuation

The complete [prior remaining proof](RUST-PLAN-05.md#remaining-proof-and-continuation),
[remaining M0–M14/final map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary-domain inventory](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained)
and [predeclared physical protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol)
are incorporated unchanged. This batch removes none of their gates or thresholds.

- M0 originals/provenance and M1 target-bound nonrendering evidence remain intact.
  All 68 core events, numerical kernels and generated APIs are not full M2 proof.
- M2 still needs typed trajectory Session ingress/snapshots/compatibility (including
  legacy-null views), actual module semantics, deterministic general and Number Walls
  randomization/undo, interpolation/animation/timer ownership, complete physical event
  transactions (wheel/pinch anchor, drag/fling, keyboard, double tap, rotation lock),
  off-UI executor/job scheduling, stale native snapshots/frames and installed effects/
  frame round trips. Sources for the next state cut are fractal_controller.dart:603–740
  (seed masking, draw order, six opt-in primes, successful-only single undo frame,
  current-view undo, 600 ms parameter interpolation), its morph/animation owner and
  gesture_handler.dart's pointer history/handoff/interaction completion. Do not invent
  Rust/Dart RNG equivalence; first derive the existing seeded oracle and exact draw
  contract. This batch does not resolve or waive that later port.
- High-u64 successful output needs a reachable test-only production-codec producer
  before installed proof; low counters and wrong-input rejection are insufficient.
  Do not expose an arbitrary identity setter. Extended-fixture compilation precedes
  scheduling actual official-driver Linux and designated Waydroid execution. Preserve
  source/artifact identities, terminal results and owned cleanup; an executor is still
  absent. Device/browser availability is unassessed, not a new consent question.
- Snapshot-only legacy rendering, editor/preset/history/deep-link **app routing**,
  rollback without lost state and the whole-session switch still follow complete
  state/executor parity. No per-field owner switch or flag enablement.
- M3 runtime registry/catalog/presets/capabilities retains both identity namespaces,
  production/debug/performance/hidden filtering, order, exact values, provenance and
  presentation mapping. Baseline readers and seven fixture modules are not runtime M3.
- M4 exact float uniforms/separate samplers/versioned bindings; M5 boundary neighbors,
  capabilities/hysteresis; M6 honest CPU formulas/tiles/cancel; M7 reference orbits,
  deep coordinates/double-float/perturbation remain separate proof.
- M8 Linux external texture/Android surface, no per-frame Dart bytes, durable GPU
  resources/latest-state mailbox, resize/orientation/loss/background/fences/cleanup
  and physical qualification remain. M9 edited Mandelbulb/depth, M10 all families,
  M11 Rust backend/scheduler/viewport ownership remain required.
- M12 pinned-revision 4K/8K PNG, bounded memory/cancel/dimensions/crop/color/alpha;
  M13 saved/import/history/deep-link compatibility; M14A WASM/legacy rendering and
  M14B real-browser WebGPU/export/download remain separate gates. Web is not stranded.
- Final audit retains Fourier/image/Cantor analysis, RK4, exact Number Walls,
  Gaussian moat, quaternion prime norms and all actual mathematical owners. No absent
  audio feature. Audit imports/dependencies and routing, not suffixes. Flutter retains
  UI/l10n/accessibility/platform I/O; default-off flags and standing consent persist.
- ADRs 0005/0006 retain device/GPU/refresh/backend/build/viewport/trace declaration,
  5 s warmup, 30 s measurement, compositor-present revision markers and distributions.
  At 60 Hz: p95 interval <=1000/60 ms, max stall <=100 ms, p95 input-to-present <=50 ms.
  Optional 120 Hz requires compatible physical hardware and its own <=1000/120 ms run.
  Waydroid remains the designated Android functional target, not physical GPU proof.

No owner-only gap blocks these offline tasks. Missing tools/cache/transport/capacity
remain exact technical failures with task/operation/source/evidence returned to the
same coordinator and candidate, not replacement tasks, an interview or skipped success.

## Verification and handoff

All building commands are **proposed/unrun in this planning pass**. Reuse root
AGENTS.md's exact Full check with pinned Flutter 3.47.9/Dart 3.13.7, Rust 1.95.0,
existing isolated PUB/CARGO/FRB caches, checkout-local lockfile-enforced resolution
and private TMPDIR. Compare Flutter with fdroid/flutter.version and verify the actual
host's provisioned /usr/bin/python3 pytest/jinja2/markupsafe imports first. Android
uses the existing target-enabled cached RUSTC documented in RUST-M2-BRIDGE. No install,
lock update or ambient fallback. A worker can fix attributable check-blocking defects
inside its declared Touches without weakening assertions. Focused worker checks and
the runner's merged-tree/full-main gate remain distinct; do not loop the full suite.

Premortem: trajectory divergence/partial results → short-horizon/convergence and
bounded cancellation tests; changed camera direction/timing → zero-rotZ/3D/sign and
cadence oracles; false native proof → complete provenance/aggregate guards, actual
new target builds and explicit installed/unexecuted boundary. No measured speedup.

Planning checks passed: five saved task records read back exactly; 17 scoped local
links/Sources/anchors; five-task cap, four-build successor and round checks; exact
root Full check in every building record; original planning contract and unmet goal
preservation. A fresh read-only builder review found **nothing important left** and
independently confirmed the seven-module 12288-byte calculation. No implementation,
generation, analyzer, build or device test was run by that review. The supplied
validator reports 148 tasks, 21 goals, no drafts and six expected uncommitted task
records; post-commit validation must clear those pending records. Bundled docs.py
stale/check exit 0 with no docs/roles.json manifest, not repository-wide coverage.
The scoped readback supplies this batch's link coverage. Whitespace/diff checks and
post-commit selection readback remain part of the handoff.

Expected delivery is four independently reviewed building results, separate from
this one planning commit. Close RUST-PLAN-06 manually with this document as evidence,
not a receipt or goal qualification. Keep exactly one open successor, RUST-PLAN-07,
**6 of 10**, depending on all four new building tasks. The same authorized coordinator
continues the chain on its own; this pass dispatches nothing. Move RUST-PLAN-07 to
Needs decision to stop it. At round 10 or without new building work, preserve the
BLOCKERS stop question and an open remaining-proof record unless actual ledger
qualification proves the goal met. Empty queues never establish completion.
