# Rust session state and executed native request frontier

## Brief and authority

Status: Accepted within the [owner-approved migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
This completes RUST-PLAN-07, **Plan round: 6 of 10**, under
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md). The request is focused
planning, not implementation or a backlog sweep. All engineering choices below
are **planner calls**, not new owner decisions. The goal remains **unmet**.
Preserve whole-session ownership, saved formats, exact values, source provenance,
mathematical honesty, default-off flags and the working Flutter renderer.
No per-field switch, installation, publication, receipt or goal qualification occurs here.

Inspection base: `44eb506c4dcdf093a55b8a10c8a709ccf1639689`; this checkout was clean.
The supplied executable reports prepare API 4. Read-only preparation reports READY
for this checkout and the actual canonical consumer, with no conversion actions.
Initial validation: 148 tasks, 21 goals, no drafts or pending records. Read-only
canonical runner status shows zero running workers and zero awaiting integration;
RUST-PLAN-07 is pending planning, not a live worker or retained candidate. No
RUST-PLAN-07 slot directory or saved task-ledger patch was found. No patch is replayed.
The owner-first ACAD-013-4142ef42 remains first in Now, rank 1000, unchanged.
Canonical main is `cd72841992b4e4d8d8365d8276fb4adf16e30490`, with seven unrelated
dirty widget-test files. This batch writes only this isolated checkout; local
commit/validation is not delivery to main. Legacy preparation diagnostics are not
validation errors and are outside this trigger. No code graph was used.

## Finished evidence and limits

Read the four task records and actual `attempt-1/report.json` files **in place**
under `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/`.
Private reports are not copied into this checkout. All four closures are already
`coordinator_verified`, and their candidate commits are ancestors of this checkout.
These are reported results, not checks rerun during planning.

| Finished task / candidate | Reported result | Remaining boundary |
|---|---|---|
| RUST-M2-TRAJECTORY / `2d9145d1060135bafd4b9ecdde0e255571a814b9` | Nine public trajectory tests, 58 workspace tests/doctests and 13 unchanged Dart oracle tests passed. Validated settings and bounded RK4 jobs landed. | No trajectory Session ingress, cache/service, bridge or renderer ownership. |
| RUST-M2-PHYSICAL / `4045df89b94a8dd2e15497d98f783de9e1f46e2e` | Eleven physical kernel and five normalization tests, workspace checks and 44 unchanged Dart tests passed. | No event state machine, pointer handoff, keyboard, timer, fling boundary damping or interaction completion ownership. |
| RUST-M2-WALL-BRIDGE / `9a5e92f3b0d1c4eca2f43d295498576ea415a90d` | Eleven public bridge tests, Rust checks, equal twice-generated five-file inventories, analyzer/adapter checks and scalar Linux/APK/Web builds passed. | Bounded synchronous transport, not off-UI execution or installed new-method proof. |
| RUST-M2-EXTENDED-FIXTURE / `66cc97c109d36726552ae0637d12995a40a8de7b` | Eight Python cases, analyzer, 18 offline Dart tests, Linux/APK and both Web flag builds passed. Seven complete modules use 12288/32768 encoded bytes with RUST_CORE=true. | Four new native assertion cases are compiled, not executed. High-u64 output, executor, browser, hardware and full-session proof remain absent. |

None reports a final environment/setup failure requiring recovery. Existing
[RUST-M2-LINUX-STATE](RUST-M2-LINUX-STATE.md) and
[RUST-M2-WAYDROID-STATE](RUST-M2-WAYDROID-STATE.md) execute only the old four-module
scalar target. They cannot qualify effects, exact frames or future async methods.
Rejected large stale operands still prove inputs only, not successful high-u64 outputs.

## Source observations and chosen cut

- `session.rs` supports seven modules and rejects non-null trajectory markers.
  `trajectory.rs` now supplies private validated version-1/rk4 settings and exact
  three-module compatibility. `FractalViewState.copyWith` preserves trajectory
  metadata for scalar camera updates; initial/reset view clears it. Controller
  `updateView` and input normalization drop valid-but-incompatible metadata. The
  existing 68-event replay has no trajectory, randomization, undo or timing events.
