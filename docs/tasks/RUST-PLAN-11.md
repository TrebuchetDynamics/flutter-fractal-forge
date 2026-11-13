# Final bounded Session qualification frontier

## Authority and evidence

Status: Accepted within the [migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
Focused Plan For Me for RUST-PLAN-11, **round 10 of 10**, under
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md). This is planning only.
The goal remains **unmet**. No successor planning task is saved.

Inspection base: `eeca1ce10d8d8955e1bceb5e6116a307c7c327c7`.
All four reported final commits below are ancestors of this checkout. The actual
reports were read in place under the absolute Git common directory:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/`.
Reported checks were not rerun during planning.

| Producer | Final report / candidate | Result and limit |
| --- | --- | --- |
| RUST-M2-PHYSICAL-BRIDGE | attempt-1/report.json; `6012ee4755b78a3b574bb7136c439fef76ed6fa4` | Nine bridge/eight focused core tests, unchanged 67-scenario/382-checkpoint timed oracle, matching complete five-file generations. Linux/APK trajectory/u64 compilation and both Web builds, not installed physical-event assertions. |
| RUST-M2-TIMELINE-BRIDGE | attempt-1/report.json; `ff1e6cc93664e9d97efd6f2ea4ee3cc89f96a327` | Fourteen bridge/13 core/11 Dart tests, unchanged 68-output replay, 36 parameter/morph callbacks, matching five-file generations. Staged scheduled wall randomization and non-skipped Dart morph remain unqualified. |
| RUST-M2-SESSION-ADAPTER | attempt-2/report.json; `a07bdddc012362795a631f82f62482f7ec65af93` | Thirteen detached adapter/probe/replay tests; Rust gate and both Web builds rerun successfully. Eight adapter cases use injected detached data, not native execution. |
| RUST-M2-SESSION-FIXTURE | attempt-2/report.json; `b74979d4ff67fab354e90b971e5d03135cb87a4f` | Fourteen launcher/11 adapter tests, analysis, Linux/APK compilation and both Web builds. Ten complete module projections; 14224/32768 encoded bytes in compile launches. Native assertions explicitly unexecuted. |

Final reports list no unresolved blocker. The timeline report retains a resolved
120-second tool timeout, followed by a passing 600-second rerun and Rust gate.
This is not evidence for a replacement task or a product-code failure. Earlier
adapter/fixture attempts are retained; the final notes say they reused those
implementations and reran the required checks. Do not replace or repin evidence.

`tasks handoff .` reports no saved task proposal or patch. There is no
RUST-PLAN-11 slot directory. No patch is applied and no producer closure is edited.
RUST-CORE-01 is **open** in the current ledger. Its unchanged-viewer/M0/official
native proof remains its own contract, not proof supplied by these four closures.
Do not repeat the older plan's implication that this aggregate gate is qualified.

## Current source and planner decisions

The following are source findings, not runtime measurements:

- `rust/crates/fractal-core/src/session.rs::supported` admits exactly mandelbrot,
  julia, cantor_set, recursive_sine_sphere, kaleidoscope_basic,
  kaleidoscope_fractal, number_wall, thomas_attractor, four_wing and lorenz_2d.
  Neither the launcher nor an adapter test admits additional modules.
- `rust/crates/fractal-bridge/src/api.rs` now exposes physical generation and
  typed raw batches, ordinary seeded randomization, parameter/morph tokens and
  bounded wall undo under the original Session mutex. The service still exposes
  submit/replace wall commands and trajectories, not staged wall randomization.
- `RustStateSessionAdapter.create` defaults off and refuses Web before loading.
  `_admit` has one awaited operation, explicit Busy and no queue. Busy leaves all
  input with the caller. A non-Busy transport error can follow a native commit;
  read/reconcile before retry, never assume exactly-once transport from rejection.
- The native backend borrows one composition-owned service. Its scheduled wall/
  trajectory routes use tickets. Direct Session begin/advance/async APIs, core
  entry points and separately constructed services remain diagnostic bypasses.
  There is no process-wide execution-limit or migrated-app ownership proof.
- `SessionCheckpoint` freezes the supported read tree, exact typed values and
  BigInt identity/revision/generation. Hidden physical clocks, timeline targets,
  randomization undo and request ownership are not a restorable serialized engine.
  Disposal retains detached reads, not an operational rollback Session.
- `lib/features/renderer/widgets/renderer/fractal_renderer.dart` still reads
  FractalController through Provider, including params/view/effects/morph and
  trajectory. `FractalRenderSnapshot` is a post-routing diagnostic output, not
  an input interface that makes the legacy renderer snapshot-only.
- `integration_test/migration/rust_state_whole_session_smoke_test.dart` has one
  real adapter test, source-hash checks, mapped-SO hashing and `rendering=false`.
  It covers raw wheel/drag/pump, rejection/last-good, independent token replacement,
  load/effects/checkpoints, service wall/trajectory outcomes/cancel and exact u64
  getters after source close. It does not run the production viewer or every
  admitted module's semantics. Preserve its 30-second terminal deadline,
  5-second poll timeout and all assertions/teardown.

**Planner call:** save two independent native execution tasks and one owner-owned
Needs decision continuation task: **three new tasks total**. Both execution tasks
consume the compiled fixture, not each other's results. Place them after existing
Next work. Shared target/launcher paths rank scheduling, not dependency admission.
The Waydroid lane names the shared target resources and encodes existing owner
consent; Linux has no device resource. No exclusive pool-draining resource is used.

Select fresh execution of the existing inert target before proposing any production
switch. Reject enabling the adapter now: module branches, lossless capture,
non-skipped morph, rendering and rollback are incomplete. Reject copying the
controller or adding another native launcher/test: existing seams already reach
these assertions. A wider implementation batch is not needed to execute this
known fixture. The remaining source-dependent migration work below stays visible
in the continuation record, not disguised as complete runnable contracts.

## Official Linux Session execution

Task: **RUST-M2-LINUX-SESSION**, consuming RUST-M2-SESSION-FIXTURE.
Use `--session` with the existing official reserved-port Linux wrapper:

```sh
: "${AUTOWORK_PORT_BASE:?real current allocation required}" "${TMPDIR:?private scratch required}"
/usr/bin/python3 scripts/migration/run_state_session_smoke.py --session -- timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_state_whole_session_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true
```

Reuse the [current-source collection method](RUST-M2-LINUX-TRAJECTORY-U64.md#input-source-artifact-and-backend-binding),
including its private `native-evidence-current` observer/source-binding helpers.
Resolve that method under the absolute Git common directory, not this worktree's
`.git` file. Adapt target/mode in task-private scratch; preserve prior bundles.
Create durable private evidence under this task's own slot-data attempt directory.
No producer artifact or old 518-file count is the current execution inventory.

Require official `run.json` exit_code=0, protocol_success=true,
cleanup.remaining_pids=[], and `protocol-success.json` allTestsPassed=true.
Retain complete logs naming the test and teardown, not console snippets or a
supplemental launch. Observe the actual owned process/library and display backend.
`rendering=false` and a software display are honest nonrendering evidence, not
painted pixels, renderer/backend ownership or GPU timing.

## Standing Waydroid Session execution

Task: **RUST-M2-WAYDROID-SESSION**, independently consuming the same fixture.
Use only the [standing target](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target).
Existing owner 2026-10-26 consent covers this app-test/install cycle. It is not a
new target approval or publication grant. Declare `live`, `waydroid` and
`android-waydroid`: the last two names cover the same mutable instance used by the
prior Session tasks and open RUST-CORE-01. Revalidate actual users and current
serial/model/boot/get-state, with matching ANDROID_DEVICE/ANDROID_DISPOSABLE_DEVICE.

Reuse the [reserved-forward/private SDK-view method](RUST-M2-WAYDROID-TRAJECTORY-U64.md#target-tools-and-execution)
and its linked STATE procedure. Copy/adapt only collection helpers into private
scratch; never edit the installed SDK or another attempt's evidence. Use current
allocated DDS/host-forward ports, not the old 20500/20501 values. The base command
is the existing `--session` launcher plus `flutter test --no-pub --no-uninstall`
on the whole-session target, `-d "$ANDROID_DEVICE"`, `RUST_CORE=true`, expanded
reporting and the assigned DDS port. Bound the run to 1200 seconds plus 60 seconds
for supervised cleanup, as the prior method does.

Require one native test, no skips, terminal Flutter exit 0 and owned handle/app/
test/forward/listener cleanup. Preserve unrelated forwards and users. Retain built
and installed APK hashes, packaged and actually mapped SO hashes, source/generated/
inputs/tools/backend and complete terminal output. The target already prints its
mapped SO hash; denied host `run-as` is not permission for privileged recovery.

On transport failure retain status/helper/get-state/model/boot errors and the next
permitted diagnostic from the [reporting contract](../engineering/testing/waydroid-headless.md#release-preflight-and-exact-blocker-reporting).
Do not ask for a physical phone, change keys/credentials, reset/restart the container
or interrupt another worker. Technical failure goes to this same coordinator and
candidate. No replacement task, skipped success or new owner interview.

## Common verification and recovery

Use root AGENTS.md pinned setup: absolute Git-common-directory AUTOWORK_CACHE,
Flutter 3.47.9/Dart 3.13.7, Rust 1.95.0, FRB 2.13.0/cargo-expand 1.0.127 and
existing isolated caches. Compare Flutter with fdroid/flutter.version; verify
`/usr/bin/python3` pytest/jinja2/markupsafe.soft_str imports. Run offline
lock-enforced Pub resolution in the execution checkout. No ambient fallback,
installation, profile/SDK/manifest/lock changes or producer-checkout package binding.
The task records retain the exact root Full check; runner owns merged/full-main gates.

Both tasks run launcher pytest, focused target analysis and adapter/probe tests.
They may repair reproducible assertion-preserving target/launcher defects within
Touches. If those paths change, rerun those checks, Linux and Android-x64 compile
commands from RUST-M2-SESSION-FIXTURE and both Web flag builds. Then execute the
native target again against the repaired final bytes. No weakened assertion,
fixture refresh, codegen/production repair or timeout-as-success is allowed.
Other failures retain exact task/operation/source/evidence for supported recovery.

Collect full current execution source path sets and hashes before/after build/run,
including adapter/backend, core/bridge/generated source, target/launcher/driver,
inputs and locks. Verify against freshly resolved integration sources before report;
no hard-coded revision or file-count shortcut. Documentation-only drift is allowed
only with identical complete execution-source inventories. Any execution-source
drift requires fresh execution; a new label cannot qualify old binaries/results.
Keep full private logs/binaries outside commits; commit only the result note and
any justified bounded repairs. Actual encoded defines, including driver-added
flags, must remain <=32768 bytes and decode to the exact four projections.

## Remaining proof and continuation

The [complete M0-M14/final map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary inventory](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained),
[measurement protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol) and
[prior remaining proof](RUST-PLAN-10.md#remaining-proof-and-continuation) remain
required without weaker gates or thresholds. The bounded execution batch closes
only the new fixture's native transport assertion gap if it passes.

| Remaining outcome | Preserved work and completion boundary |
| --- | --- |
| Module semantics | Mandelbulb/quaternion/Gaussian and Burning Ship alias/default/special branches need source-bound parity and explicit admission. Pure 3D/Gaussian physical cases do not admit Session modules. Extend whole-session coverage only after those semantics exist; no catalog baseline refresh. |
| Randomization/timelines | Schedule existing core staged wall randomization through the shared service, preserving successful-only undo, custom modulus/six-prime policy and cancellation; never synchronous certification drain. Non-skipped Dart morph differential/native presentation and external 36x16-ms callback scheduling remain distinct from source-derived cubic ticks. |
| Physical/app consumers | Preserve gesture arena/focus/nested controls/HUD/key ownership; apply all incremental raw inputs in order before render coalescing. Supply lossless admission/reconciliation across Busy and ambiguous post-commit errors before connecting handlers. Route editor/preset/history/deep-link consumers to the same owner, preserving exact values and old saved formats. Diagnostic shaped inputs are not production routing. |
| Snapshot-only legacy rendering | Establish a read-only render-input seam from accepted immutable Session state; remove controller mathematical reads for migrated sessions without constructing a mirrored mutable FractalController. Preserve full view/trajectory/effects/transparency/morph and actual pixel/uniform/precision behavior. Existing post-routing FractalRenderSnapshot alone is insufficient. Flutter still owns nonmigrated sessions. |
| Whole-session switch/rollback | Quiesce physical clocks, tokens and pending wall/trajectory work or retain the original Session. Prove whole-state switch and rollback without loss, stale identity/revision/frame rejection and last-good retention; checkpoint/FractalPreset serialization alone cannot restore hidden owners. Default-off until the actual route qualifies; no per-field switches. |
| M3-M7 | Runtime dual namespaces, production/debug/performance/hidden filtering/order/provenance/exact values/presentation; exact float slots plus separate samplers/versioned bindings; precision boundary neighbors/hysteresis/capabilities; honest CPU formulas/tiles/bounded memory/off-UI/cancel; deep coordinates/reference orbits/double-float/perturbation. |
| M8-M11 | Actual Linux external texture/Android surface, long-lived GPU, latest-state mailbox, fences/resize/orientation/loss/background/cleanup, no per-frame Dart bytes; edited Mandelbulb/depth; every family; backend/viewport ownership and qualified legacy retirement. |
| M12-M14 | Pinned-revision 4K/8K PNG bounded-memory/cancel/dimensions/crop/color/alpha; saved/import/history/deep-link compatibility; actual WASM and browser WebGPU/export/download/capability/loss/fallback. JavaScript builds are not browser or WASM execution. |
| Auxiliary/final | Fourier/image analysis/discrete Cantor/norm estimation, RK4, exact Number Walls, Gaussian moat, quaternion prime norms and every real mathematical owner. Audit imports/dependencies/runtime routes; do not add absent audio. Preserve M0 references, open RUST-CORE-01 and original replay/exact-value/last-good gates. |

ADRs 0005/0006 still require declared hardware/GPU/display refresh/backend/build/
viewport/input trace, 5-second warmup and 30-second compositor-present observation.
At 60 Hz: p95 interval <=1000/60 ms, no stall >100 ms, p95 input-to-present <=50 ms.
Optional 120 Hz requires compatible physical hardware and a separate <=1000/120-ms
run. Waydroid is functional container proof, never physical hardware timing.
No hardware availability or qualification is asserted here.

The rolling chain stops at its authorized limit. **RUST-MIGRATION-CONTINUE** is an
open owner-owned Needs decision task for this remaining proof and the single
`Q-RUST-PLAN-11 — Planning stopped` question in BLOCKERS.md. It is not a producer
prerequisite for the two independently authorized fixture executions. The question
asks whether/how to continue after round 10, not to reapprove routine engineering,
the standing device or an existing technical failure. No successor plan, goal
qualification, waiver or coordinator receipt is created.

## Planning verification and handoff

Builder self-review (no subagent tool available): both target/mode inputs exist;
the old Linux and Waydroid methods are reachable in durable slot-data and linked
notes; exact ports are supplied by the runner, never historical constants. The
fixture already owns mapped-library diagnostics and teardown. Default-off, hidden
checkpoint limits and the open RUST-CORE-01 are explicit. Shared resources serialize
the designated device; shared files alone create no prerequisite. No material
engineering question remains for executing this existing target.

Premortem: source drift -> complete pre/post path-set/hash readback and fresh run;
false native success -> full official terminal/protocol/cleanup requirements;
false app/hardware qualification -> inert rendering=false and explicit remaining
proof. All execution commands in this plan are proposed and **unrun here**.

Capability handshake: c05bd93a release, prepare_api=4. Read-only prepare reports
READY, no in-flight task entries and an active coordinator lease. Its unrelated
legacy documentation/goal diagnostics are not permission for a backlog sweep.
Executed planning checks: task validation passes with **206 tasks, 22 goals, no
drafts or warnings**. Scoped readback passes all **21** local plan/Source links
and anchors, three-task cap, final-round/no-successor rule, unchanged original
contract except manual closure, owner-owned continuation, exact root Full check,
existing consent, bottom-of-Next priority and fixture-only dependencies.
`git diff --check` passes. Only planning/task/BLOCKERS paths change. The goal and
all receipts/production sources remain unchanged. No application tests, builds,
native/device execution or full offline gate ran in this planning pass.

Expected delivery is two separately reviewed execution outcomes, not two completed
native runs in this planning commit. First within this batch is
RUST-M2-LINUX-SESSION; Waydroid is independent under standing target admission.
After commit run `tasks why RUST-M2-LINUX-SESSION`; this measures committed selection,
not resource admission, dispatch or canonical inclusion. Return this checkout's
single local planning commit to the same coordinator for supported integration.
No branch switch, canonical write, push, worker dispatch or implementation here.
