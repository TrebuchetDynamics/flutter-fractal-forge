# Rust deterministic Session producers and trajectory transport

## Brief and authority

Status: Accepted within the [owner-approved migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
This is focused Plan For Me for RUST-PLAN-08, **Plan round: 7 of 10**, under
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md). This is a multi-component
planning batch, not implementation or a backlog sweep. All choices marked
**Planner call** are delegated engineering choices, not owner selections.
The goal remains **unmet**. Preserve the whole-session switch, exact values,
saved formats, mathematical provenance, default-off flags and existing Flutter rendering.
A per-field switch, fixture-derived implementation, invented RNG equivalence or
build-only claim of native execution would fail this plan.

Inspection base: `517c315a0abaf5ac524a75bcadea408029fddfd2`. This checkout and canonical
main were clean and at that revision when inspected. The supplied executable reports
prepare API 4. Read-only preparation returned READY for both checkouts, with no
conversion actions or pending migration. Initial validation: 155 tasks, 21 goals,
no drafts or pending records. Preparation's historical legacy diagnostics are not
validation failures and are outside this trigger. Read-only runner status showed
zero running workers and zero awaiting integration. RUST-PLAN-08 was pending
planning, with no slot directory, candidate or saved ledger patch found. No patch
is replayed. Preserve owner-first ACAD-013-4142ef42, Now rank 1000, unchanged.
This batch is branch-local until the existing coordinator integrates it.

## Finished evidence and limits

Read all six task records, their accepted plan sections and actual
`attempt-1/report.json` files **in place** under the absolute Git common directory's
`autowork-execution/slot-data/`. Reports and private binaries are not copied into Git.
All six records are already coordinator-verified. Candidate commits are ancestors
of the inspection base. Results below are reported execution, not checks rerun here.

| Task / candidate | Reported result | Limit |
|---|---|---|
| RUST-M2-TRAJECTORY-STATE / `861b870ef74c317265cf86be563738e4a54256d7` | 17 focused Rust tests, 77 workspace tests/doctests and 15 unchanged Dart tests passed. Typed compatible trajectory settings survive detached snapshots and atomic ingress. | No public trajectory bridge, cache/job owner or app route. |
| RUST-M2-RANDOM-ORACLE / `7362ce0d9a96aaf2e8df6ee757365ad219047775` | Twice-executed immutable oracle: 18 general scenarios, 15 wall scenarios, 18 ordered lifecycle actions, 148 source bindings and identical explicit exports. All six opt-in primes reached. | Pinned Dart VM evidence, not a Rust RNG, Rust undo or browser equivalence. |
| RUST-M2-INTERPOLATION / `e959128013adf325950e5b267520ba44cc0f894a` | Seven focused Rust and seven Dart tests passed; all 37 steps per case and replacement outputs compared. | Pure kernel, not Session timeline, morph or physical events. |
| RUST-M2-ASYNC-STEP / `ab5e75b25604cc86c931faed3a02c72f61b59875` | 12 focused bridge tests, 80 workspace tests/doctests, identical twice-generated five-file inventories, analyzer/adapter checks and Linux/APK/Web builds passed. | Bounded normal FRB calls, not bounded admission, fairness or responsiveness. |
| RUST-M2-LINUX-EXTENDED / `176382d437ae2df3fae26a01a811d4c8499f4235` | Both unchanged targets executed via official integrationDriver at `df3c2fcffd5fd823d3184ba748496030c7ed3730`: four extended bodies and two Future bodies. Each run has exit 0, protocol_success=true, allTestsPassed=true, remaining_pids=[]. | Software-backend native transport evidence, not GPU timing/full M2/high-u64 success. |
| RUST-M2-WAYDROID-EXTENDED / `e0682b4097b7561d4805b5667e7778b789494303` | Same two targets/source: four plus two tests, terminal Flutter exit 0, actual serial/model/boot, source/APK/SO binding and owned cleanup. | Android container/native FFI, not physical hardware, scheduling or full M2. |

