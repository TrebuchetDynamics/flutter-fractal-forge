# Exact Number Walls state and effect-bridge frontier

## Brief and authority

RUST-006-ee74a370 completes **Plan round: 4 of 10** for
[RUST-ENGINE-001](../../tasks/goals/RUST-ENGINE-001.md), under the
[accepted migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration).
This is focused planning, not a backlog sweep or implementation. The goal stays
**unmet**. All design choices below are **planner calls**, not new owner decisions.
Preserve IDs, closures, saved data, mathematical claims, default-off flags and the
working Flutter path. No session or individual field switches owner in this batch.
No runner, native test, installation, publication, receipt or qualification starts here.

Inspection base: `daa878f34af79daa3fe2c9cfabf0723fe34461d7`; initial checkout clean.
The supplied consumer reports prepare API 4 and read-only preparation **READY**,
no pending conversion or in-flight contracts. Initial validation passes: 138 tasks,
21 goals, no drafts/pending records. Unrelated prepare diagnostics are not validator
errors and are outside this single planning trigger. The owner's first Now task,
ACAD-013-4142ef42 at rank 1000, is not moved. No RUST-006 slot report or saved ledger
patch was found; there is no proposal to replay. Preserve all five newer verified
closures rather than apply historical ledger suggestions.

## Finished evidence and limits

Read records and actual `attempt-1/report.json` files **in place** under the absolute
Git common directory's `autowork-execution/slot-data/`. Do not copy private bundles
into the checkout. These are reported worker results, not newly executed checks.

| Task / candidate | Actual reported result | Boundary |
|---|---|---|
| RUST-001-0fdde2b6 / `cb35266384f54c9b75f46d2c78442d13ce633c61` | Four public prime tests, 26 workspace tests, ten Dart tests and 75 scratch Dart-oracle cases passed. Exact raw length, text, status, count, cancellation and chunk precedence represented. | No grids, frames, Session ingress or app routing. |
| RUST-002-07ee2543 / `1d32db9cd2481d183b66f3ac00230d55066206c1` | Four effects plus three replay tests, 26 workspace tests and 14 Dart tests passed. Eleven setters, forced-module restoration, rollback and persistence; crate-private reuse of normalization clamp. | Original replay only 0–46; no effects bridge or installed effects proof. Preserve the landed normalization helper change. |
| RUST-003-2b8363f4 / `b0f60ad68d7808a02b5af1a9207bb2d411060150` | Four launcher tests, analyzer/three adapter tests and new-target Linux/Android compilation passed. Complete-record four-module projections fit the aggregate guard. | Compilation-only in this report; no full-catalog/native success inferred. |
| RUST-004-2dccfb82 / `2dbbceb6cc2f0509868ff6a9ca3ce967e90dd695` | Two official Linux runs: three bodies plus teardown, exit 0, protocol_success/allTestsPassed true, remaining_pids empty; 218 persistent evidence files verified. | Xvfb/llvmpipe transport, not hardware rendering/performance. Private `attempt-1/native-evidence/final` retains final driver evidence. |
| RUST-005-c9f7f34a / `e92f07e6a889d10af3c8bcdef2d3897e90f5a26f` | Three actual Waydroid native tests, none skipped, Flutter exit 0; target/model/boot and matching consent variables verified; APK/SO/input identities, 52 evidence files and owned cleanup retained. | Existing container target, not physical GPU evidence. Private `attempt-1/evidence` retains terminal transport/artifact evidence. |

All five records are already **coordinator_verified** with their existing evidence.
Reports contain no final environment failure/blocker needing a replacement task.
Linux and Waydroid prove the existing **four-module scalar API**, not the new core
effects, Number Walls, all catalog modules or full M2. Successful installed identity/
revision outputs above 2^53 remain unreachable through low allocation counters;
rejected large stale operands prove exact inputs only. Do not add a public identity
setter, reopen these tasks or upgrade their proof. Historical pending-live references
to the now-finished peer identify report capture time, not a new dependency.

## Current source and decided interfaces

- `number_wall_model.dart:1–81,190–463` defines six sequences, modular Fibonacci
  doubling, canonical signed residues, pivoted determinant elimination, inverse,
  zero-denominator fallback, support halo and bounded grids. Existing independent
  Bareiss fixtures in `test/modules/number_wall_parity_fixtures.dart` record **971**
  cases and fingerprint **196b53dc**. Port the mathematics, not a shader approximation.
- `NumberWallGrid.generate` permits rows 1–64, columns 1–256 and columnStart in
  rows−1..1000000; signed Pagoda adds one support element on either side. It checks
  cancellation during support/elimination, at row yields and before publication.
  Its arithmetic API accepts a modulus >=2 but is **not** a prime certificate.
