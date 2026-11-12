# Ordered physical state, bounded work and installed trajectory/u64 proof

## Authority and evidence

Status: Accepted within the [migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
Focused Plan For Me for RUST-PLAN-09, round **8 of 10**, under
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md). This is planning only.
The goal remains **unmet**. Planner calls below select reversible engineering
methods, not new product acceptance or execution authority.

Inspection base: `22060074a052641e4cfba0adc880c14e64ef22c3`.
Read the seven dependency records, their Sources/component notes and actual reports
in place under `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/`.
The following are reported checks, not tests rerun in this planning pass.

| Producer | Final report / candidate | Evidence and limits |
|---|---|---|
| RUST-M2-SEEDED-RANDOM | attempt-1; `7d59b364f668a2ab4c6c3e295ff2f117b947ec86` | Six randomization/five normalization tests; all 18 general/15 wall targets and draws. Pure pinned VM algorithm, not browser equivalence. |
| RUST-M2-RANDOM-STATE | attempt-1; `7bb93f3db1a585103f348dd8f2468101734ecab7` | 13 focused tests; 12 actual-module ordinary cases, 15 wall cases, 18 unsuccessful actions and unchanged 68 replay outputs. Immediate/staged undo, not animated app ownership. |
| RUST-M2-PARAM-TIMELINE | attempt-1; `69e6e2ffaebc6d3fcfdfb2087a96ad7c1b3f9ff6` | Eight focused tests plus overflow regression; explicit steps 0..36 and replacement. No external timer or measured 600-ms guarantee. |
| RUST-M2-PHYSICAL-ORACLE | attempt-2; `3045f6d451d00cdecffb057e36917045157fcf35` | 67 raw sequences/303 bindings; two identical exports, 268 unchanged gesture regressions, 13 reference tests and 11 renders with zero changed pixels. Flutter observations, not a Rust event owner. |
| RUST-M2-TRAJECTORY-JOBS | attempt-1; `b228e943b184d44dc04aedc9f87a76d11eb6be08` | 29 focused tests; shared touched three-entry LRU, <=256-step chunks, terminal reservations and wall isolation. No executor admission/fairness. |
| RUST-M2-TRAJECTORY-BRIDGE | attempt-2; `0862f15be9ba8e66eaa2235a27e0176452498989` | 11 bridge/12 protocol tests; identical generated inventories, compiled Linux/APK and both Web flags. Native trajectory assertions unexecuted. |
| RUST-M2-U64-FIXTURE | attempt-1; `6caac37153369a833f541521567406028154eba9` | Debug fixed snapshots and release refusal, generated codec and compiled Linux/APK/Web. Successful installed BigInt outputs unexecuted. |

Also read both earlier physical/trajectory attempt-1 reports. Physical recovery
preserved all original M0 bytes and exact source maps; its final retry changed only
the landed bottom-sheet source binding and note relative to the retained candidate.
Initial capture timeouts are retained, not counted as passes. Trajectory retry
made the Dart Lorenz enum mapping explicit. No final report lists an unresolved
blocker. Do not create replacement tasks for either historical technical failure.

The current locks, generated header and specification pin FRB **2.13.0**, not the
reports' historical 2.11.1. New generation uses current `scripts/ci/rust-bridge-codegen.sh`
and the provisioned 2.13.0 tool. Never downgrade locks to reproduce an old report.
Current native runs must bind their actual integrated source and binaries.
The task handoff reports no pending files/diff; no RUST-PLAN-09 slot directory or
saved candidate proposal was found. No ledger patch is replayed. Existing producer
closures/receipts and the separate RUST-CORE-01 qualification task remain untouched.

## Selected batch and boundaries

Planner call: seven building tasks and one successor, **eight new tasks total**.
Split physical instantaneous state from timed completion, and pure admission policy
from bridge execution. Each split has a testable result and a real consumer seam.
Morph is a bounded source-derived core timeline, not a fabricated Dart oracle.
Installed execution is independent of these new owners: its two targets already exist.

| Task | Produces / real prerequisite | Placement |
|---|---|---|
| RUST-M2-PHYSICAL-STATE | Raw input reducer and ordered Session physical transactions; consumes PHYSICAL-ORACLE, PHYSICAL, PARAM-TIMELINE | Now, appended below existing owner priorities |
| RUST-M2-PHYSICAL-TIME | Momentum/tap elapsed-time state and exactly-once completion; consumes PHYSICAL-STATE | Next |
| RUST-M2-MORPH-TIMELINE | Explicit source-derived module morph ticks; consumes PARAM-TIMELINE, RANDOM-STATE | Now |
| RUST-M2-WORK-QUEUE | Bounded permit/round-robin policy tested with real wall/trajectory jobs; consumes TRAJECTORY-JOBS, INGRESS | Now |
| RUST-M2-WORK-BRIDGE | Pre-pool admission and bounded pump on existing FRB pool; consumes WORK-QUEUE, TRAJECTORY-BRIDGE | Next |
| RUST-M2-LINUX-TRAJECTORY-U64 | Both existing new targets through official Linux driver; consumes TRAJECTORY-BRIDGE, U64-FIXTURE | Next |
| RUST-M2-WAYDROID-TRAJECTORY-U64 | Both targets on designated Waydroid under standing consent; same producers | Next |
| RUST-PLAN-10 | Round **9 of 10**, depends on every seven new building tasks | Next |