Linux evidence remains in `RUST-M2-LINUX-EXTENDED/attempt-1/native-evidence/`;
Waydroid evidence remains in `RUST-M2-WAYDROID-EXTENDED/attempt-1/evidence/` under
that slot-data root. Historical producer notes saying “compiled only” do not
invalidate these later executions. Linux reported generated defines of 12713/32768
bytes; Waydroid reported 12288/32768. Do not equate different command aggregates.
No report has an unresolved final setup/operation failure requiring replacement work.
Future failures return exact task/operation/source/evidence to the same coordinator
and candidate, not a duplicate task or new owner interview.

## Source observations and selected frontier

- Pinned SDK `lib/_internal/vm/lib/math_patch.dart:171–280` supplies seed mixing,
  four warm-up transitions, MWC constant `0xffffda61`, rejection sampling,
  two-draw 53-bit nextDouble and nextInt(2)==0 nextBool. The oracle binds this
  source. Rust must implement these wrapping 64-bit semantics, not use rand or
  fit expected outputs. `fractal_param_randomizer.dart` supplies schema order,
  inclusive integers, Julia radius 0.35, six-decimal step cleanup, enums and
  decimal defaults. Palette fields consume no draw.
- `fractal_controller.dart:603–681` stages seeded Number Walls state and installs
  exactly one undo frame only after success. Undo restores prior exact params/grid
  but retains the **current** view/transparency. Cancellation/rejection keeps the
  prior undo; ordinary navigation clears it. Current core request publication in
  `session_number_wall.rs:70–190` has no undo provenance.
- The interpolation kernel clones complete from at step 0, normalizes intermediate
  schema values and clones complete target at >=36. Controller timers schedule
  36 ticks at 16 ms. Param/preset/load/module/reset cancellation differs from
  scalar view changes; do not cancel on every command for convenience.
- Existing replay explicitly excludes gestures/timers. `physical_view.rs` accepts
  already selected anchors/rotation, not raw event ownership. Gesture recognition
  uses source timestamps, DateTime.now and animation elapsed time separately.
  A fake animation pump alone cannot freeze tap boundaries.
- Trajectory jobs already advance at most 256 RK4 steps. Dart owns a module-global
  three-entry touched LRU and per-widget cancellation/generation. Camera/palette
  changes reuse samples; settings replacement invalidates stale completion.
  Independent misses are not deduplicated. A per-Session replacement cache would
  not prove the existing shared cache policy.
- Current StateSession allocates low identities; StateSnapshot getters use u64/
  Dart BigInt. Existing high-value tests encode Rust bytes or reject large inputs.
  Neither returns a successful high-counter snapshot to installed Dart.

**Planner call:** save seven building tasks and one successor, **eight tasks total**.
Keep numerical RNG, staged undo, parameter timeline, raw-event observations and
trajectory jobs independently testable. Split trajectory core jobs from generated
transport so the latter consumes a real public core seam. A separate fixed codec
fixture remains independent of trajectory. Do not start the whole controller/app
rewrite, introduce another runtime, expose arbitrary counter setters or schedule
new installed tests before their fixture producers land.

## Seeded RNG and pure randomization

RUST-M2-SEEDED-RANDOM owns `seeded_random.rs`, a public pure schema-randomization
module, its test and component note. API shape: seeded signed-64-bit generator with
fallible next_int(max), next_double and next_bool; pure helpers take ordered schemas,
current values and an explicit generator/seed and return target params. Match the
pinned source's seed mixing and wrapping operations, warm-up and draw order.
nextInt accepts 1 through 2^32, rejects other bounds without a draw, and preserves
its rejection inequality. No secure/unseeded entropy service or cross-version claim.

Consume every general and Number Walls draw/target in randomization.json, including
synthetic schemas without admitting a synthetic production module. Verify exact
integer/bool/enum/text and draw-double values; float step-cleaned outputs must match
recorded values. Preserve all six seeds and additional opt-in seeds 3, 8, 19,
materialized wall seed masking and prime opt-in. Existing normalization remains
shared; no new dependency or original fixture refresh. Result is a pure target
producer, not Session ownership.