- `fractal_controller.dart:603–681` defines both randomization paths. Ordinary
  schemas are visited in order; palette IDs consume no draws. Number Walls masks
  the materialized seed to 31 bits, draws source then four colors, optionally a
  sixth draw from six primes, and saves exactly one undo frame only on successful
  commitment. Undo restores the previous exact grid/params but uses the current
  camera/transparency. The existing test mostly checks replay/ranges, not exact
  draw streams. A Rust PRNG cannot be assumed equivalent to Dart Random.
- `fractal_controller.dart:684–740` has 36 parameter steps, scheduled every 16 ms,
  from nominal 600 ms at 60 fps. Cubic easing uses the **step**, not measured wall
  time. Before the final step, palette, boolean and enum values stay at `from`;
  numeric values interpolate then use the shared normalizer. The final step
  assigns the complete target, including discrete values. Morph scheduling has a
  related cubic curve but distinct state/completion behavior.
- `api.rs:715–860` serializes Number Walls begin/advance/cancel through the existing
  session mutex. Generated wrappers currently use `wrap_sync`. The cached locked
  FRB 2.11.1 `handler/implementation/executor.rs:49–81` routes **normal**, non-sync
  calls through its existing thread pool. No new async runtime or background
  service is needed to move one bounded step off the Dart call stack.
- The extended launcher and target already provide source-bound seven-module
  inputs, full exact-grid assertions and explicit handle disposal. Reuse this
  protocol for a separate async target; do not fork or refresh baseline catalogs.

**Planner call:** save six building tasks and one successor, **seven new tasks total**.
Keep trajectory state, a randomization oracle and parameter interpolation independently
testable. Add normal-mode FRB request-step methods plus a compile-only async fixture.
Then execute both native targets separately on Linux and designated Waydroid.
Reject a full controller rewrite, invented RNG equivalence, a second executor/runtime,
per-field app routing and build-only/native-proof conflation. The randomization oracle
is a real test-input producer, not a claim that Rust randomization/undo has landed.

## Trajectory session state

RUST-M2-TRAJECTORY-STATE extends the inert core Session, not the public Dart trajectory
API. Store optional validated `OrbitTrajectorySettings` in detached snapshots and
accept typed settings at core camera ingress. Admit only `thomas_attractor`,
`four_wing` and `lorenz_2d` in addition to the seven current modules, using their
original complete catalog records. Decode preset metadata using the landed settings
parser. Missing/null remains the legacy portrait; malformed non-null data fails
atomically; valid incompatible settings are dropped just as Dart does.

Preserve settings on scalar zoom/pan/rotation and parameter changes, clear on
initial/reset view, and carry/normalize them through select/load/preset/updateView
according to existing controller and saved-view semantics. Retained snapshots must
not change after mutation. Original replay outputs must remain byte-identical.
Test actual module defaults, legacy-null views, valid cross-system incompatibility,
invalid JSON and failed-batch rollback. Keep Number Walls pending-work cancellation,
revision reservation and retained frame semantics intact.

The core camera representation and names are worker-reversible. Adapt the bridge's
private `StateCamera::into_core` mapping only as needed for compilation: the public
`hasTrajectory=true` marker contains no settings and must still reject, never invent
a trajectory. Preserve public Dart API/generated bytes. Existing core rejection
assertions may be updated only for the new typed supported cases; retain malformed,
unrepresented-marker and unsupported-module rejection. No integration job runs
synchronously during apply_batch, and no cache/render consumer is introduced.

## Seeded randomization oracle

RUST-M2-RANDOM-ORACLE creates a separate `migration/oracles/randomization.json`,
`test/migration/randomization_oracle_test.dart` and a focused support helper. Reuse
existing deterministic JSON/source-binding patterns, not the old baseline outputs.
Capture exact results from unchanged production Dart Random/controller/helper APIs,
not expected values reconstructed with a proposed Rust algorithm.

Planner-selected finite seed set: 0, 1, 42, 2147483647, -1 and 2147483648. Record
ordinary no-animation output for mandelbrot/julia and a synthetic schema covering
all five FractalParamType kinds, preserving actual schema order, enum underlying types, inclusive integer
bounds, Julia radius 0.35, step/rounding behavior and palette no-draw behavior.
For injected general randomization, use a delegating Random recorder to log method,
bound, value and order without changing the seeded generator. Number Walls constructs
Random internally: record actual public-controller outputs; any explanatory draw
transcript uses the same pinned generator/source order and is checked against those
outputs, not claimed as instrumentation. Number Walls runs use small 4x16 grids,
custom prime 97 and both modulus opt-in states; record exact cells, status, params,
materialized seed and successful undo using a changed current camera/transparency.
Add deterministic cancel/navigation or rejected-ingress cases proving unsuccessful
work cannot overwrite a previously committed undo frame; follow actual source behavior,
not a new undo policy. Record each reached public action and result explicitly.