Ordinary shared files rank admission; they are not dependencies or exclusive resources.
No promise of conflict-free parallel merges follows. Only the Android task reserves
`live`/`waydroid`. Existing protected-path/generated-output coordination still applies.
No task narrows Touches to evade it. No task writes task records or shared history.

## Raw physical transactions

`gesture_handler.dart` owns pointer tracking, ScaleGestureRecognizer callbacks,
anchors, velocity and animation. `viewer_interactions.dart` owns keyboard updates;
Flutter owns gesture arena, focus, nested controls and HUD/menu activation. Preserve
all of those routes. The new Rust owner is inert and does not replace event handlers.

Planner call: typed raw pointer down/move/up/cancel, wheel, key/focus, viewport,
wall-clock and elapsed-pump inputs, with sequence and owner/generation identity.
Do not accept Dart-computed pan, rotation, zoom or ScaleDetails as the proof input.
Derive pointer geometry/recognition from the pinned Flutter/source behavior and
physical-events.json; observed callbacks are expected outputs only. Routing metadata
may state that a nested control consumed an event, but cannot supply camera math.
Do not implement a second Flutter gesture arena or alter focus/key dispatch.

PHYSICAL-STATE handles instantaneous updates and hidden anchor/pointer state.
Use the existing physical_view kernels, normalizer and atomic Session publication.
An invalid/stale/overflow/rejected mixed transaction leaves hidden and visible state
unchanged. Known parameter edits still cancel the parameter timeline; camera moves
alone do not. One ordered input transaction publishes at most one revision, including
all camera/adaptive changes. No render coalescing may discard incremental input.

Test all wheel checkpoints and drag/bounds/pinched/handoff/resumed/twisted checkpoints
before timed advancement. Preserve shortest-side 2D mapping (screen rotZ ignored),
3D height/axis signs and +/-67.5-degree tilt bound, >0.12 twist, pointer handoff,
rotation lock, absent-layout fallback, keyboard .08 rotated pan/1.2 zoom/R and
Gaussian-walk/nested-control precedence. Keep existing zoom/pan/Cantor limits.
The approved Session module list does not include mandelbulb or quaternion_julia_3d:
test their geometry at the public pure reducer seam, and compose supported modules
with Session. Do not widen module admission or call pure 3D tests full Session proof.

PHYSICAL-TIME consumes that same state and replays every timed checkpoint across
all 67 scenarios. Source timestamps take precedence for velocity, wall time owns tap
classification, elapsed animation time owns pumps. Preserve last-five samples,
>5 px/reference-frame pan and >.01 zoom admission, .95/.92 retention, .1/.0001
cutoffs, 16000-us fractional reference frames, 2-second limits, .5 boundary damping,
<=220-ms/18-px two-finger, <=280-ms/28-px raw double and <120-ms duplicate rules.
Tap animations use 200-ms easeOutCubic and inverse-zoom pan interpolation, not the
600-ms parameter timeline. Reuse source easing, not a fitted expected-value table.
Retain 8333/16667/33333/100000-us cadence cases and existing 1e-8 tolerance.
Interaction end waits for both momentum owners, fires once, and cannot be delivered
by an abandoned animation after replacement/module/disposal. Snapshot retention,
transaction rollback and stale tick rejection cover hidden timing state too.
UI haptic/menu effects remain Flutter signals, not Rust platform calls.

## Morph timeline

Planner call: add an inert complete module-selection/morph start, one logical-tick,
replace/cancel seam. Source: fractal_controller.dart:315–432. Capture previous ID
only when the source starts a morph. The production path uses 36 periodic 16-ms
callbacks, progress `1 - (1 - step/36)^3`, then progress=1, false and previous=null.
Same-module/resetView, animate=false, source special branches, replacement and
module load behavior must follow source; do not assume every selection starts or
cancels a morph. Do not admit previously unsupported modules to test a branch.
Use existing supported Mandelbrot/Julia cases and record unsupported branches as
remaining proof. Parameter interpolation and morph are distinct concurrent owners.