## Staged Session randomization and undo

RUST-M2-RANDOM-STATE consumes the pure target helpers. Add inert core seams for
immediate seeded ordinary randomization, begin seeded wall randomization and undo.
Keep animation separate: the ordinary target can later feed the parameter timeline.
Do not expose a Dart app route. Reuse existing begin/advance/cancel and exact frame
jobs. Store request-local provenance distinguishing randomization from ordinary
loads. Capture the prior committed frame at randomization admission; install it as
undo only with that request's successful frame publication. No early undo write.

Public tests replay all applicable actual-module oracle scenarios and the ordered
unsuccessful actions, including changed view/transparency, second undo, cancelled
replacement, rejection, revoked guard and navigation. Synthetic schema parity stays
in the pure producer, not Session's approved-module list. Undo is one atomic
identity/revision-checked publication; retain exact frame/params and current camera/
transparency. Ordinary load/reset/edit/select behavior follows controller source,
not a blanket “clear undo” rule. Preserve last-good state, pending cancellation,
revision reservation and all 68 original outputs. Hidden undo and pending provenance
must roll back with a failed batch. No timer, bridge or owner switch.

## Ordered parameter timeline

RUST-M2-PARAM-TIMELINE adds core start/replace/cancel/tick seams around the landed
interpolation kernel. Inputs are a complete typed target and one explicit logical
tick per scheduled callback, never a Dart-computed intermediate map or wall-clock
catch-up. Store from/target/step in the Session's transactional owner. Start captures
current params; replacement starts from the current partial map. Each accepted tick
publishes one revision and consumes at most one of 36 steps; stopped/stale tokens
cannot advance a replacement. Checked overflow or a rejected mixed batch leaves
both visible state and hidden timeline unchanged.

Replay actual-module oracle steps/replacement/cancellation at the public Session
seam; keep synthetic kernel cases unchanged. Match cancellation call sites:
known parameter edits, preset/load/module/resetParams/resetSession cancel; camera
moves/resetView alone do not cancel parameter interpolation. Explicit cancellation
is idempotent. Session drop/bridge close cannot leave an external timer because
this owner creates none. Names and helper extraction are reversible. Morph,
celebration/haptics, physical animations and app timer transport remain separate
future consumers; this is not full animation ownership or a measured 600-ms guarantee.

## Physical event oracle

RUST-M2-PHYSICAL-ORACLE produces a source-bound `physical-events.json` through
unchanged production recognizer behavior, not a second recognizer or transformed
camera commands. Reuse the lightweight renderer gesture harness and real viewer
keyboard handler. Add only an optional test clock callback on FractalRenderer,
defaulting to DateTime.now, and route gesture wall-time reads through it, including
the velocity fallback when sourceTimeStamp is absent. Drive it from explicit
scenario microseconds. Keep source-event timestamp precedence and animation elapsed
time separate. Prove omitted callback behavior remains unchanged.

Schema: runtime/source bindings, initial module/params/view/effects/viewport,
ordered seq-tagged raw pointer down/move/up/cancel (ID/kind/buttons/local position/
source timestamp), wheel delta/focal point, key down/repeat/up/focus, logical wall
clock changes, fake-time pumps, module/dispose actions, and expected checkpoints.
Record actual camera/adaptive params, ordered interaction callbacks, handled/ignored
keys and nested-control values. Observed scale callbacks, if logged, are outputs,
not substituted physical inputs. Bind renderer/input/viewer sources explicitly;
the old replay graph alone omits these owners.

