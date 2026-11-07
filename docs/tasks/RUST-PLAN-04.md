# Rust session effects, exact validation and installed transport frontier

## Authority and evidence

This completes RUST-PLAN-04, **Plan round: 3 of 10**, under
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md) and the
[accepted migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
The goal remains **unmet**. This pass plans only: no implementation, dispatch,
installation, receipt, waiver, qualification or publication.
The owner's scope and the prior M0/M1 closures are unchanged. All new engineering
details below are **planner calls**, not new owner decisions.

Inspection base: `93346c526fee563efc747faabfc74bfb15cc98b7`. The initial checkout was clean. The actual consumer
reports prepare API 4, `prepare --check` outcome READY, no pending conversion and
no in-flight task records. It also reports a live parallel coordinator lease;
this pass neither changes runtime state nor edits its other task contracts.
The baseline validator passes: 132 tasks, 21 goals, no drafts or pending records.
Unrelated prepare diagnostics are not validation errors or a backlog-sweep request.
No RUST-PLAN-04 slot/report or saved task patch was found. No historical ledger
proposal is replayed. The three consumed implementation records are already
coordinator_verified; preserve their receipts and all newer closures.

Read the following reports **in place** under the absolute Git common directory's
`autowork-execution/slot-data/`; do not copy private bundles into this checkout.

| Finished task / attempt-1/report.json | Executed evidence | Limits |
|---|---|---|
| RUST-M2-NORMALIZATION, candidate `41263c17f898493a5060f47d46b1a3081fa57131` | Five public normalization tests, original scalar replay inputs, 12 workspace tests and six Dart tests passed. Nonfinite parameter defaults, view clamps, strict booleans/enums and exact text are represented. | Scalar preparation only; decimal syntax is not prime certification. |
| RUST-M2-SESSION, candidate `d0b54722887b549a19e8a3813feded97d4070daf` | Original events **0–46**, twice, strict output equality and expectation-drift rejection; ordered/atomic/stale/overflow/isolation tests; 16 workspace and 12 Dart tests passed. | Events **47–67 explicitly unported**; only mandelbrot, julia, cantor_set and recursive_sine_sphere. No effects, non-null trajectories, Number Walls or app routing. |
| RUST-M2-BRIDGE, candidate `bdf544a9bd62155b86746202666b03d4ba38b913` | Four public bridge tests, 22 workspace tests, identical complete five-file FRB generation inventories, analyzer/adapter tests, Linux/APK probe compilation and both Web flag builds passed. | Native builds run only the old probe fixture. Rust codec tests and generated BigInt/u64 readback are **not executed Dart/native StateSession transport**. |

The reports have no final blocker or environment failure. Focused worker passes
are not the merged-tree/full-main gate; no implementation checks were rerun here.
Their [normalization](RUST-M2-NORMALIZATION.md), [session](RUST-M2-SESSION.md) and
[bridge](RUST-M2-BRIDGE.md) notes describe APIs accurately. Older “next consumer”
wording records capture time, not a reason to reopen finished work.
The prior [M0/M1 disposition](RUST-PLAN-03.md#evidence-and-current-disposition)
remains intact: nonrendering M1 lifecycle passed on its recorded Linux/Waydroid
source, without hardware or rendering qualification.

## Source observations and chosen cut

- `rust/crates/fractal-core/src/session.rs` owns a private candidate snapshot,
  publishes nonempty batches once and rejects unsupported modules/trajectories.
  Reuse that transaction boundary; do not switch any live field to Rust.
- `fractal_controller.dart:215–308,579–599,845–922`,
  `input/fractal_effect_input_bounds.dart` and
  `state/fractal_kaleidoscope_state.dart` define the next bounded state slice.
  Effects are not in M0's replay. Port their actual source/test vectors separately;
  do not claim the original 68-event replay measures them.
- Effects defaults are glow disabled/sigma 1/intensity .35, fluid disabled/strength
  1, rotation unlocked, and kaleidoscope disabled/8 sectors/mirror true/rotation
  0/mode 0. Sigma clamps .1–5, intensity 0–1, fluid 0–2. NaN preserves bounded
  prior state; infinities clamp. Kaleidoscope rotation is finite but unbounded.
  Sectors clamp 4–16 then round down to even; mirror mode clamps 0–3.
  Only the `kaleidoscope_` prefix forces enable/sectors 16/mode 3. Preserve the
  original user state through consecutive forced modules and restore it on exit.
  ResetSession clears rotation lock, but **does not reset all effects**. Direct
  updateRotation is not blocked by the gesture rotation lock.
- `number_wall_model.dart:98–188` supplies an exact, bounded trial-division
  validator: raw ASCII digits, maximum 256 digits before canonicalization, small
  primes 2 through 47, then odd candidates from 53, default budget 100000 and
  yields every 1024 odd divisions. Composite/invalid/unverified/cancelled never
  become verifiedPrime. It accepts leading zeros, unlike generic decimal syntax.
  `NumberWallFrame.prepare`, committed grids and ingress generations remain
  separate consumers. Do not enable number_wall in Session from a validator alone.
- A dependency-free validator is feasible without inventing a new primality test:
  exact decimal remainder by a small divisor plus exact decimal comparison with
  its square implements the same trial-division stopping rule. No float or entire
  value narrowing is needed. This avoids introducing an uncached bigint crate
  merely for validation. Arbitrary-precision grids/sequences are still unported.
- The generated Dart StateSession API is synchronous and exposes opaque owned
  commands/values and detached snapshots. The native fixture must create fresh
  moved arguments and dispose retained handles. Do not demand a Dart concurrent
  async race from this synchronous API; Rust contention tests already cover it.
- Native input delivery needs a concrete producer: the original four envelopes
  total over 14 MB and are **not app assets**. A fresh builder review proved
  that compressing/chunking all their bytes still fails: pinned Flutter recombines
  defines into one DART_DEFINES environment entry / Gradle argument, about 733619
  bytes after its second base64 encoding, exceeding Linux's per-string exec limit.
  **Disposition: planner-resolved.** Do not stage repeated builds or add production
  assets. For this four-module transport test, project all complete payload records
  for exactly mandelbrot, julia, cantor_set and recursive_sine_sphere from each
  original envelope (`id` for modules, `module_id` otherwise). Preserve record order,
  every field and scalar kind/text. Replace the enormous source provenance map with
  explicitly derived fixture provenance: original flutter_version/hash_algorithm/
  registry_mode, sources mapping the original envelope path to its SHA-256, a new
  source_set_sha256 over that sorted compact JSON mapping, and fixture_projection
  metadata listing selected IDs and original_source_set_sha256. Retain original
  hashes as evidence, never claim original provenance bytes or whole-catalog parity.
  A fixture-only Python launcher zlib/base64 encodes these four derived envelopes,
  appends one ordinary define each and invokes argv without shell eval. Native Dart
  uses dart:io zlib and four explicit const environment keys. Python tests prove
  lossless selected-record projection, deterministic derived provenance and decoded
  bytes. The measured Flutter-encoded aggregate is 9639 bytes before ordinary flag
  overhead. Enforce a planner-selected **32768-byte aggregate** budget including
  supplied defines, leaving headroom for Flutter's few internal flags; refuse rather
  than truncate if it grows. Test the actual reaggregated encoding, not per-chunk
  length. This preserves the wrapper, app assets, dependencies and original M0 files.
  Missing/truncated/tampered input fails, never skips. Full-catalog parity remains
  the existing Rust catalog test's evidence, not this installed transport claim.
- Large exact number/text values are reachable through StateValue constructors
  and getters. Large stale identity/revision inputs are reachable, but successful
  snapshots with identity/revision above 2^53 are **not**: identities allocate from
  a low counter, revisions start at zero. Their rejection does not prove an exact
  high-u64 output round trip. Keep that installed proof pending; do not add a public
  arbitrary-identity/revision setter or claim it passed.

Planner choice: advance effects transactions and exact certification preparation
independently of a fixture/native transport lane. Reject a full controller rewrite,
a per-field live switch and a Number Walls module enabled without certified grids.
Reject another inventory-only batch. Do not block offline ports on device access.
Internal helper names/test organization remain reversible; observable semantics,
source-bound inputs and unsupported-path honesty do not.

## Next executable batch

Six new tasks total, all under RUST-ENGINE-001; no owner-first Now task is moved.

| Task | Outcome | Genuine prerequisites | Placement |
|---|---|---|---|
| RUST-001-0fdde2b6 | Resumable exact decimal trial-division validator, with source-matched status/count/cancellation tests; no grid/session routing. | RUST-M0-REPLAY supplies original Number Walls inputs. | Now, below the owner's first task. |
| RUST-002-07ee2543 | Inert session effect/rotation-lock/kaleidoscope state and transactional parity vectors. | RUST-M2-SESSION supplies the transaction/snapshot API. | Now. |
| RUST-003-2b8363f4 | Real-native StateSession test and source-bound four-module input launcher; offline compile/input validation only. | RUST-M2-BRIDGE supplies generated typed API. | Now. |
| RUST-004-2dccfb82 | Execute that fixture via the official reserved-port Linux driver; retain terminal source-bound evidence. | RUST-003-2b8363f4 supplies target/launcher. | Next. |
| RUST-005-c9f7f34a | Execute the same fixture on designated Waydroid under existing test consent and resource admission. | RUST-003-2b8363f4 supplies target/launcher. | Next. |
| RUST-006-ee74a370 | Reconcile all five outcomes and expand exact grid/ingress, remaining session/input and adapter proof. **Plan round: 4 of 10**. | Every new building task above. | Next. |

Effects and prime preparation do not produce native fixture inputs; do not serialize
those lanes. Linux and Waydroid consume the fixture, not each other's outcome.
Shared resources, actual active-device coordination and protected-path admission
still apply. Shared paths alone add no product dependencies. The bridge fixture
uses the existing four-module API even if effects lands meanwhile; bridge transport
of the new effects remains a future producer/consumer slice, not a hidden requirement.

### Decided implementation seams

**Prime:** new pure `fractal_core::number_wall_prime` module. A job constructed from
raw text and a u32 trial budget exposes an advance operation, terminal typed status,
canonical verified-prime text and exact division count. Each advance performs at
most 1024 odd divisions, with Rust-local cancellation checks; no callback into Dart,
async executor, dependency or prime cache. Keep small-prime and final cancellation
checks and the source's budget/root/count precedence. u64 candidates and u128
squares suffice for the u32 budget; checked arithmetic rejects internal exhaustion
rather than wrapping. Tests read relevant original replay inputs and source-matched
validator cases, including zero budget, cancellation, leading zeros, Carmichael
composites, 2^53+1, the 127-bit unverified value and 256/257-digit boundaries.
No new claim that this certifies all primes or completes full replay.

**Effects:** extend core Session commands/snapshots with glow, fluid, rotation lock,
kaleidoscope and the hidden restore state. Permit two additional explicitly tested
baseline IDs, kaleidoscope_basic and kaleidoscope_fractal, to exercise real forced
module transitions; do not enable every module by prefix or drop trajectories.
Use original descriptors and existing normalization/transactions. New focused
session_effects tests carry source references to current Dart tests/assertions and
cover all setters, forced→forced→ordinary switches, reset/load/preset persistence,
nonfinite edges, stale/error rollback and immutable earlier snapshots. Existing
session_replay remains strict on 0–46; no baseline refresh. The API stays inert,
with no effects renderer, timer, randomization or bridge regeneration in this task.

**Fixture:** add integration_test/migration/rust_state_session_smoke_test.dart,
scripts/migration/run_state_session_smoke.py and its focused Python input tests.
The launcher accepts `-- COMMAND ARGS...`, reads original envelopes, projects the
four complete supported-module records with explicit derived provenance as above,
and appends four small fixture defines to argv, retaining original/projected hashes
without shell interpolation. Test Flutter's aggregate encoding against 32768 bytes;
no staged delivery or private persistent catalog is needed.
Initialize through the existing RustEngineAdapter; preserve rendering=false and
probe lifecycle assertions. Exercise independent sessions, ordered batches versus
fresh singleton commands, nonfinite defaults, empty/no-op revisions, wrong/stale
identity/revision rejection, atomic failed batches, retained snapshots, duplicate
shutdown, post-close errors and exact number/text/boolean getters. Compare expected
ordinary results to original M0 data and existing bridge test cases, not a second
Dart mutable mathematical owner. Test large stale operands and report their limits.
Do not claim runtime race or high-u64 output proof. Offline compile uses this new
target, not the probe-only target. Installed tests are separate task results.

**Native execution:** reuse existing private evidence/driver mechanisms, not a new
receipt or registry. Linux requires real worker AUTOWORK_PORT_BASE/private TMPDIR,
run.json exit_code=0, protocol_success=true, no remaining owned PIDs and official
allTestsPassed=true. Waydroid rediscovers only the designated instance and verifies
get-state/model/boot with matching ANDROID_DEVICE/ANDROID_DISPOSABLE_DEVICE. Encode
only the owner's standing 2026-10-26 app-test consent; no new live authority is
created. Resource contention with ACAD-013-4142ef42 is admission, not a prerequisite.
Retain target/library/build/input/toolchain/backend identities and terminal errors.
Neither software Linux nor Waydroid is physical GPU/performance evidence. Recover
actual runtime failures through the same coordinator and existing candidate, without
another interview, replacement candidate or invented prerequisite.

## Remaining proof and continuation

The complete [remaining proof map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary mathematical inventory](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained)
and [predeclared native hardware/scenario protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol)
are incorporated without dropping any gate or threshold. In particular:

- M0 is unchanged; M1 remains proven only for its recorded nonrendering targets.
  New StateSession native tests do not retroactively broaden those results.
- M2 still requires all original **68** replay events, exact asynchronous Number
  Walls certification **and grids**, pending/error/last-good state, newer request,
  navigation, edits and shouldCommit cancellation, editor/preset/history/deep-link
  ingress, retained grid behavior and randomization/undo. The validator alone is
  insufficient. Carry new effects state into typed transport later. Trajectory
  settings/compatibility, RK4, randomization, interpolation/animation/timer ownership,
  and every physical input transform (wheel/pinch anchor, drag/fling, keyboard,
  double tap and rotation lock) remain. Large-u64 installed output, stale snapshot
  rejection and snapshot-only legacy rendering precede a whole-session owner switch.
- M3 still needs runtime registry/catalog/preset/capability ownership, separate IDs,
  release/debug/performance/hidden filtering, order, exact values, provenance and
  presentation mapping. Reading baseline JSON is not runtime authority/certification.
- M4 exact uniforms/separate samplers/versioned bindings; M5 precision boundary
  neighbors/capability/hysteresis; M6 honest supported CPU formulas/tiles/cancel;
  M7 reference orbits/deep coordinates/perturbation remain unqualified.
- M8 Linux external texture and Android surface, no per-frame Dart bytes, durable
  GPU resources/latest-state mailbox, resize/loss/background/fences/cleanup and
  independent physical hardware qualification remain. M9 edited Mandelbulb/depth,
  M10 all families and M11 backend/scheduler/viewport ownership remain.
- M12 pinned-revision 4K/8K PNG, bounded memory/cancel/dimensions/crop/color/alpha;
  M13 saved/history/import/deep-link compatibility; M14A WASM/legacy rendering and
  M14B real-browser WebGPU/export/download remain separate gates.
- Final audit retains Fourier/image analysis, Cantor Fourier lab, RK4, exact Number
  Walls, Gaussian moat, quaternion prime norms and every real mathematical owner.
  No absent audio feature. Audit imports/dependencies and routing, not file suffixes.
  Default-off flags, rollback without lost state, ordered incremental input before
  render coalescing and revision-pinned exports remain binding. Flutter keeps
  presentation/l10n/accessibility/platform transport; Web cannot be stranded.
- ADRs 0005/0006 and target-specific 60/120 Hz qualification are unchanged: defined
  physical hardware/scenario/trace, 5 s warmup, 30 s measurement, compositor-present
  revision markers, distributions, p95 frame/input latency and stall thresholds
  fixed before measurement. No hardware/browser availability or pass is invented.

No new owner-only decision blocks this batch. Missing tools, native transport or
capacity are exact infrastructure failures, never skipped success or new consent
questions. Root AGENTS.md's pinned Flutter 3.47.9/Dart 3.13.7/Python Full check,
Rust 1.95.0 and existing isolated Cargo/FRB caches remain required. Android uses the
existing target-enabled cached Rust compiler as in RUST-M2-BRIDGE. Focused worker
checks and runner merged-tree/full-main gates remain distinct. All new implementation
checks here are **proposed/unrun**.

Premortem: incorrect prime promotion is caught by budget/status/count and exact-text
negatives; effect state leakage by forced-module restore and retained snapshots;
false native success by source-bound projection/input tests and terminal official driver
results and aggregate-encoding/projection guards; overclaimed u64 proof by the
explicit unreachable-output limit above.
Expected delivery is five reviewed building results, separate from this planning
commit; no runtime speedup or completed migration is claimed.

Close RUST-PLAN-04 manually with this plan as evidence, not a receipt. Keep exactly
one open successor RUST-006-ee74a370, round 4 of 10, depending on all five building tasks.
The same authorized coordinator continues the chain; this pass starts no runner.
Move the successor to Needs decision to stop it. At round 10 or without new building
work, retain the stop question and an open remaining-proof task unless actual ledger
qualification proves the goal met. An empty queue is never completion.

## Planning verification and handoff

A fresh read-only builder review found the whole-envelope E2BIG defect described
above. The saved fixture and both consumer contracts now require complete-record
projection, explicit derived provenance, original/projected hashes and the aggregate
encoding guard. A focused independent recheck measured **9761 bytes including
RUST_CORE and driver flags**, successfully exercised both downstream exec equivalents
and reported **nothing important left**. These are source/input-feasibility checks,
not native builds or StateSession execution.

Final scoped readback checks six complete new records, exactly one round-4 successor
with all five building dependencies, the manual planning closure and the unchanged
unmet goal. All **26** local plan/Sources/consent paths and anchors pass. Task
validation passes: **138 tasks, 21 goals, no drafts**; before commit only the seven
intended task records are pending. `git diff --check` passes. Bundled Docs Sync
stale/check exit 0 but report no docs/roles.json manifest, so they provide no link
coverage; the separate scoped check supplies it. No product tests, builds, device
journeys or goal qualification were run in this planning pass.

First new building task is RUST-001-0fdde2b6, an offline isolated worker task after
its already-closed replay producer. Effects and fixture work are independent lanes.
The owner's existing first Now task remains first. After the single local planning
commit, check committed-store selection with tasks why; that result is not resource
admission or dispatch. This branch-local commit still needs the same coordinator's
supported integration into canonical main; no push or runner start occurs here.