The fixture binds source hashes, pinned Dart version, scenario inputs and full
expected outputs. Two runs must agree; mutate a nested expected value to prove
comparison fails. An explicit scratch-export define can follow the existing replay
pattern, but normal checks never silently overwrite fixtures. Source drift requires
review, not automatic promotion. Do not modify the original M0 baselines or production
Dart code. This is VM/Dart oracle evidence, not Web RNG parity, a stable cross-version
RNG promise, a Rust randomizer or undo Session ownership.

## Parameter interpolation kernel

RUST-M2-INTERPOLATION owns a pure `param_interpolation` module and one public test
seam. Reuse catalog parameter types and `normalize_parameter`. Inputs are schema,
from/target maps and an explicit step index. Use 36 steps and `1-(1-step/36)^3` for
steps 1–35; step 0 returns from; step >=36 returns the full target. Retain source
fallback-to-default values, palette preservation and interim bool/enum behavior,
Dart ties-away-from-zero integer rounding, normalization/clamping and exact decimal
strings. Do not interpolate decimal text or relabel it as binary64.

Port source-derived fixture cases for fractional/integer/discrete/missing values
and palette behavior. Use a new focused Dart oracle test without sleeps, executing
the existing controller under fake time: observe ticks 1, 18, 35 and 36, target
replacement and cancellation on module/reset/dispose. Compare ordinary numeric
fixtures with absolute tolerance 1e-12 and exact integer/bool/enum/text values.
Keep the existing real-time regression unchanged. The pure Rust kernel has no
Session timer, morph, render, event or clock ownership; those remain explicit future
consumers. Do not conflate 36 x 16 ms with a measured 600 ms completion guarantee.

## Off-UI bounded request transport

RUST-M2-ASYNC-STEP adds normal-mode counterparts of begin/advance/cancel and async
snapshot/shutdown to the existing `StateSession`; keep every synchronous method.
Use ordinary Rust functions without `#[frb(sync)]`, so generated Dart returns Futures
and FRB's locked thread pool executes them. Reuse one private implementation per
operation to avoid diverging policies. Borrow request/guard handles through awaiting;
consume fresh command/value inputs exactly once. Guard revocation remains immediate
and lock-free. One advance delegates one existing bounded step, never drains a job.

Identity/revision checks happen at execution under the same mutex. Concurrent stale
calls reject; there is no hidden retry or input coalescing. Shutdown remains idempotent;
queued calls after close reject; held snapshots/frames remain readable. Deterministic
Rust barriers/channels can test stale/supersede/revoke/close ordering without sleeps.
Do not add an app scheduler, change core semantics or claim a thread-pool facade is
complete production job scheduling.

Regenerate all five existing outputs twice with FRB 2.11.1/cargo-expand 1.0.127 and
compare complete SHA-256 inventories. Add `rust_state_async_smoke_test.dart`, using
the unchanged --extended inputs and actual Future methods for staged exact-grid work,
revocation, stale rejection, supersession and close. Preserve old targets/assertions.
Analyze and compile for Linux/Android x86_64, retaining both Web flag builds.
Native assertions remain **unexecuted** in this producer. Generated wrap_normal plus
locked executor readback proves dispatch wiring, not measured UI responsiveness.

## Installed native qualification

RUST-M2-LINUX-EXTENDED and RUST-M2-WAYDROID-EXTENDED each consume the landed extended
and async targets, and run **both**. Their actual prerequisites are those producers,
not trajectory/interpolation/random-oracle work. They retain source, input, target,
launcher, toolchain, artifact/SO and backend identities, full terminal results and
owned cleanup in durable private slot evidence. Component notes give results and
limits without publishing private logs. They may repair reproducible check-blocking
fixture/launcher defects inside Touches without weakening assertions or provenance.

Linux uses the official integrationDriver through `scripts/run-native-integration.sh`,
real worker `AUTOWORK_PORT_BASE` and private TMPDIR. Each target requires run.json
exit_code=0, protocol_success=true, cleanup.remaining_pids=[] and official
protocol-success.json allTestsPassed=true. Compilation, raw flutter test -d linux,
a probe-only run or a supplemental launch does not substitute.

