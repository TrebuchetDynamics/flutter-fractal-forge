# RUST-M2-FRAME — Certified immutable Number Walls frames

## Result and scope

The pure core [number_wall_frame API](../../rust/crates/fractal-core/src/number_wall_frame.rs)
composes the existing exact prime job, then the exact grid job. It ports
[NumberWallFrame.prepare](../../lib/core/modules/fractals/number_wall_frame.dart)
under the [frame ownership design](RUST-PLAN-05.md#frame-and-session-ownership).
The [replay validation boundary](../engineering/spec.md#number-walls-replay-validation-boundary)
is unchanged. No Session, bridge, renderer or app route uses the new API yet.

## Producer and consumer API

- `NumberWallFrameJob::new(raw_prime, params, previous, max_trial_divisions)`
  owns a `BTreeMap<String, ParameterValue>` of normalized non-prime parameters.
  This reuses the existing core settings representation. Prime text is a separate
  raw `&str`; the map's prime, verification and status values cannot certify it.
  Non-prime schema normalization remains the caller's responsibility.
- `advance(&AtomicBool, grid_work_limit)` returns `None` while pending, or a shared
  `NumberWallFrameResult` with `status()` and `frame()`. Only `VerifiedPrime` carries
  a frame. Invalid, composite, unfinished and cancelled work carries none.
  Missing/malformed mathematical fields, invalid dimensions and invalid origins
  return `Invalid`. Other unexpected grid errors also map to `Invalid`.
- `phase()` exposes `Prime`, `Grid`, `FinalCheckpoint` and `Finished`.
  A positive-limit call performs one existing prime advance (at most 1024 odd
  trials), or at most `min(grid_work_limit, 1024)` scalar grid units.
  `last_grid_work_units()` reports only grid work. Zero checks cancellation without
  advancing. Bigint operations and decimal conversion remain indivisible; these
  bounds do not establish wall-clock responsiveness.
- The job yields between prime and grid stages. It preserves the grid job's row
  and completion checkpoints, then yields again after acquiring complete grid
  storage and before publishing the frame. Cancellation is checked independently
  of any future request-owner guard, including reused proof/grid paths and the
  final publication boundary. Terminal results remain stable after cancellation.
- `NumberWallFrame::prepare(raw_prime, params, previous, budget, cancelled)` is a
  synchronous convenience driver of the same resumable job, not an executor.
- A successful `NumberWallFrame` has shared-only `params()` and `grid()` getters.
  The prime setting is canonical text and matches the complete exact grid.
  Frame/result fields are private, with no public certificate constructor or
  deserialization. A cloned frame retains its immutable `Arc<NumberWallGrid>`.

Only an actual successful frame can supply prior proof. Raw prime text must equal
that frame's canonical grid modulus exactly. Thus a completed larger-budget
Continue proof survives a later lower-budget style edit. Leading zeros require
fresh certification, even if the resulting canonical modulus will be unchanged.
A terminal `Unverified` result does not resume; Continue starts a new job with a
larger total trial budget, as the existing prime validator specifies.

Grid storage is shared only when sequence, certified modulus, rows, columns and
origin all match. Style-only changes preserve the same allocation. Mathematical
key changes compute a new grid. A crate-private `NumberWallGridJob::into_result`
handoff moves completed cells into the frame without a full-grid clone; it does
not expose a new public proof path. Failed or cancelled candidates cannot mutate
retained previous frames.

## Verification

Rust 1.95.0 and `CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"` reused the provisioned
locked dependency cache. Flutter 3.47.9 matched `fdroid/flutter.version`; Dart was
3.13.7. The provisioned `/usr/bin/python3` imported pytest 9.0.2, jinja2 3.1.6 and
callable `markupsafe.soft_str`. Checkout-local Flutter metadata was regenerated
with `flutter pub get --offline --enforce-lockfile`. No dependency or lock changed.

Checks passed:

- `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test number_wall_frame --test number_wall_grid --test number_wall_prime --locked --offline`:
  12 tests, including three new frame cases. Frame coverage includes forged flags,
  raw-versus-normalized prime input, canonical publication, complete/stepped
  agreement, actual 100003-trial certification beyond the default 100000 budget,
  lower-budget proof reuse, leading-zero revalidation, shared grid identity,
  each mathematical-key change, invalid dimensions/origin and deterministic
  cancellation before every traced advance with and without storage reuse.
- `autowork-run scripts/ci/rust-check.sh`: formatting, denied-warning clippy,
  38 workspace tests and one compile-fail doctest passed. The doctest rejects
  public frame construction from an uncertified arithmetic grid.
- `flutter test --no-pub test/modules/number_wall_model_test.dart test/number_walls/number_wall_state_test.dart`:
  all 15 unchanged source-model/state tests passed.
- Source readback confirms the Dart canonical-text proof reuse rule, all five
  mathematical grid keys, canonical immutable publication and final cancellation
  checks. The existing public tests retain forged-ingress and last-good-state
  coverage. Migration baselines, Dart/bridge sources and lockfiles are unchanged.

Scoped Docs Sync Maintain adds this designated API/result/gap note. The spec and
planning owners were inspected and remain unchanged. Scoped links/API readback
and repeat-pass byte-stability checks passed. Bundled `docs.py stale` and `check`
report no role manifest; they do not establish repository-wide documentation
coverage. The coordinator retains task bookkeeping and shared-history updates.
The runner owns merged-tree full checking; this worker did not run the full gate.

## Remaining proof

RUST-M2-INGRESS is the next consumer of this public core job/result/frame API.
Session begin/advance/cancel ownership, atomic session snapshots and full replay
remain unported here. Platform executor/FFI transport, native/browser execution,
app routing and hardware timing remain separate proof. These offline checks do
not qualify any of those paths.

The change reuses the prime algorithm, budgets, grid cursor, settings value type
and standard-library `Arc`. It omits new dependencies, a parallel certificate
format, Session enablement, generated output, saved-format changes, randomizer/
undo work and renderer changes.
