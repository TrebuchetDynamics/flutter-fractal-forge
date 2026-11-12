# Typed input transport and an inert whole-session rehearsal

## Authority and evidence

Status: Accepted within the [migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
Focused Plan For Me for RUST-PLAN-10, **round 9 of 10**, under
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md). This is planning only.
The goal remains **unmet**. Engineering choices below are planner calls, not owner
acceptance, execution receipts or permission to enable a production route.

Inspection base: `80cbc0176b6bfa6979e55f22096f06c46fad2a03`.
Read all seven dependency records, their component notes and actual reports in
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/`.
All seven final candidate commits are ancestors of this base. Reported checks below
were not rerun during planning.

| Producer | Report / candidate | Observed result and boundary |
| --- | --- | --- |
| RUST-M2-PHYSICAL-STATE | attempt-2; `1040581abbfffcb9be302983b84669546ddfc2ec` | 191 instantaneous outputs across 33 scenarios; 20 focused Rust and 241 unchanged Dart tests. Hidden pointer/anchor rollback. Unsupported Mandelbulb/quaternion/Gaussian coverage is pure-only. |
| RUST-M2-PHYSICAL-TIME | attempt-2; `8bc3753a75f7a9d43117517f9f571863768d8714` | All 67 raw scenarios/382 checkpoints, 22 focused Rust and 47 Dart tests. Explicit source/wall/pump clocks and stale completion tests, not an app timer/transport. |
| RUST-M2-MORPH-TIMELINE | attempt-1; `3d517ad1591cd2d07de7faf4307fcfb6eb767742` | 13 focused Rust/seven Dart tests, 36 cubic ticks and deferred wall publication retaining concurrent morph state. Source-derived, not a non-skipped Dart morph differential run. |
| RUST-M2-WORK-QUEUE | attempt-1; `2f67255b70baed4d2118973a576bf52e61ee6191` | 18 focused Rust/15 Dart tests; eight active-plus-queued permits, Session/kind fair selections with real jobs. Pure policy, not measured throughput. |
| RUST-M2-WORK-BRIDGE | attempt-1; `97cd8697be97ab3154a7bad4f13558024ecb6e85` | 14 focused bridge tests, twice-generated five-file inventories, Linux/APK trajectory/u64 and both Web flag builds. One pump per service; legacy manual/async methods and other service instances bypass that domain. No installed scheduler proof. |
| RUST-M2-LINUX-TRAJECTORY-U64 | attempt-2; `536af53a7ac690747c4968159f8feb9d0a6259ea` | Fresh runs at `d113ac4e65fb8a7be8aa1f37c9bbb24e72c37d0f`, both official-driver exit 0/protocol success/allTestsPassed/empty cleanup. Complete 518-file source binding includes physical-time files; old 516-file inventories rejected. Mesa llvmpipe, not hardware timing. |
| RUST-M2-WAYDROID-TRAJECTORY-U64 | attempt-2; `1a4415f5adc08390a4067a67175c829a493443bc` | Both targets one native test/no skips/Flutter exit 0 at `cf52b4bd` plus fixture diagnostics. Actual APK/loaded-SO/inputs/cleanup binding. This older source-bound result remains historical container proof, not qualification of later physical-time/work-service code. |

Linux private evidence is `RUST-M2-LINUX-TRAJECTORY-U64/attempt-2/native-evidence-current`;
Waydroid evidence is `RUST-M2-WAYDROID-TRAJECTORY-U64/attempt-2/evidence`, under that
absolute slot-data root. Keep those bundles private and unchanged. Successful exact
BigInt pairs remain `(9007199254740993,18446744073709551614)` and
`(18446744073709551614,18446744073709551615)`. No revision label may replace a new
source-bound execution when execution sources differ.

No producer's final report lists an unresolved runtime blocker. The Linux retained
source-drift incident was repaired by fresh execution, not by changing acceptance.
Do not create replacement tasks for historical failures. `tasks handoff .` reports
no pending ledger proposal, and there is no RUST-PLAN-10 slot directory. No saved
patch is applied. Existing closures and RUST-CORE-01 qualification remain unchanged.

## Source findings and selected batch

`session.rs:322–335` admits exactly ten modules: mandelbrot, julia, cantor_set,
recursive_sine_sphere, kaleidoscope_basic, kaleidoscope_fractal, number_wall,
thomas_attractor, four_wing and lorenz_2d. `StateSession` still has no typed physical,
parameter-timeline, morph or seeded-random route. `StateSnapshot` exposes neither
morph metadata nor wall-undo availability. `RustEngineAdapter` is only a neutral
probe, never an app controller. `StateWorkService` already shares the original
Session mutex and admits before FRB pool submission. Reuse these owners.

Planner call: four building tasks plus one successor, **five new tasks total**.
The first two are independent API outcomes despite shared generated files. Their
overlap ranks scheduling, not a producer prerequisite. The adapter consumes both;
the fixture consumes the adapter. Each chain link has a real interface dependency.
All go after existing tasks in Next; no owner priority, focus or resource changes.

| Task | Outcome | Real prerequisite |
| --- | --- | --- |
| RUST-M2-PHYSICAL-BRIDGE | Typed raw events, clocks, generation and ordered logical outputs over the existing Session | PHYSICAL-TIME and TRAJECTORY-BRIDGE |
| RUST-M2-TIMELINE-BRIDGE | Typed parameter/morph tokens, seeded ordinary targets, animation option and snapshot metadata | PARAM-TIMELINE, MORPH-TIMELINE, RANDOM-STATE and TRAJECTORY-BRIDGE |
| RUST-M2-SESSION-ADAPTER | Inert awaitable whole-session presentation owner, one work service, detached read model and lossless checkpoint | Both new bridge tasks and WORK-BRIDGE |
| RUST-M2-SESSION-FIXTURE | Source-bound ten-module diagnostic fixture and Linux/APK compilation | New adapter |
| RUST-PLAN-11 | Final round **10 of 10**, reconcile actual four reports and plan remaining qualification/ownership | Every four building tasks |

Reject switching app handlers now: module admission and compatibility/presentation
proof are incomplete. Reject per-field switches or copying Flutter camera/timeline
math into Dart transport. The smallest complete next result is an inert, directly
testable session path, not another neutral probe or a production replacement.
No new module, dependency, runtime, thread pool, baseline refresh or flag is needed.

## Physical transport

Planner call: extend the existing `StateSession` with a normal FRB Future method
wrapping `Session::apply_physical` under its same mutex. Use opaque typed input
constructors and detached result getters, as existing StateCommand/StateValue do;
no JSON command protocol or Freezed dependency. Carry all existing PhysicalInput
variants: pointer ID/local pixels/phase/kind/buttons, wheel local/dy, key/phase,
focus, wall microseconds, pump generation/delta and Dispose. Every event retains
sequence, optional source microseconds and consumed routing. Viewport is optional
width/height, never camera geometry or ScaleDetails. Preserve unsigned u64 for
identity/sequence/generation/buttons and signed i64 for source/wall/delta times;
generated Dart uses BigInt without double conversion.

Return detached snapshot, current physical generation, ordered interaction signals
and key dispositions. Expose raw output updates only as diagnostic output, never
as a second camera owner. Initial generation must be obtainable through the same
Session without fabricating zero. Preserve empty versus nonempty revision rules,
stale-pump sequence semantics and one atomic publication including hidden clocks.
Retained result data stays readable after later mutation/shutdown. Foreign/stale/
invalid/overflow batches preserve hidden and visible state.

Flutter still owns gesture arena, focus, nested controls, HUD and keyboard routing
in gesture_handler.dart/viewer_interactions.dart. No capture handler changes in
this batch. Supported cases use Session; unsupported 3D/Gaussian oracle cases stay
pure-only. Reuse the frozen oracle and existing physical tests: transport tests
compare mapped supported raw sequences and exact ordering, not a weaker new oracle.
`1e-8` remains the camera tolerance. Timings/thresholds in
[PHYSICAL-TIME](RUST-M2-PHYSICAL-TIME.md#api-and-clocks) remain unchanged, including
the first pump anchoring a ticker rather than advancing it. No new haptic/platform
calls or full-executor responsiveness claim.

## Timeline transport

Planner call: opaque Session-bound parameter and morph tokens have no caller-built
numeric constructor. Expose start/tick/cancel for parameter timelines, morph
snapshot token/tick/cancel and `apply_batch_with_module_animation`. Token identity
and stale/idempotent behavior remain core-owned. Snapshot getters include morph
progress/isMorphing/previous ID/token and wall undo availability. Parameter start
returns its token plus detached snapshot atomically under one Session lock.

Expose ordinary immediate seeded randomization and a seeded animation-start helper
that calls the existing Rust target generator then `start_param_timeline`. Put the
small helper in the existing core randomization owner: no Dart intermediate target
math, entropy, timer or second random implementation. Preserve pinned signed i64
seed/VM algorithm and typed complete target validation. Wall undo can wrap the
existing bounded restore operation and return its changed flag plus snapshot.
**Staged wall randomization is not yet a scheduled-service operation**: do not
silently implement it as a synchronous certification drain or claim full wall
randomization ownership. It stays an explicit remaining gate.

Reuse all 36 parameter callbacks and all 36 morph callbacks, with independent
generations. Morph is `1-(1-step/36)^3`, terminal progress=1/false/previous=null.
Same-module/resetView/nonanimated selection/load/reset do not gain a blanket
cancel rule. Deferred wall publication preserves current morph metadata. The
source uses 36 callbacks at integer 16-ms intervals, not a measured 600-ms claim.
Automated controller tests skip morph: preserve that limit rather than adding a
production test override. Unchanged replay retains 68 outputs.

Both transport tasks regenerate the complete five-file FRB inventory twice with
current runtime/Dart/codegen **2.13.0**, cargo-expand **1.0.127**, and compare hashes.
Use current locks, not historical report-era versions. Never hand-edit generated
bodies. Check existing trajectory/u64 Linux/APK compilation and both root Web flags;
compilation is not native assertion execution, WASM or browser qualification.

## Inert whole-session adapter

Planner call: add a separate `RustStateSessionAdapter`, without altering the neutral
probe, startup, FractalController, renderer or production event routes. One instance
owns one StateSession and borrows one explicitly shared StateWorkService from its
composition owner. All expensive wall/trajectory operations in this adapter use
service tickets only, never old begin/advance/drain APIs. Existing diagnostic
bypasses remain available outside it and must be named in its note. Do not claim a
process-wide limit or that all app execution has migrated.

Use an injected backend interface plus a native implementation and conditional
Web refusal, following the existing loader pattern. Tests inject detached values
rather than mock opaque FRB objects. Creation is explicit/default-off and refuses
Web without initialization. Methods forward typed ordered commands/raw events/
tokens and expose detached immutable presentation values. Do no camera,
normalization, seeded target, interpolation, certification or RK4 math in Dart.
Timer scheduling remains external explicit tick inputs; do not start UI timers.

There is at most one awaited mutation in flight per adapter. A second mutation
returns explicit Busy **before** accepting/consuming its inputs, with no hidden
wait/retry queue. The caller retains an unaccepted incremental event and must
retry in order. This is a diagnostic awaitable API, not production gesture capture
or permission to drop/coalesce input. Later UI integration must supply and test its
own lossless admission strategy. Only render-state consumption may coalesce.

Validate session identity and monotonic BigInt revisions before presenting returned
snapshots/frames. Equal revision reads are allowed; wrong identity/older responses,
late ticket results after replacement/disposal and superseded frame generations
cannot overwrite the accepted view. Use existing terminal status semantics:
Finished alone is not a verified prime. Retain last-good view on error/Busy.
Cancel tickets and dispose owned handles exactly once; service lifetime belongs to
its composition owner, not a tab. Disposal during an awaited response closes the
owner and disposes late handles without publication.

Provide a detached compatibility checkpoint of the **entire supported read state**:
module ID, typed params/exact decimals, view including trajectory, transparency,
effects, morph metadata and available wall/trajectory frames/status. Do not call
FractalPreset JSON a full checkpoint: it omits effects/transparency/hidden owners.
The checkpoint is presentation/rollback input, not a second mutable engine, and
must explicitly identify hidden in-flight owners that cannot be serialized. A
future owner switch must quiesce those owners or retain the original Session;
this task performs no switch/restore or saved-format migration.

Rehearse editor parameter changes, preset/load/module selection, and decoded
history/deep-link-shaped inputs through the same typed command entry, without
editing their production consumers or importing a live store. Preserve exact
integer/string distinctions and unsupported-operation rejection. Mapped effect/
view/trajectory values can be consumed by later snapshot-only legacy rendering;
no uniform setter, render calculation or app binding is changed here.

## Compile-only native fixture

Planner call: add `--session` to the existing source-bound launcher as a mutually
exclusive fourth mode. Project complete records for exactly the ten currently
admitted modules, preserving original hash verification, numeric token spelling,
record order and the actual **32768-byte encoded aggregate** guard. Existing default,
`--extended` and `--trajectory` outputs/hashes/assertions stay unchanged. New fixture
pins the newly calculated projection hashes from actual output, not guessed values.

Add `integration_test/migration/rust_state_whole_session_smoke_test.dart`.
The existing `rust_state_session_smoke_test.dart` already owns the original
four-module fixture: preserve it, its hashes and assertions unchanged.
The new inert target exercises the real adapter/generated APIs: raw supported
wheel/drag/pump plus rejection, seeded parameter ticks and independent morph
replacement, ordinary load/effects/checkpoint retention, scheduled wall and
trajectory terminal results/cancellation, exact counters and post-close retained
read data. Capture all owned opaque handles with teardown. Bounded polling uses a
finite timeout with failure diagnostics, never a skipped success. Reuse existing
assertions/kernels/fixtures rather than replace old targets or add a second launcher.

Compile the target for Linux and Android-x64; analyze and run launcher tests and
both root Web flag builds. Do not install/run devices in this task. The result note
must say native assertions are **unexecuted** until separate current-source official
Linux/standing Waydroid runs. Subsequent execution uses current port/TMPDIR,
official integrationDriver terminal receipts and documented Waydroid consent/
transport/cleanup. No new target approval, reset, credentials or publication.

## Remaining proof and continuation

Carry the entire [prior remaining proof](RUST-PLAN-09.md#remaining-proof-and-continuation),
[M0–M14/final map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary inventory](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained) and
[predeclared measurement protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol).
No original gate or threshold is removed.

Next round reads actual four reports/merged source and separates source-derived,
pure/core, generated, compiled and installed evidence. It must plan actual new
native transport/scheduler assertions, remaining module semantics and whole-session
presentation, rather than promote this inert path directly to production.

Remaining M2 prerequisites include: unsupported Mandelbulb/quaternion/Gaussian and
Burning Ship alias/default/special-branch semantics; scheduled wall randomization/
successful-only undo integration; non-skipped morph differential/native presentation;
lossless physical input capture and external tick scheduling; editor/preset/history/
deep-link production routing; snapshot-only legacy rendering; stale snapshots/frames;
whole-session quiescence/rollback without lost state. No per-field switch or flag
enablement before those gates. Flutter remains the sole active app owner.

M3 retains runtime dual namespaces, production/debug/performance/hidden filtering,
order/exact values/provenance/presentation keys; M4 exact float slots and separate
samplers/versioned bindings; M5 boundary neighbors/hysteresis/capabilities; M6 honest
CPU formulas/tiles/bounded memory/off-UI/cancel; M7 deep coordinates/reference orbits/
double-float/perturbation. M8 retains Linux external texture/Android surface,
long-lived GPU/latest-state mailbox, fences/resize/orientation/loss/background/
cleanup and no per-frame Dart bytes. M9 edited Mandelbulb/depth, M10 all families
and M11 actual backend/viewport ownership and qualified retirement remain required.
M12 pinned-revision 4K/8K PNG bounded memory/cancel/dimensions/crop/color/alpha;
M13 saved/import/history/deep-link compatibility; M14A actual WASM and M14B actual
browser WebGPU/export/download remain separate. Final audit includes Fourier/image/
Cantor, RK4, exact Number Walls, Gaussian moat, quaternion prime norms and every
real mathematical owner, not absent audio. Audit imports/dependencies/runtime routes.

ADRs 0005/0006 retain hardware/GPU/refresh/backend/build/viewport/trace declaration,
5-second warmup, 30-second measurement and compositor-present revision distributions.
At 60 Hz: p95 interval <=1000/60 ms, no stall >100 ms, p95 input-to-present <=50 ms.
Optional 120 Hz needs compatible physical hardware and a separate <=1000/120-ms run.
Waydroid is functional container evidence, never physical hardware timing.

There is no new owner-only gap for this offline batch. RUST-PLAN-11 is exactly one
open successor, **Plan round: 10 of 10**, depending on every four building tasks.
The authorized coordinator continues that chain; move it to Needs decision to stop.
At round 10 save no further planning successor. Unless executed evidence meets the
goal under existing ledger rules, that stopping pass must preserve one BLOCKERS
question `Q-RUST-PLAN-11 — Planning stopped` naming remaining proof, and an open
Needs decision task for continuation/remaining proof, within its eight-task cap.
An empty queue/manual planning closure never qualifies the goal.

## Verification and handoff

Use root AGENTS.md pinned isolated SDK/cache/import preflight and exact Full check.
Preserve both locks; installs/profile changes/ambient fallback are not setup repair.
Workers may repair reproducible check-blocking defects inside declared Touches
without weakening assertions/provenance. Other technical failures retain exact
task/operation/source/evidence for the same coordinator/candidate, not a new task
or owner interview. All building/test/generation/native commands are proposed,
unrun here. The runner owns merged-tree/full-main gates.

Builder self-review (no subagent tool available) resolved: private core tokens need
opaque borrowed wrappers; seeded animated targets need a core helper, not Dart math;
wall randomization lacks a scheduled operation and stays unqualified; FractalPreset
is not a whole checkpoint; adapter Busy must not consume raw input; new launcher
mode must preserve all old outputs. The original session-smoke filename is already
occupied, so the new whole-session target has a distinct path and the original is
protected by the fixture's preservation check. These resolutions are in the
contracts above.
Premortem: late token/response publication -> stale/disposal/rollback tests; exact
value loss -> BigInt/tagged decimal and unchanged replay checks; false scheduler/
native qualification -> one shared service and explicit compile-only result notes.

Executed planning checks: working-tree task validation passes with **203 tasks,
22 goals, no drafts or warnings**. The six pending task paths are this uncommitted
batch, not runtime receipts. Scoped readback passes the five-task cap, four building
dependencies, one round-10 successor, ten new task Sources/anchors and all plan
links. It also verifies the original RUST-PLAN-10 contract unchanged except manual
closure, the exact root Full check in all four building records, unchanged goal/
receipt/lock files, owner-first priority and no overlap-only dependency. The first
readback caught the occupied original native-fixture path; the corrected distinct
whole-session path and preservation check pass. No application tests/builds or
native runs were executed. Runtime admission is unassessed: `status .` refuses a
detached checkout; this does not authorize branch switching or runtime edits.

Capability handshake reports matching c05bd93a release,
prepare_api=4 and required verbs. Read-only preparation is READY with an active
coordinator lease. Its unrelated legacy-source/goal diagnostics are not task
validation failures and are outside this single trigger. Read-only pruning plan
was inspected, not applied. Task/plan Sources, anchors, five-task cap, round and
producer dependencies must pass scoped readback and task validation before the
single planning commit. No goal or runtime receipt is edited. After committing,
run `tasks why RUST-M2-PHYSICAL-BRIDGE` in this checkout; this measures committed
selection only, not runtime resource admission or canonical delivery.

Expected delivery: four reviewed building outcomes/integrations, separate from
this one planning commit. This checkout returns the batch to the same coordinator
for supported integration; it does not switch branches, push, dispatch or write
canonical main directly.