Android uses only the existing [standing Waydroid target and consent](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target).
Rediscover serial; verify get-state=device, native model `WayDroid x86_64 Device`
and boot=1; export matching ANDROID_DEVICE/ANDROID_DISPOSABLE_DEVICE. Existing owner
consent covers both app-test targets, not a new device/profile, unrelated deletion,
reset, publication or interruption. Record the existing consent in typed fields,
not a new planner grant. Use the working diagnosis/reconnect/authorization contract
on a broken transport; retain exact errors and next diagnostic. Use owned reserved
host forwarding as required by the current worker protocol, not SDK edits or random
ports. Serial/helper/RUNNING success is not a passed test. Require terminal Flutter
exit 0 for both real native targets and owned test/forward cleanup. An infrastructure
failure goes to the same coordinator/candidate; no replacement task or owner interview.

Neither task qualifies high-u64 successful output, full M2, physical hardware, Web,
rendering or performance. Current low counters cannot reach high outputs; build a
separate fixed test-only production-codec producer before that later qualification.
No arbitrary public identity/revision setter is permitted.

## Saved batch and admission

| Task | Prerequisites | Placement |
|---|---|---|
| RUST-M2-TRAJECTORY-STATE | RUST-M2-TRAJECTORY, RUST-M2-INGRESS | Now, below owner-first task |
| RUST-M2-RANDOM-ORACLE | Existing Dart owners/tests | Now |
| RUST-M2-INTERPOLATION | RUST-M2-NORMALIZATION | Now |
| RUST-M2-ASYNC-STEP | RUST-M2-WALL-BRIDGE, RUST-M2-EXTENDED-FIXTURE | Now |
| RUST-M2-LINUX-EXTENDED | RUST-M2-ASYNC-STEP, RUST-M2-EXTENDED-FIXTURE | Next |
| RUST-M2-WAYDROID-EXTENDED | Same two producers | Next, existing live/waydroid consent only |
| RUST-PLAN-08 | Every six new building tasks | Next, Plan round: 7 of 10 |

Cold core lib.rs/api.rs and native fixture/launcher overlap is disclosed, not a
product prerequisite or permission to narrow Touches. Only ASYNC-STEP owns generated
outputs. Directory/test overlap ranks admission; literal hot files, shared resources
and protected-path rules still apply. Waydroid retains live/waydroid resources and
coordinates ACAD-013-4142ef42 without changing that task or adding a false dependency.
Each worker owns its designated result note, not tasks/ or shared history.
Six implementation outcomes require their normal independent review/integration;
this planning commit is separate. No parallel-execution or capacity promise is made.

## Remaining proof and continuation