Freeze representative drag/pinch/handoff/fling/orbit/rotation-lock/wheel/double-tap/
two-finger/cancel/new-gesture/module/dispose and focused nested-control paths.
Existing boundaries: twist >0.12 rad, two-finger <=220 ms and movement <=18 px,
raw double tap <=280 ms and <=28 px, duplicate suppression <120 ms. Test both
neighbors of those comparisons under the injected clock. Preserve 2D shortest-side
mapping versus 3D height/axis signs; keyboard rotZ pan .08, zoom factor 1.2 and R.
Preserve last-five-sample fling admission, >5 px/reference-frame pan and >.01 zoom,
.95/.92 retention, .1/.0001 cutoffs, 16000-us fractional reference frames, 2-second
flings, .5 soft bands and hard zoom/pan bounds including Cantor min .2.
Reuse cadence scenarios 8333/16667/33333/100000 us and tolerance 1e-8 where already
specified. Interaction end waits for both momentum owners and fires once; abandoned
animations must not finish a new interaction. Flutter retains gesture-arena/focus/
HUD control routing and Gaussian-walk key precedence. No Rust event owner yet.

Capture twice, compare immutable expected output normally and reject nested/source
mutation. Export only to an explicit empty private scratch directory; no silent
promotion or M0 refresh. The new oracle is a real producer for next-round ordered
Session physical transactions, not browser/hardware or renderer fidelity proof.

## Trajectory jobs and shared cache

RUST-M2-TRAJECTORY-JOBS extends the core's trajectory owner with captured settings,
request identity, begin/advance/cancel and detached terminal data. Reuse TrajectoryJob,
RequestGuard revocation and checked identity/revision publication. Begin never drains
RK4 work; one advance delegates at most one 256-step chunk. Reserve terminal revision
capacity before admission. A replaced settings generation cannot publish. Scalar
camera/palette changes with equal settings do not invalidate reusable samples.
Keep request kind separate from wall requests; reject foreign tokens and preserve
existing wall cancellation/rollback behavior. No mathematical work inside apply_batch.

Provide an explicitly shared cache service: three-entry touched LRU over validated
settings, reusable by multiple Sessions, not a private per-Session cache claimed as
Dart equivalence. Default standalone Sessions may own isolated services for tests;
the bridge consumer shares one process service. No in-flight deduplication or new
cache admission policy. Test A→B supersession, exact chunk-boundary cancellation,
settings/metadata invalidation, shared hit/touch/eviction, camera/palette reuse,
divergence, stable retained samples/bounds and revision overflow. Numeric settings
keys must include every version/system/seed/integrator/step/count/projection field;
assert equality against source-derived settings cases, not unproved Dart key bytes.

## Typed trajectory transport

RUST-M2-TRAJECTORY-BRIDGE consumes the landed core job/cache API. Preserve existing
StateCamera and its unsupported bare presence marker; add a separate typed validated
settings/camera seam, not fabricated defaults. Add detached settings/frame getters
and normal-mode begin/advance/cancel with existing session mutex/close/borrowed-handle
rules. One Rust-local shared cache service serves bridge Sessions. No new runtime,
per-sample FFI or synchronous job draining. Return bounded whole sample buffers and
bounds from immutable terminal frames, with identity/settings provenance.

Only this task adds the trajectory input projection mode to the existing launcher:
three complete original attractor records with the same exact-number/source-hash/
provenance and 32768-byte aggregate guards. Preserve default and --extended bytes
and every old assertion. Add a separate trajectory native target. Compile Linux and
Android x86_64, but do not install or claim assertions executed. Regenerate the five
existing outputs twice with locked FRB 2.11.1/cargo-expand 1.0.127 and compare complete
inventories. Test legacy marker rejection, typed compatibility/malformed input,
chunk/cancel/supersede/stale/close and detached samples; compare kernel bounds/points
with existing Dart trajectory expectations. Installed consumers follow in round 8.

## Fixed successful high-u64 producer

RUST-M2-U64-FIXTURE adds a **debug-only body** behind an always-generated bridge
method returning detached StateSnapshot fixtures. Use fixed identity/revision pairs
(9007199254740993, 18446744073709551614) and
(18446744073709551614, 18446744073709551615). No caller-supplied counter, allocator
mutation, mutable fixture Session, revision setter or app route. Core's private
snapshot helper clones a real validated snapshot and changes only those fixed
counters under cfg(debug_assertions). In non-debug builds the stable bridge method
returns an explicit unsupported error; its core helper is absent. Keep generated
API shape stable across profiles and prove release refusal by a focused release test.
This is test instrumentation, not a security boundary or production identity source.