- `number_wall_frame.dart:14–75` reuses module-owned proof only when raw prime text
  exactly equals the previous frame's canonical prime. It preserves Continue
  certification beyond the default budget; replay flags never create a frame.
  Reuse the grid only when sequence, prime, rows, columns and origin all match;
  style-only changes wrap the same immutable grid. Publish settings and grid together.
- `fractal_controller.dart:110–140,420–601,1169–1314` and
  `test/number_walls/number_wall_state_test.dart` own pending/error/last-good,
  generation, shouldCommit, newer-request/navigation/edit cancellation and latest
  candidate merging. A revoked old request cannot cancel a newer request. Retained
  grid state can survive leaving the module. Prime input bypasses generic decimal
  normalization until exact validation; non-prime fields still use the schema.
- `Session` currently clones a private candidate and publishes once, supports six
  IDs and rejects non-null trajectories. Preserve that scalar/effects transaction
  contract and rejected-batch rollback. Add only `number_wall`, not all IDs by prefix.
- `session_replay.rs:173–201` intentionally stops at 47 outputs. Actual original
  events 47–67 are precisely Number Walls ingress/history/cancellation then an
  ordinary reset; they contain **no trajectories, randomization or gestures**.
  Full 68-event parity is achievable without pretending to port those other owners.
- `fractal-bridge/src/api.rs` lacks all eleven effect constructors/getters even
  though `session_effects.rs:79–114` already provides core getters. Extend the same
  opaque synchronous API and five-file FRB inventory; do not invent a second state
  owner or expose mutable hidden restore state.

### Arithmetic and bounded work

