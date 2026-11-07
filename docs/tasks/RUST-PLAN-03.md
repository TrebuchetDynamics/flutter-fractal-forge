# Rust session preparation from native lifecycle evidence

## Authority and limits

This completes `RUST-PLAN-03`, Plan round: 2 of 10, under
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md) and the
[accepted migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
The goal stays **unmet**. This is planning, not implementation, dispatch, new live
consent, a verification receipt or goal qualification.

User outcomes remain unchanged: Flutter keeps presentation and platform I/O.
Rust eventually owns all mathematical state, algorithms, rendering and export.
Preserve saved data, IDs, mathematical claims, input behavior and the working
Flutter path. No dual mutable owner, silent formula fallback, lossy exact integer,
fictional CPU support or interactive frame copies through Dart are acceptable.
All engineering choices below are planner calls, not new owner decisions.

## Evidence and current disposition

Inspection base: `7e9b37c1281cb93713989b320834f818c713f1c3`. The checkout was clean.
The task CLI reports prepare API 4 and `prepare --check` outcome `READY`, with no
in-flight records or pending conversion. Its unrelated legacy-source/goal
coverage diagnostics are not validation errors or inputs to a backlog sweep.
The baseline ledger validates: 128 tasks, 21 goals, no drafts or pending records.
The three consumed slots are closed. There is no RUST-PLAN-03 slot report or saved
Rust task patch in slot-data. No historical candidate ledger edit is replayed.

Read the finished reports **in place**, under the absolute Git common directory's
`autowork-execution/slot-data/`. Do not copy private bundles into this checkout.

| Record and report | Executed result | What it does not prove |
|---|---|---|
| RUST-M1-LINUX, attempt-1/report.json, `59044afd` | At source `9c84e6da`, the real reserved-port driver passed version 0.1.0, rendering=false, independent handles, duplicate close and closed reads. Final run.json has exit_code=0, protocol_success=true and no remaining PIDs. [Result](RUST-M1-LINUX.md). | Mesa llvmpipe software context, not Rust rendering, hardware timing or Web. An optional initial backend observer timed out; the corrected observation and terminal run passed. |
| RUST-M1-WAYDROID, attempt-1/report.json, `bf59bbfa` | At the same source, the real fixture passed with Flutter exit 0 on rediscovered designated Waydroid. Installed APK/SO identities and owned cleanup are retained. [Result](RUST-M1-WAYDROID.md). | Container functional evidence only. Initial unsupported CLI option and downgrade rejection remain history. Flutter's automatic ADB forward was outside the leased range and was removed; do not claim a fully port-constrained run or physical GPU proof. |
| RUST-M3-CATALOG-PARITY, attempt-1/report.json, `c11f388d` | Typed CatalogBaseline::from_jsons, complete envelope parity, exact number/text preservation, atomic errors, seven workspace tests, 34 Flutter checks and a real forbidden dependency injection. [Result](RUST-M3-CATALOG-PARITY.md). | Read-only debug/diagnostic baseline preparation, not runtime registry, release filtering, prime certification or M3 completion. |

Both native tasks and catalog preparation have coordinator_verified closures and
existing receipts. Preserve them. Together with the finished workspace/bridge
reports, the **contracted nonrendering M1 native lifecycle gate is proven**.
This statement reconciles existing evidence; it grants no broader qualification.
The older notes that say M1 still needs the other target describe their original
capture time. Do not reopen either task or rewrite that history.

The earlier M0/workspace/bridge reports remain the starting oracle, including
RUST-M0-CONTRACTS attempt 1, RUST-M0-REPLAY attempt 1, RUST-M0-IMAGES attempt 1,
RUST-M1-WORKSPACE attempt 2 and RUST-M1-BRIDGE attempt 2. Their limits and source
identities are recorded in [round 1 evidence](RUST-PLAN-02.md#evidence-read-and-milestone-disposition).
M0 and the Burning Ship repair closures remain intact. No failed earlier attempt
is promoted over a passing final report. No coordinator recovery is indicated by
the final reports in this batch.

### Source observations that determine the cut

- `rust/crates/fractal-bridge/src/api.rs` still owns only an AtomicBool closed flag.
  `lib/core/services/engine/rust_engine_adapter.dart` is only a native probe.
  Neither is a controller state owner.
- `fractal-core/src/catalog_baseline.rs` already has typed ModuleId, CatalogId,
  ParameterKind, ParameterValue and preset/view data. Reuse them and the locked
  Serde graph. Do not copy the inventories or write a new parser.
- `lib/core/controllers/params/fractal_param_value_normalizer.dart:80-127`
  defines generic normalization. **All nonfinite numeric parameters use schema
  defaults**, not infinity clamps. The replay labels for events 8/9/12/13 are
  misleading: actual expected iterations are 350 and bailout 4.0. Values and
  current executable semantics, not prose labels, are the oracle. Dart numeric
  enum equality accepts equal int/double numbers, but not the string "1".
- `input/fractal_view_input_bounds.dart:14-18` defines maxZoom=1e12,
  defaultMinZoom=1e-9, cantorSetMinZoom=0.2 and pan [-3,3]. View NaN retains
  bounded last-good components; view infinities clamp, unlike parameters.
  Nonfinite rotation retains finite prior angles.
- `fractal_controller.dart:1017-1142` merges schema defaults, preset values and
  overrides, ignores unknown parameter keys, and tracks adaptive zoom history.
  The existing adaptive policy uses epsilon 1.01, minimum step 8, dimension and
  module exclusions. ResetView means the true initial view, not a module preset.
- `migration/baseline/state-replay.json` has an ordinary prefix, events 0-46,
  using mandelbrot, julia, cantor_set and recursive_sine_sphere. Events 47-67
  exercise Number Walls and ownership races. The harness in
  `test/migration/support/replay_codec.dart` serializes real history/preset values.
  The full 68-event corpus remains required; prefix parity is only a bounded port.
- `fractal_controller.dart:1169-1313` and the
  [Number Walls boundary](../engineering/spec.md#number-walls-replay-validation-boundary)
  require asynchronous exact certification, prior committed grids, generation and
  shouldCommit guards. Generic decimal syntax is not prime verification.
- Other session state includes effects, kaleidoscope policy/restore, rotation
  lock, animation/randomization and compatible trajectory settings. Physical
  gestures still perform transforms in Flutter. Prefix parity does not cover
  those paths and cannot authorize a per-field or whole-session live switch.

## Next executable batch

Four new tasks total, all under RUST-ENGINE-001:

| Task | Reviewable outcome | True prerequisites | Placement |
|---|---|---|---|
| RUST-M2-NORMALIZATION | Pure Rust parameter/view normalization with original baseline inputs and focused edge cases. | RUST-M3-CATALOG-PARITY supplies typed descriptors; RUST-M0-REPLAY supplies the oracle. | Now, below the owner's first task. |
| RUST-M2-SESSION | Inert transactional candidate session and ordinary-prefix replay parity. | RUST-M2-NORMALIZATION supplies normalization APIs. | Next. |
| RUST-M2-BRIDGE | Typed opaque state-session transport and generated Dart seam, not app routing. | RUST-M2-SESSION supplies transactions/snapshots; RUST-M1-BRIDGE supplies pinned glue/tooling. | Next. |
| RUST-PLAN-04 | Reconcile these results and plan full-session parity, native transport proof and the eventual adapter frontier. Plan round: 3 of 10. | Every new building task above. | Next. |

This is M2 preparation, **not M2 completion**. A three-outcome serial batch is
justified by actual data/API consumption, not shared files. The source gives no
safe independent production switch yet. Reject a big-bang controller port and a
camera-only live switch: both risk dual ownership or omitted Number Walls/effect
state. Reject another inventory/preflight task: the inputs and native M1 proof
already exist. Reject blocking pure preparation on physical GPU timing: ADR 0006
keeps that later gate separate.

### Decided interfaces and error semantics

- Normalization lives in `fractal-core::normalization`. Expose typed raw scalar
  input that can represent f64 nonfinite values, booleans and exact text, plus
  finite view values. Normalize against existing Parameter descriptors without
  adding FRB or platform dependencies. Decimal syntax preserves canonical text
  but never certifies a modulus. View normalization in this batch covers scalar
  pan/zoom/rotation only; non-null trajectories are unsupported by the candidate
  session, not silently dropped. A later port must preserve their semantics.
- The candidate `fractal-core::session` owns module, parameters, view,
  transparency and adaptive-iteration history together. Construct it from the
  validated original four envelopes, a selected supported module and an explicit
  session ID. Support only the four ordinary-prefix module IDs for now. Unsupported
  modules/trajectory inputs fail explicitly without partial state. This is a new
  inert preparation API, not a changed legacy import fallback.
- Expose snapshot and apply_batch(session_id, expected_revision, commands).
  Snapshots carry session identity and u64 revision. Start at revision zero.
  Apply ordered commands to a private candidate, then publish once. A successful
  nonempty batch increments once, including a valid no-op; empty batches are
  unchanged. Reset is an ordered command and increments normally. Stale identity,
  stale revision, unsupported operations and revision overflow reject atomically.
  Invalid parameter values follow legacy normalization, not a new reject policy.
  Preserve every incremental input; do not coalesce pan/zoom commands.
- Commands cover the public ordinary-prefix operations: view/zoom/pan/rotation,
  parameter edit, module selection, transparency, preset/load, params/view/session
  reset. History save/restore and serializer framing stay in the test harness:
  use snapshot/load and original epoch/ID/null/result fields, not storage in core.
  Tests read original baseline files, compare every prefix result and prove an
  altered expectation fails. Assert the cut explicitly; never silently skip later
  events or claim the complete replay passed.
- Add a separate opaque StateSession in the bridge. Preserve Engine's existing
  probe API. Give each new bridge session a fresh process-local u64 identity with
  checked exhaustion, and serialize mutation/shutdown under one lock. Accept the
  four envelope strings once at explicit construction, not per frame. Use typed
  command/value/view/snapshot DTOs and coarse batches, not JSON command RPC or
  mathematical callbacks into Dart. Rust validates commands; Dart does not become
  a second mutable mathematical owner. Keep u64 identity/revision exact in generated
  transport, including values above 2^53. Retained snapshots are immutable copies.
- Bridge tests compare direct-core and bridge results and cover separate sessions,
  stale/wrong identity, duplicate close, post-close rejection and ordered batches.
  Regenerate with FRB 2.11.1 twice and compare outputs. Compile native smoke and
  both Web flag builds. Generated-code/build checks do not prove actual native
  state transport; leave installed state-session tests to the next round.
  Do not change app startup, RustEngineAdapter, controller or renderer routing.

Reversible details: internal helper names, error enum spelling and file-local test
organization. They must preserve the selected observable semantics above. No new
library, manifest/lock update, mathematical improvement or M0 refresh is needed.
Each building task owns its result note. Bridge may update only current-status
sentences in spec.md, not its normative ownership or Number Walls contracts.

## Remaining proof and continuation

The [complete remaining proof map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary mathematical domains](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained)
and [predeclared native measurement protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol)
are incorporated without removal or changed thresholds. In particular:

- M0 is retained unchanged. M1's nonrendering native lifecycle is now proven only
  for the captured source/targets. New state transport still needs installed proof.
- M2 still needs the full replay, exact asynchronous Number Walls certification
  and cancellation, complete session fields, effects/kaleidoscope/trajectory and
  randomization parity, physical input transforms, stale-result rejection and
  snapshot-only legacy rendering before a qualified whole-session owner switch.
- M3 still needs runtime registry/preset/capability authority, release/debug/
  performance/hidden distinctions, separate IDs, order, exact values, provenance
  and presentation mapping. Catalog loading is not mathematical certification.
- M4 uniform math/float slots/separate samplers and versioned bindings; M5 precision
  neighbors, capability and hysteresis; M6 supported CPU formulas/tiles/cancel;
  M7 reference orbits/deep coordinates/perturbation all remain unqualified.
- M8 Linux external texture and Android surface composition, no per-frame Dart
  bytes, long-lived GPU resources, resize/loss/background/cleanup and separate
  hardware qualification remain required. M9 edited Mandelbulb/depth/lifecycle,
  M10 every family and M11 Rust scheduling/backend/viewport ownership remain open.
- M12 pinned-revision 4K/8K PNG, bounded memory/cancel/dimensions/crop/color/alpha;
  M13 legacy saved/history/import/deep-link migration; M14A WASM/legacy rendering
  and M14B browser WebGPU/export/download remain separate required gates.
- Final retirement still includes Fourier and image analysis, Cantor Fourier lab,
  RK4 trajectories, Number Walls, Gaussian moat, quaternion prime norms and other
  existing mathematical owners found by the final audit. No absent audio feature.
  Audit imports, dependencies and real routing, not Dart file extensions alone.
- Default-off flags, valid routes, rollback without lost state, honest CPU support,
  ordered commands, bounded resources and export revision pinning remain binding.
  Flutter retains UI/l10n/accessibility/platform transport. Web cannot be stranded.
  ADRs 0005/0006 and the prior 60/120 Hz protocol remain unchanged: defined hardware,
  source/scenario/input trace, 5 s warmup and 30 s measurement, compositor-present
  revision markers, distributions and stalls. Waydroid is not hardware timing.

No new owner-only gap blocks this offline batch. Hardware/browser access is not
assessed here and remains scoped to its later qualification tasks. A real execution
or transport failure returns to the same coordinator with exact task, operation,
source and attempt evidence, without duplicate candidates or another product interview.

Use root AGENTS.md's current self-contained Full check and pinned Flutter
3.47.9/Dart 3.13.7, provisioned system Python imports, existing Rust 1.95.0 and
isolated Cargo/FRB caches. Worker checks are focused; runner merged-tree/full-main
checks remain separate. Missing tools, timeouts and failures are never skips.
All new implementation commands and tests are proposed and unrun in this pass.

Premortem: nonfinite policy confusion is caught by original expected values and
edge tests; lost incremental commands by ordered-batch equivalence and stale/atomic
negative cases; premature ownership claims by unsupported-session rejection and
unchanged app routing. Each task retains baseline bytes and the working Dart owner.
Expected delivery is three reviewed implementation candidates/integrations, separate
from this planning commit; no runtime or delivery-speed improvement is claimed.
Shared cold source paths are not new prerequisites. Normal protected-path and
resource admission still apply; no exclusive/live resource is added.

A fresh read-only builder review read the saved contracts and source seams and
reported **nothing important left**. This is a planning review, not implementation
or native verification. Parent readback confirmed original scalar default values,
all four new contracts, true producer edges and owner-first ordering. The task
validator passes with 132 tasks and 21 goals, no drafts, and only the expected
uncommitted task records pending before commit. Docs Sync `stale` and `check` both
exit 0 but report no docs/roles.json manifest; they provide no link coverage.
Local plan links and Sources anchors receive a separate scoped check.

Close RUST-PLAN-03 manually with this plan as evidence, without a receipt. Save one
open successor RUST-PLAN-04, Plan round: 3 of 10, depending on all three new building
tasks. The same coordinator can continue the chain up to round 10. Move the successor
to Needs decision to stop it. At round 10, or without new building work, retain the
required stop question and open remaining-proof task unless executed ledger evidence
actually proves the goal met. An empty queue never establishes completion.