Add public source-derived core tests for every tick, replacement and rollback,
including independent parameter ticks/randomization. Do not claim an unchanged Dart
fake-time morph oracle exists: RuntimeModeService causes the current controller's
morph to skip in automated tests. No production test override or fixture refresh is
needed for this slice. Differential non-skipped morph/native/app/haptic presentation
remains pending; source-derived numerical tests do not close that gate.

## Bounded admission and fair execution

Current `StateSession` normal methods acquire their mutex **after** generated
`wrap_normal` dispatch. This does not bound the FRB queue. The cached pinned 2.13.0
`handler/implementation/executor.rs` calls `thread_pool.execute`; its
`handler/implementation/handler.rs` exposes `DefaultHandler::thread_pool()`.
`for_generated/boilerplate.rs` declares the generated handler. This supports reuse
of the actual existing pool without editing generated bodies or adding Tokio.

Planner call: first create a pure bounded work policy keyed by Session identity,
request kind and generation. Default capacity **8 total admitted jobs**, including
the currently stepped job, is a new internal bound, not a measured throughput claim.
At most one wall and one trajectory job per Session. Reject full admission explicitly
as Busy without allocating a hidden waiter/retry list. Replacement revokes/releases
the prior matching job before admitting its successor atomically. Keep wall and
trajectory identity distinct. Round-robin one existing bounded chunk per runnable
Session, rotating kinds within that Session. With S runnable Sessions, each gets a
turn within S selections; no wall-clock fairness claim. Reserve/release permits on
terminal/error/revoke/close/panic/drop and reject stale/double release.
Tests compose the policy with actual Session wall/trajectory jobs and retained frames.

Bridge consumer: a new inert sync submit/cancel/status API admits to that bounded
policy **before** calling the existing generated handler's pool `.execute`.
Submission only captures validated operands/identity; no certification/RK4 drain.
Use shared Arc ownership of the existing Session mutex (no second Session state).
A single scheduled/running pump flag allows at most one pool closure for this
service. The pump steps one chosen bounded chunk, rotates, and exits on empty.
Make empty-to-nonempty/exit races atomic under the queue lock; no lost wake or
one-closure-per-rejected-request behavior. Never hold queue lock while doing math
or waiting on the Session mutex. Retain bounded terminal status in the ticket;
dropping tickets/Session or close revokes work and releases capacity. Do not retain
unbounded completed-result maps. Inject the pool submission seam in Rust tests to
count queued closures deterministically. Catch panic at the job boundary, release
its permit and preserve service liveness without inventing a successful result.

The old diagnostic async methods remain compatibility routes, not bounded-admission
proof. New scheduled jobs own their tokens; concurrent old/manual operations cause
explicit stale/revoked results, never late publication. Full app/executor ownership
requires routing the future whole-session adapter through this new path and auditing
all bypasses. That qualification remains open; this task must label its narrower
service claim. Sync status reads return detached cached progress, not mathematical
work. No per-sample FFI, new runtime/thread pool, app route or flag enablement.
Generate all five files twice with current pins, compare complete inventories and
compile Linux/APK plus both Web flags. No installed scheduler proof is claimed.

## Installed trajectory and high-u64 execution

Run existing `rust_state_trajectory_smoke_test.dart` with `--trajectory`, and
`rust_state_u64_smoke_test.dart` with `--extended`. Preserve original complete-record
projections, exact numbers/source hashes and the 32768-byte aggregate guard.
Do not replace assertions, infer installed success from old extended/Future runs,
or reuse producer binaries as current-source evidence. The fixed successful pairs
remain (9007199254740993,18446744073709551614) and
(18446744073709551614,18446744073709551615), through actual generated BigInt getters.

Linux uses `scripts/run-native-integration.sh`, real current AUTOWORK_PORT_BASE and
private TMPDIR, official integrationDriver, terminal exit_code=0,
protocol_success=true, allTestsPassed=true and cleanup.remaining_pids=[].
The [previous Linux procedure](RUST-M2-LINUX-EXTENDED.md) is reusable collection
method, not acceptance for these targets. Record actual software/hardware backend.

Android uses only the [standing Waydroid target](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target).
Encode the owner's existing 2026-10-26 app-test/install consent in typed fields.
Rediscover current serial, require get-state=device, native model
`WayDroid x86_64 Device`, boot=1 and matching ANDROID_DEVICE/ANDROID_DISPOSABLE_DEVICE.
Use existing reserved-host forwarding, terminal Flutter results and owned cleanup
from [the prior execution](RUST-M2-WAYDROID-EXTENDED.md). Coordinate active users;
no device substitution/reset, unrelated deletion, authentication change or publication.
Transport failure retains exact helper/get-state/model/boot error and next documented
diagnostic, not an owner target-choice question. Both targets must actually execute.