**Planner call:** add exactly pinned `num-bigint = "=0.4.6"` to fractal-core, using
signed BigInt arithmetic internally and canonical decimal text at exported value
boundaries. Use default std support, no rand/serde/quickcheck features; no extra
direct arithmetic dependency is required. This is an ordinary local dependency
provisioning step already allowed by the migration's first-frontier setup, not a
new host install or live permission. The [versioned upstream documentation](https://docs.rs/num-bigint/0.4.6/num_bigint/)
confirms signed/unsigned arbitrary integers and optional features. Resolve/fetch
only this dependency closure into existing isolated CARGO_HOME, preserving every
unrelated locked package. Then run all required Cargo checks locked/offline.
The inspected isolated cache has no num-bigint package: **not pre-provisioned**.
A failed fetch is an exact setup failure returned to the same coordinator, not an
owner question, skipped pass or permission to switch caches/change host profiles.
Planning performs no fetch or lockfile edit. GRID also owns the narrow dependency-graph
description update in `docs/engineering/spec.md#isolated-rust-workspace-foundation`
and the existing `fractal-core/src/lib.rs` graph guard: add exactly the resolved
pure arithmetic closure, retaining all-edge/all-target checks and injected forbidden
Flutter/Android/GPUI negatives. Do not disable the guard or open it to arbitrary
packages. The Number Walls validation boundary itself remains unchanged.

Reject machine-integer grids (they narrow the accepted exact model), a new homegrown
bignum implementation (unnecessary audit burden), and probable-prime promotion.
Keep the existing dependency-free prime validator unchanged. Arbitrary-precision
arithmetic does not itself certify a modulus or expand its validation budget.

Expose pure resumable grid jobs using Rust-local AtomicBool cancellation and at
most 1024 **scalar field-update work units** per advance, plus row/completion
checkpoints. Count support values, pivot search/elimination work; do not hide an
entire grid/determinant behind one unit. A bounded bigint inverse/scalar operation
can finish within a unit; this is not a wall-clock responsiveness or 8 ms claim.
Do not publish partial grids. Synchronous complete helpers may drive the same job.
Internal names, representation of the elimination cursor and test helper layout
are worker-reversible within these semantics.

### Frame and session ownership

**Planner call:** use a pure frame-preparation job composed of prime then grid
stages. It consumes normalized non-prime parameters, raw prime text, optional prior
immutable certified frame and trial budget; result is pending or terminal typed
status/frame. Only module-owned successful jobs create certified frames; no replay
flag, deserialized proof constructor or generic syntax result may do so.

**Planner call:** extend the inert Session with begin/advance/cancel operations
and a session-owned monotonic request token. Begin validates identity/current
revision and stages the complete target candidate while publishing pending metadata;
it does not synchronously drain the mathematical job. Advance performs a bounded
step outside any platform executor, and successful completion atomically publishes
settings/view/transparency/frame only for the still-current owned request. Ordinary
commands remain ordered transactions. No callback into Dart or new async runtime.
Platform executor/FFI job transport is **later proof**, not this core port.

For shouldCommit, accept an explicit owned-request revocation/active guard at the
step/commit boundary rather than a foreign callback. Guard false before begin has
no effect; revocation cancels that request only, never its successor. Recheck just
before publishing. Wrong/stale identity/revision operations and failed batches
must not invalidate valid pending work. Successful source-defined edits/reset/
navigation invalidate pending work as in Dart, with source-specific state/status
retention. Non-prime mathematical edits merge the latest owned candidate but use
the **committed** prime; style-only edits reuse a committed grid. Preserve the
actual module-selection pending/default behavior and rotation/effect interactions.

Revision rule (new inert API only): each accepted nonempty batch still increments
once; begin increments once for pending metadata; standalone current terminal
completion/cancellation increments once. Cancellation caused by an accepted edit
shares that batch's one increment, never an additional increment. Pending steps
and stale old completion publish nothing and do not increment.

Reserve terminal capacity before admitting work: begin requires current revision
checked_add(2) to succeed, otherwise reject without changing current/pending work.
Any transaction that keeps a request pending must leave one revision available
beyond its proposed published revision; reject atomically if it cannot. An edit
that legitimately cancels that request may use the final revision and clears the
request in the same publication. Tests cover begin at MAX-2 then terminal MAX,
rejected begin at MAX-1, and rejected pending-preserving no-op versus successful
source-defined cancelling edit at MAX-1. This prevents pending work stranded at
MAX without changing ordinary no-pending batch rules.
Retained snapshots are immutable, including grid/status; a rejected operation
cannot mutate effective or hidden effect restore state. The replay compares
observable M0 output, not a fabricated Dart revision counter. Preserve existing
core/bridge tests; unknown APIs' names remain worker-reversible.

For Number Walls commands that require work, the caller/harness explicitly starts
and drives the job. Do not hide unbounded validation in synchronous apply_batch.
An attempted mixed synchronous batch requiring deferred work must fail atomically
with a typed deferred-operation error and no partial mutation; the explicit
begin operation stages the entire supported ingress transaction instead. Test
this limit and document it; no app routing depends on this new API yet.

## Saved executable batch

Five new tasks total, all under RUST-ENGINE-001. No owner-first task is moved.

| ID | Outcome | Real producers | Placement |
|---|---|---|---|
| RUST-M2-GRID | Exact six-sequence/modular determinant and resumable immutable grid parity, isolated dependency setup | Original M0 replay/model fixtures | Now below rank 1000 |
| RUST-M2-FRAME | Certified resumable frame preparation and previous-proof/grid reuse | RUST-M2-GRID and RUST-001-0fdde2b6 | Next |
| RUST-M2-INGRESS | Inert session request ownership, exact commits and all 68 original outputs | RUST-M2-FRAME and landed scalar/effects transactions | Next |
| RUST-M2-EFFECTS-BRIDGE | Eleven typed effect commands/getters, Rust boundary tests and deterministic regenerated glue | RUST-002-07ee2543 and RUST-M2-BRIDGE | Now |
| RUST-PLAN-06 | Reconcile actual outcomes and expand next reachable ownership/native frontier; **round 5 of 10** | Every new building task above | Next |

Grid and effects-bridge are independently buildable; their write sets are disjoint.
Frame consumes the grid API; ingress consumes certified frames. No file-overlap
prerequisite is added. Scheduler resource/protected-path/file admission still
applies; planning promises no runtime concurrency. Reuse pinned Rust/Flutter/FRB,
existing caches and private TMPDIR, never another checkout's project metadata.
Scoped attributable defects blocking checks within each task's Touches can be
repaired without weakening assertions. Out-of-scope runtime/transport failures go
to this same coordinator with task/source/operation/evidence, not duplicate tasks.

## Remaining proof and continuation

The entire [prior continuation](RUST-PLAN-04.md#remaining-proof-and-continuation),
[remaining proof map](RUST-PLAN-02.md#remaining-proof-map),
[auxiliary inventory](RUST-PLAN-02.md#auxiliary-mathematical-domains-retained) and
[predeclared measurement protocol](RUST-PLAN-02.md#predeclared-native-measurement-protocol)
are incorporated unchanged, including every M0–M14/final threshold and gate.
Specifically, none of the following is silently replaced by this batch:

- M0 originals/source provenance and M1's target-bound nonrendering proof remain.
  Full 68-event core replay will still not be app, browser or installed M2 proof.
- M2 still needs trajectories/settings/compatibility/RK4; deterministic
  randomization and Number Walls undo; interpolation/animation/timer ownership;
  every physical transform (wheel/pinch anchor, drag/fling, keyboard, double tap,
  rotation lock); all remaining module semantics; async executor and exact frame/
  request transport; native effects/forced restore round trips; reachable high-u64
  output transport; stale snapshot/frame rejection; snapshot-only legacy rendering,
  rollback without lost state and a whole-session owner switch. No per-field switch.
  Editor/preset/history/deep-link **app routing** remains unqualified even after
  source-matched core ingress tests. Next planner must build reachable native
  fixture producers before scheduling their executions; old scalar targets do not
  exercise new effects or frames. Keep the 32768-byte aggregate/provenance guard.
- M3 runtime registry/catalog/presets/capabilities retains both identity namespaces,
  production/debug/performance/hidden filtering, order, exact values, provenance and
  explicit presentation mapping. Baseline readers are not runtime ownership.
- M4 exact uniforms/separate samplers/versioned bindings; M5 boundary neighbors,
  capabilities/hysteresis; M6 honest CPU formulas/tiles/cancellation; M7 reference
  orbits/deep coordinates/double-float/perturbation all remain separate.
- M8 Linux external texture/Android surface, no per-frame Dart bytes, durable GPU
  resources/latest-state mailbox, resize/orientation/loss/background/fences/cleanup
  and independent physical hardware qualification; M9 edited Mandelbulb/depth;
  M10 all families; M11 Rust backend/scheduler/viewport ownership remain.
- M12 pinned-revision 4K/8K PNG with bounded memory/cancel/dimension/crop/color/alpha;
  M13 saved/import/history/deep-link compatibility; M14A WASM/legacy renderer and
  M14B real-browser WebGPU/export/download remain separate gates.
- Final audit includes Fourier/image/Cantor analysis, RK4, exact Number Walls,
  Gaussian moat, quaternion prime norms and all actual mathematical owners, no
  invented audio feature. Audit imports/dependencies and routing, not suffixes.
  Flutter retains UI/l10n/accessibility/platform I/O; Web is never stranded.
- ADRs 0005/0006 retain predeclared physical device/GPU/refresh/backend/build/viewport/
  trace, 5 s warmup, 30 s measurement, compositor-present revision markers,
  distributions, 60 Hz p95 interval <=1000/60 ms, max stall <=100 ms and p95
  input-to-present <=50 ms; optional 120 Hz needs compatible hardware and its own
  <=1000/120 ms run. No target availability or passed hardware claim is invented.

No new owner-only gap prevents this offline batch. Existing Waydroid designation
and app-test consent remain unchanged; no new task acquires live authority.
Missing tools/network/cache/capacity are exact technical failures, not new consent
questions. Failed execution returns to the same coordinator/candidate.

## Verification and handoff

All implementation commands in the task contracts are **proposed/unrun** here.
Use root AGENTS.md's pinned Flutter 3.47.9/Dart 3.13.7/Python Full check and Rust
1.95.0; compare Flutter to fdroid/flutter.version and verify provisioned Python
imports on the actual host. Full offline checking belongs to the existing runner
merged-tree gate, distinct from focused worker checks. New dependency provisioning
precedes, never replaces or weakens, locked/offline verification.

Premortem: exactness narrowing is caught by large signed modular cases and 971
independent fixtures; false certificates by forged flags/low budgets; stale commits
by deterministic begin/advance/revoke interleavings; hidden effect leakage by failed
batch/forced→forced→ordinary tests; generated drift by complete twice-generated
inventories. No sleeps or wall-clock races substitute for ownership assertions.

A fresh read-only builder review found two material gaps. Both are planner-resolved:
terminal-revision reservation and pending-preserving/cancelling edge tests are now
in INGRESS; GRID now owns the narrow spec dependency-graph update and existing
strict dependency guard extension. Parent inspection confirmed the guard's exact
package-set comparison and retained forbidden-platform negative assertions. The
review found no further material obstacle to all 68 replay events or backward-
compatible bridge extension. Grid and effects-bridge remain independent lanes.
Implementation, dependency fetch and native checks were not run by the review.

Planning checks passed: 18 scoped Markdown links/task Sources and anchors;
five-task cap/four-build successor/round checks; manual closure with original
Scope/Acceptance/Checks/Dependencies unchanged; untouched goal/evidence; exact root
Full check in all four implementation records; and whitespace checks. The working-
tree validator reports 143 tasks, 21 goals, no drafts and six intentional pending
records from this uncommitted batch. Post-commit validation must clear those six.
Bundled docs.py stale/check both exit 0 but report no docs/roles.json manifest;
this is not repository-wide link coverage. The scoped readback supplies coverage
for this batch only. No implementation/toolchain/native/browser checks ran here.

Expected execution is four reviewed building results, separate from this planning
commit; no measured speedup is claimed.
Close RUST-006-ee74a370 **manually** using this plan as evidence, not a receipt or
goal qualification. Keep exactly one open plan, RUST-PLAN-06, **5 of 10**, depending
on all four new building tasks. The same authorized coordinator continues the chain;
move that successor to Needs decision to stop it. This pass starts no runner.