Use actual StateSnapshot getters and the production generated u64 codec, not a
parallel test codec or decimal-string stand-in. Add a separate --extended native
target asserting Dart BigInt values and retained readback after closing the source
Session, with explicit handle disposal. Rust debug tests succeed; release tests
refuse. Generate twice and compile Linux/APK plus both root Web flags. No installed
execution here. Round 8 must schedule official Linux and standing Waydroid execution
of this new target before calling high-u64 output proved. Existing rejected operands
and Rust-only bytes remain useful but insufficient independent guards.

## Saved batch and admission

| Task | True prerequisites | Placement |
|---|---|---|
| RUST-M2-SEEDED-RANDOM | RUST-M2-RANDOM-ORACLE, RUST-M2-NORMALIZATION | Now, below owner-first |
| RUST-M2-RANDOM-STATE | RUST-M2-SEEDED-RANDOM, RUST-M2-INGRESS | Next |
| RUST-M2-PARAM-TIMELINE | RUST-M2-INTERPOLATION, RUST-M2-SESSION | Now |
| RUST-M2-PHYSICAL-ORACLE | RUST-M2-PHYSICAL | Now |
| RUST-M2-TRAJECTORY-JOBS | RUST-M2-TRAJECTORY-STATE | Now |
| RUST-M2-TRAJECTORY-BRIDGE | RUST-M2-TRAJECTORY-JOBS, RUST-M2-ASYNC-STEP | Next |
| RUST-M2-U64-FIXTURE | RUST-M2-BRIDGE, RUST-M2-ASYNC-STEP | Now |
| RUST-PLAN-09 | Every seven new building tasks | Next, Plan round: 8 of 10 |

Shared session.rs, api.rs, generated outputs and launcher writes are declared,
not hidden by narrowing Touches or false dependencies. Hot literal production files
wait for unlanded work; cold/directory/test overlaps rank admission only. Protected
paths/shared resources still apply. Two generated writers must regenerate against
their actual merged inputs and retain inventories. No concurrent execution or merge
conflict-free promise follows from task order. Every task owns its component result
note. None writes tasks/, shared history or grants live authority. Seven reviewed
implementation outcomes/merges are expected, separate from this planning commit.

## Remaining proof and continuation