Incorporate the entire [RUST-PLAN-06 remaining proof](RUST-PLAN-06.md#remaining-proof-and-continuation),
[M0–M14/final map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary inventory](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained) and
[physical measurement protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol)
without changing any gate or threshold.

- M2 next consumers: derive an actual Rust seeded RNG from the new exact oracle,
  then general randomization and staged Number Walls successful-only undo; connect
  interpolation to a single ordered Session time/event owner. Physical transactions
  must carry raw viewport/focal/scale/key/pointer history, not Dart-computed camera
  state; reuse physical_view for ordered wheel/pinch/drag/fling/double-tap/rotation-lock
  semantics. Retain recognition thresholds, pointer handoff, boundary damping,
  delayed interaction completion and no-layout fallback. Use explicit time/tick
  inputs for deterministic tests, not sleeps or a second mathematical UI timer.
- Normal-mode bounded methods do not implement bounded job admission, fairness,
  scheduling, trajectory cache/jobs or full animation/morph ownership. Installed
  assertions do not prove responsiveness, runtime race exhaustion or hardware timing.
- A successful high-u64 output producer and installed Dart readback remain required.
  Never substitute rejected operands, Rust-only codec tests or an arbitrary setter.
- Complete remaining module semantics, stale snapshot/frame handling, editor/preset/
  history/deep-link app routing and snapshot-only legacy rendering must precede the
  whole-session switch and rollback-without-state-loss qualification. No per-field switch.
- M3 runtime registry/catalog/presets/capabilities preserves both identity namespaces,
  production/debug/performance/hidden filtering, order, exact values, provenance and
  presentation mapping. Baseline loaders are not runtime M3.
- M4 exact float uniforms/separate samplers/versioned bindings; M5 boundary neighbors,
  capabilities/hysteresis; M6 honest CPU formulas/tiles/cancel/off-UI; M7 reference
  orbits/deep coordinates/double-float/perturbation remain independent proof.
- M8 Linux external texture/Android surface, no per-frame Dart bytes, durable GPU
  resources/latest-state mailbox, resize/orientation/loss/background/fences/cleanup;
  M9 edited Mandelbulb/depth; M10 all families; M11 Rust backend/scheduler/viewport
  ownership and qualified replacement of every legacy path remain required.
- M12 revision-pinned 4K/8K PNG, bounded memory/cancel/dimensions/crop/color/alpha;
  M13 saved/import/history/deep-link compatibility; M14A actual WASM/legacy renderer
  and M14B actual browser WebGPU/export/download remain separate. Web is not stranded.
- Final audit retains Fourier/image/Cantor analysis, RK4, exact Number Walls,
  Gaussian moat, quaternion prime norms and other actual mathematical owners, not
  an absent audio feature. Audit imports/dependencies and real routing. Flutter
  retains UI/l10n/accessibility/platform I/O; default-off flags persist.
- ADRs 0005/0006 retain predeclared device/GPU/refresh/backend/build/viewport/trace,
  5 s warmup and 30 s measurement, compositor-present revision markers/distributions.
  At 60 Hz: p95 interval <=1000/60 ms, max stall <=100 ms, p95 input-to-present <=50 ms.
  Optional 120 Hz needs compatible physical hardware and its own <=1000/120 ms run.
  Waydroid remains Android functional/container evidence, not hardware qualification.

No new owner-only decision blocks this batch. Target/tool/cache/port/contention
failures retain exact operation, task, source and evidence with the same coordinator.
They are not missing product intent, skipped success or grounds for duplicate tasks.

## Verification and handoff

All implementation, generation, build and device commands in the saved contracts
are **proposed/unrun in this planning pass**. Reuse root AGENTS.md's exact Full check,
pinned Flutter 3.47.9/Dart 3.13.7, Rust 1.95.0, existing isolated PUB/CARGO/FRB caches,
private TMPDIR and lockfile-enforced checkout-local package metadata. Compare Flutter
with fdroid/flutter.version; verify /usr/bin/python3 pytest/jinja2/markupsafe imports
on each host. Android uses the existing target-enabled cached RUSTC, not ambient rustc.
The older Waydroid guide's 3.44.6 sentence does not override root SDK pinning.
No installs, profile changes, lock updates or ambient fallback. Focused worker checks
and runner merged-tree/full-main gates remain distinct; do not loop full suites.

Premortem: trajectory lost on scalar update -> retained-snapshot/legacy-null tests;
false random/timing equivalence -> exact recorded draw stream and fake-time ticks;
false native success -> both named targets, original protocol guards, terminal
results, source/artifact binding and owned cleanup. No measured speedup is claimed.

Close only this planning task manually with this plan as evidence. Keep exactly one
open successor, RUST-PLAN-08, **7 of 10**, depending on all six new building tasks.
The same authorized coordinator continues the chain on its own, up to round 10;
move RUST-PLAN-08 to Needs decision to stop it. Saving this batch dispatches nothing.
The goal stays unmet; no BLOCKERS stop question is needed because new building work
exists before round 10.

Planning checks: the fresh read-only builder review found **nothing important left**.
Scoped readback passed 23 local links/Sources/anchors, seven-new-task cap, six-build
successor/round, exact root Full check in every building record, owner-first priority,
standing scoped consent, manual-only closure, preserved original contract/body and
unmet goal. Nine-file repeat readback was byte-stable. The supplied validator reports
155 tasks, 21 goals and no drafts; eight expected uncommitted task records are pending
until this one planning commit. Post-commit validation must clear them. Bundled
`docs.py stale .` and `docs.py check .` exit 0 with no docs/roles.json manifest;
this is not repository-wide content coverage. Provisioned /usr/bin/python3 imports
passed (3.12.3, pytest 9.0.2, Jinja2 3.1.6 and callable markupsafe.soft_str).
No implementation, generation, Flutter/Rust suite, build or device check ran here.
Post-commit `tasks why RUST-M2-TRAJECTORY-STATE` will check local selection ordering,
not dispatch, resource admission or delivery to canonical main. Canonical integration
and subsequent implementation/live qualification remain with the same coordinator.