For each platform/target retain actual source/input/launcher/generated/toolchain,
built artifact and loaded-library identity, full terminal logs/results, backend and
owned cleanup in durable private slot-data evidence; link it from the component
note. Capture first-run artifacts before the second build overwrites them.
Private evidence stays out of Git. Only bounded target/launcher check-blocking
repairs are allowed; do not weaken assertions or broaden core/generated ownership.
Failure returns exact operation/task/source/evidence to the same coordinator/candidate.
Neither run qualifies physical GPU timing, browsers, scheduling or full M2.

## Remaining proof and continuation

Carry the entire [prior remaining proof](RUST-PLAN-08.md#remaining-proof-and-continuation),
[M0–M14/final map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary inventory](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained) and
[predeclared measurement protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol)
unchanged. No old gate or threshold is removed.

Next round must read actual seven reports and merged source, reconcile partial
physical/morph module coverage, scheduled-service versus all executor paths and
installed trajectory/u64 outcomes. Then plan typed event/timer transport, remaining
module semantics and whole-session presentation, not a per-field switch.
Snapshot-only legacy rendering, editor/preset/history/deep-link routing, stale
snapshot/frame rejection and rollback without lost state remain prerequisites to
switching. Flags remain default-off and the current Flutter app remains sole owner.
M3 runtime namespaces/filter/order/exact/provenance/presentation; M4 uniform floats
and separate samplers; M5 boundary/hysteresis/capabilities; M6 honest CPU formulas,
tiles/memory/off-UI/cancel; M7 deep coordinates/orbits/perturbation remain required.
M8 external Linux texture/Android surface, long-lived GPU/latest-state mailbox,
fences/resize/orientation/loss/background/cleanup and no per-frame Dart bytes;
M9 edited Mandelbulb/depth; M10 every family; M11 actual backend/viewport ownership
and qualified retirement remain required. M12 revision-pinned 4K/8K PNG bounded
memory/cancel/crop/color/alpha; M13 saved/import/history/deep-link compatibility;
M14A actual WASM and M14B actual-browser WebGPU/export/download remain separate.
Final audit includes Fourier/image/Cantor, RK4, Number Walls, Gaussian moat,
quaternion prime norms and every real mathematical owner, not absent audio.
Audit imports/dependencies and routes, not suffixes.
ADRs 0005/0006 retain declared hardware/GPU/refresh/backend/build/viewport/trace,
5-s warmup, 30-s measurement and compositor-present revision distributions.
60-Hz p95 interval <=1000/60 ms, no stall >100 ms, p95 input-to-present <=50 ms;
optional 120 Hz needs compatible physical hardware and its own <=1000/120-ms run.
Waydroid is functional container evidence, never physical hardware timing.

No new owner-only gap blocks this batch. The goal stays unmet with an open round-9
successor depending on every building task. The authorized coordinator continues
through at most round 10; move RUST-PLAN-10 to Needs decision to stop it. If a later
round stops without qualification, preserve its BLOCKERS continuation question and
an open Needs decision task for remaining proof. Never mark the goal met from an
empty queue or manually closed planning task.

## Checks and handoff

Use root AGENTS.md's pinned isolated SDK/cache/import preflight and exact Full check.
Keep both lockfiles. All building/test/generation/native commands are **proposed,
unrun here**. Focused worker checks are not a full-main gate; the runner owns its
merged-tree/full-main checks. No build, implementation, install or device action
occurs during this planning pass.

Builder readback (self-review; no subagent tool available) identified and resolved:
unsupported 3D modules stay at the pure reducer seam; automated-test morph skipping
is not an oracle; pool admission must precede submission, and historical FRB pins
must not override current locks. Inputs and bounded prerequisite repairs are named
in each task. Premortem: late event ticks -> transactional generations; queue floods
and lost wakes -> capacity/pool-submit counters and interleavings; false native
qualification -> per-target terminal/source/library/cleanup readback.
Seven reviewed building outcomes/merges are expected, separate from this one planning
commit. Canonical integration remains with the same coordinator, not this checkout.

Executed planning checks: the supplied CLI reports prepare_api=4 and all required
verbs. Read-only preparation reports READY with a live coordinator lease; unrelated
legacy/source/goal diagnostics are not validation failures and are outside this
single trigger. Working-tree validation passes with 197 tasks, 22 goals, no drafts
or warnings. Its nine pending task paths are this uncommitted batch, not runtime
receipts. All seven final candidate commits are ancestors of the inspection base.
Readback passes the eight-task cap, seven building dependencies, one round-9
successor, all 16 new task Sources/anchors, unchanged original planning contract,
manual-only closure, unchanged unmet goal and exact root Full check in every
building record. Scoped whitespace checks pass. Post-commit validation must clear
pending paths, and `tasks why RUST-M2-PHYSICAL-STATE` must assess local committed
selection separately from resource admission, dispatch and canonical delivery.