Incorporate the entire [prior remaining proof](RUST-PLAN-07.md#remaining-proof-and-continuation),
[M0–M14/final map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary inventory](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained) and
[physical measurement protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol).
This batch removes none of their gates or thresholds.

- Next-round consumers must use actual RNG/undo/timeline/event/job/bridge results.
  Build ordered physical Session transactions from raw events and the new oracle,
  then morph/remaining mathematical animation ownership and full module semantics.
  Do not substitute Dart-computed camera/intermediate parameter state.
- **Bounded executor admission/scheduling remains unimplemented.** Normal FRB pool
  dispatch is not bounded request admission. Next design uses actual wall/trajectory
  job types: bounded permits acquired before queuing work, release on every error/
  revoke/close, fair stepping between Sessions and no hidden unbounded retry queue.
  A mutex or admission check only after entering an unbounded pool queue cannot prove
  that gate. Preserve ordered incremental commands; coalesce only render state.
  This is a future source-backed consumer, not a claim that a new scheduler exists.
  Do not add Tokio/a second runtime merely to move work off UI.
- Compile-only trajectory/u64 targets require new installed Linux official-driver
  and standing Waydroid runs. Retain source/input/artifact/backend identity, terminal
  outcomes and owned cleanup. Existing native extended passes do not qualify newly
  generated APIs. Waydroid consent/diagnosis remains unchanged; no phone request.
- Complete snapshot-only legacy rendering, editor/preset/history/deep-link app
  routing, stale snapshot/frame handling and rollback without state loss before
  the whole-session switch. No per-field ownership switch or flag enablement.
- M3 runtime catalog retains both identity namespaces, production/debug/performance/
  hidden filtering, order, exact values, provenance and presentation mapping.
  Baseline loading/fixture modules are not runtime M3.
- M4 exact float uniforms/separate samplers/versioned bindings; M5 boundary neighbors,
  capabilities/hysteresis; M6 honest CPU formulas/tiles/cancel/off-UI; M7 reference
  orbits/deep coordinates/double-float/perturbation remain required.
- M8 Linux external texture/Android surface, no per-frame Dart bytes, durable GPU
  resources/latest-state mailbox, resize/orientation/loss/background/fences/cleanup;
  M9 edited Mandelbulb/depth; M10 all families; M11 Rust backend/scheduler/viewport
  ownership and qualified replacement of every legacy path remain required.
- M12 pinned-revision 4K/8K PNG, bounded memory/cancel/dimensions/crop/color/alpha;
  M13 legacy saved/import/history/deep-link compatibility; M14A WASM/legacy renderer
  and M14B actual-browser WebGPU/export/download remain separate. Do not strand Web.
- Final audit includes Fourier/image/Cantor analysis, RK4, exact Number Walls,
  Gaussian moat, quaternion prime norms and all real mathematical owners. No absent
  audio feature. Audit imports/dependencies and runtime routes, not file suffixes.
- ADRs 0005/0006 retain declared hardware/GPU/refresh/backend/build/viewport/trace,
  5 s warmup, 30 s observation, compositor-present revision markers/distributions.
  At 60 Hz: p95 interval <=1000/60 ms, no stall >100 ms, p95 input-to-present <=50 ms.
  Optional 120 Hz needs compatible physical hardware and its own <=1000/120 ms run.
  Waydroid remains Android functional/container proof, never hardware timing.

No owner-only decision blocks this offline frontier. Physical performance remains
unmeasured, not waived. If future rounds stop without qualification, preserve an
open remaining-proof Needs decision task and one BLOCKERS continuation question.

## Verification and handoff

Planning runs only task validation, source/link/anchor/round/dependency readback,
Git ancestry and whitespace checks. No Flutter/Rust build, test, code generation,
installation or device operation is executed here. New checks in task records are
**proposed, unrun**. Preserve the pinned SDK/cache/import preflight and full offline
command from AGENTS.md; focused worker checks are not a full-main pass.

Pre-mortem: RNG drift is guarded by pinned SDK hashes plus exact draw transcripts;
late undo/trajectory publication by staged ownership/revocation/rollback tests;
false event timing/high-counter proof by explicit clocks and compiled-versus-installed
separation. Reuse existing oracles/kernels/request methods/launcher rather than
parallel validators or baseline refreshes. A fresh read-only builder check reviewed all eight records, the plan and source;
it found no material contract gaps or blockers. A final parent readback also made
the velocity wall-clock fallback explicit in the physical oracle contract.

Executed planning checks: all six candidate commits are ancestors of the inspection
base; 22 local plan/task source links and anchors resolve; the eight-task cap,
single round-8 successor, all seven building dependencies and owner-first order
pass. Working-tree validation reports 163 tasks, 21 goals and no drafts. Pending
markers identify this uncommitted batch; validate again after the one commit.
Manual closure preserves the original plan contract; goal files are unchanged.
Whitespace checks pass. Bundled Docs Sync stale/check commands exit 0 with no
roles manifest and provide no content coverage; the scoped readback above does.
These checks do not qualify implementation or live behavior.

Close RUST-PLAN-08 manually with this plan as evidence, not a verification receipt.
Save exactly one open successor RUST-PLAN-09, round **8 of 10**, depending on all
seven new building tasks. The already-authorized coordinator can continue the chain;
this session dispatches no building work. Stop it by moving RUST-PLAN-09 to
Needs decision. After the commit, run tasks why on RUST-M2-SEEDED-RANDOM in this
checkout. Selection readiness does not establish admission, capacity or canonical
delivery. The goal and its existing source/priority/focus stay unchanged.
