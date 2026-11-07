# RUST-M2-TRAJECTORY-JOBS — Bounded requests and shared sample cache

## Result and boundary

The Rust-local [Session](../../rust/crates/fractal-core/src/session.rs) now owns
bounded trajectory requests and detached terminal frames. The
[request owner](../../rust/crates/fractal-core/src/session_trajectory_jobs.rs)
reuses the [existing RK4 job](../../rust/crates/fractal-core/src/trajectory.rs).
`apply_batch` does not execute RK4 work.

This extends the earlier [metadata-only result](RUST-M2-TRAJECTORY-STATE.md).
It implements the accepted [job and cache slice](RUST-PLAN-08.md#trajectory-jobs-and-shared-cache)
within the [planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary)
and [ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md).
The app, renderer, generated bridge, fixtures, feature flags and locks are unchanged.
This is not a public trajectory bridge, executor, total admission/latency bound,
renderer qualification or full-M2 result.

## API for the bridge consumer

- `Session::new` creates an isolated completed-sample service.
- `Session::with_trajectory_cache(catalog, session_id, module_id, cache)` accepts
  a cloneable `TrajectoryCache`. The bridge consumer must create one process
  service and share its clones across bridge Sessions. Core does not create a
  hidden process singleton. Identity allocation and Session serialization remain
  the caller's responsibility.
- `begin_trajectory(session_id, expected_revision, guard)` captures current typed
  settings, module and settings generation. It returns an optional `RequestToken`
  without advancing integration. An inactive guard has no effect. Missing typed
  settings return `UnsupportedTrajectory`. Admission publishes one revision and
  reserves terminal capacity before replacing existing work. Cache hits also wait
  for `advance_trajectory` before frame publication.
- `advance_trajectory(session_id, expected_revision, token)` returns
  `TrajectoryProgress::Pending { steps_completed }` or `Finished(result)`.
  Each call delegates at most one existing chunk of 256 integration steps,
  including burn-in. The kernel yields on exact chunk boundaries before success.
  Pending advances do not change the Session revision.
- `cancel_trajectory(session_id, expected_revision, token)` cancels only that
  current request. A terminal publication or current cancellation increments the
  revision once. Consumed, superseded or wrong-kind tokens return `Cancelled`
  without changing current state. Foreign tokens return `WrongSession`.
  Every operation checks the expected current revision first.
- `RequestToken::kind()` distinguishes `Trajectory` and `NumberWall` requests.
  Both reuse the existing monotonic `RequestGuard` revocation owner.
- `Snapshot::trajectory_pending`, `trajectory_status`, `trajectory_generation`
  and `trajectory_frame` expose detached request state and the last good frame.
  `TrajectoryFrame` exposes its token, module, captured settings generation,
  cache-hit provenance and shared immutable `AttractorTrajectory`. That value
  owns validated settings, sample points and projected bounds. Terminal sample
  storage moves out of the kernel without a final sample copy.

The last good frame survives cancellation, divergence, settings changes and
navigation. Its own settings and generation describe its samples, not necessarily
the current camera. Retained snapshots and frames remain valid after later edits
or Session drop. A bridge consumer must compare provenance before displaying a
frame as current. An old token does not replay a terminal result; retain the frame
or terminal progress value instead.

## Validity, rollback and shared cache

Settings changes invalidate the current request, including a private batch that
changes A to B and back to A. Module changes and view/session resets follow the
existing metadata rules. Scalar camera, palette, other parameter and
parameter-timeline changes preserve samples when typed settings remain equal.
A parameter-only reset also preserves settings under the landed metadata policy.
Settings generation is separate from unrelated scalar revision changes.

Failed transactions do not change live jobs, metadata, effects, revisions or
frames. Trajectory publication updates only its own fields, not an old camera or
parameter snapshot. Staged Number Walls targets cannot restore old trajectory
ownership or erase a newer completed frame. Wall success invalidates incompatible
trajectory work. Wall rejection and cancellation leave independent trajectory work
and last-good frames intact. All revision writers preserve capacity for each
remaining terminal publication, including parameter-timeline callbacks.

`TrajectoryCache` stores at most three distinct completed successes.
Lookup touches the entry. A fourth distinct completion evicts the least recently
used entry. Failed, cancelled and superseded work does not insert samples.
Independent misses are not deduplicated, even when a peer finishes first.

Keys use equality on the complete validated `OrbitTrajectorySettings` value:
version, system, all seed coordinates, integrator, step size, burn-in count,
retained count and projection. Version 1 and `rk4` are fixed by validation.
Numeric equality is intentional; this does not claim Dart cache-key byte equality.
Camera and palette values are not sample keys. The policy reuses the source
[three-entry touched cache](../../lib/core/modules/attractor_trajectory.dart).

## Executed offline checks

Setup used Rust **1.95.0**, Flutter **3.47.9 / Dart 3.13.7**, existing isolated
CARGO/PUB caches and private `TMPDIR`. Flutter matched
[`fdroid/flutter.version`](../../fdroid/flutter.version). Provisioned Python
imports passed. Offline, lockfile-enforced Pub resolution preserved the lockfile.

- The **29** focused Rust trajectory/job/metadata/wall/replay tests passed. They
  preserve all **68 original replay outputs** and the landed RK4 expectations.
- Public job/cache tests cover bounded advances, detached provenance, supersession,
  revoked guards, exact-boundary cancellation, divergence immediately after step
  256, rollback, wall rejection/cancellation, shared hits, touched eviction and
  independent misses. A white-box revision setup exercises public mutation seams
  at exhaustion, including both terminal owners and parameter timelines.
- `scripts/ci/rust-check.sh` passed formatting, denied-warning workspace clippy,
  and **97** workspace tests including doctests.
- The two unchanged Dart trajectory model/compatibility modules passed **13 tests**.
- The worker report records scoped documentation readback, local-link checks,
  protected-path preservation and whitespace checks.

The runner owns the separate merged-tree full gate. Native/browser/device,
hardware, production and full-M2 acceptance are not established here.

## Reuse and remaining work

This slice reuses typed camera metadata, the private Session transaction owner,
`TrajectoryJob`, `RequestGuard`, original catalog/replay envelopes and the Dart
sample-cache policy. It adds no dependency, in-flight deduplication, integrator
redesign, executor scheduling, app route or generated output.

RUST-M2-TRAJECTORY-BRIDGE consumes these APIs and must share the explicit service.
Transport, app/persistence/render consumers and live qualification remain separate.
Scoped Docs Sync Maintain updates this component note. Shared planning/history
closeout and the closeout Docs Sync pass remain coordinator-owned.
