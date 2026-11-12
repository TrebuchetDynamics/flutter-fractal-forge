# RUST-M2-WORK-BRIDGE — Bounded inert scheduled service

## Implemented boundary

[`StateWorkService`](../../rust/crates/fractal-bridge/src/api.rs) consumes the
[WORK-QUEUE policy](RUST-M2-WORK-QUEUE.md) through
[`state_work_executor`](../../rust/crates/fractal-bridge/src/state_work_executor.rs).
It implements the [bounded-admission plan](RUST-PLAN-09.md#bounded-admission-and-fair-execution),
within the [planned Rust boundary](../engineering/spec.md#planned-rust-engine-boundary).
The Flutter app remains the active owner. No controller, renderer or adapter is routed here.

Each service instance has one eight-job admission domain and one pump flag.
`submit_trajectory` and `submit_number_wall` are synchronous capture/admission calls.
They check the immutable Session identity and reserve a WorkQueue permit **before**
submitting a closure to the existing generated
`FLUTTER_RUST_BRIDGE_HANDLER.thread_pool()`, using exported `BaseThreadPool::execute`.
They do not acquire the Session mutex, certify primes, integrate RK4 or create frames.
A full domain returns `Busy` without a pool submission, waiter or retry queue.
An occupied Session/kind returns `AlreadyAdmitted`.

`replace_trajectory` and `replace_number_wall` borrow an existing ticket. Replacement
requires the same service, Session and kind, and atomically revokes the old permit,
including at capacity. The service allocates checked increasing generations; overflow
and stale/foreign tickets fail without replacing work. Separate submit/replace methods
avoid optional opaque borrowed arguments unsupported by the current generator settings.

The pump uses WorkQueue's Session round-robin and alternating kinds. A turn either
begins one captured request or advances one existing bounded chunk (wall work limit
256; trajectory at most 256 kernel steps). With S runnable Sessions, each receives
a turn within S selections. This is selection fairness, not a wall-clock guarantee.
The executor lock covers admission, selection and the empty/pump-flag transition.
Neither that lock nor the policy lock is held while waiting for the Session mutex
or doing mathematical work. Empty exit and admission therefore cannot lose a wake.

## Ownership, status and failure

`StateSession` now shares its **same** `Mutex<Option<Session>>` through an Arc.
There is no copied mutable Session. Jobs hold a Weak reference to that mutex and
own their core request tokens and permit guards. Expected revision is validated
on the first pump turn, not by doing Session work during admission. Later turns
use the current Session revision and verify the owned pending token. Manual
replacement/cancel/completion cannot be adopted as this ticket's result. Existing
core token/settings-generation/guard checks remain the publication boundary.

`StateWorkTicket.status()` copies cached `StateWorkStatus` only. It never runs math
or locks a Session. Queued tickets have no snapshot. Running/terminal snapshots
are detached, including access to existing trajectory/wall frames. `Finished`
means terminal work, not necessarily a certified prime: inspect `wall_status`.
Trajectory/core errors and caught job panics report `Failed` with an error.

Terminal/error/panic paths drop the permit exactly once. Cancel, ticket drop,
service drop, and Session shutdown/drop revoke and remove matching entries.
Cancellation does not synchronously execute a core cancel operation; any already
running bounded chunk observes the same guard before publication. Core pending
storage may remain revoked until a later core operation or Session release.
Session registration is closed atomically with shutdown, so later scheduled
admission fails without waiting on the Session mutex. A job panic can poison its
Session, preserving the existing fail-closed behavior, but does not poison the
queue or prevent other Sessions from running.

The executor stores only active weak ticket entries, bounded by permits. Terminal
data lives in caller-held tickets, not a global completed-result map. Session
subscriptions are weak and pruned on admission; completed frames retain the
existing core cache and last-good semantics.

## Verification and generated inputs

The counted-submission tests in
[`state_work_executor.rs`](../../rust/crates/fractal-bridge/tests/state_work_executor.rs)
were added before the service was wired to the real pool. They cover capacity+1
without an extra submission, atomic replacement, concurrent admission/empty exit/
replacement, stale revision, cancel/drop/close and continued use. Executor unit
cases inspect actual wall/trajectory turns, the trajectory chunk bound, terminal
frame retention, and a panic while holding a Session lock. Existing public Session,
trajectory and wall tests remain the compatibility checks; no oracle is refreshed.

Tools: Rust 1.95.0, Flutter 3.47.9/Dart 3.13.7, FRB runtime/Dart/codegen 2.13.0,
and cargo-expand 1.0.127, selected from the existing isolated Git-common-directory
cache. Python is `/usr/bin/python3` with pytest, jinja2 and `markupsafe.soft_str`.
`flutter pub get --offline --enforce-lockfile` regenerates local package metadata.
No dependency, lockfile, codegen configuration or source fixture changes are made.

The generation owner is `scripts/ci/rust-bridge-codegen.sh`, with inputs
`flutter_rust_bridge.yaml`, `rust/crates/fractal-bridge/src/api.rs` and the locked
runtime/Dart graph. Two complete generations must agree for all five owned files:

- `rust/crates/fractal-bridge/src/frb_generated.rs`
- `packages/fractal_engine_bridge/lib/src/rust/api.dart`
- `packages/fractal_engine_bridge/lib/src/rust/frb_generated.dart`
- `packages/fractal_engine_bridge/lib/src/rust/frb_generated.io.dart`
- `packages/fractal_engine_bridge/lib/src/rust/frb_generated.web.dart`

Generated bodies are never edited by hand. The complete two-run SHA-256 inventories
agree. Inputs at generation:

| Input | SHA-256 |
| --- | --- |
| `rust/crates/fractal-bridge/src/api.rs` | `1982622919e38a02dd2c8a2b16c766f54583acaa3507f93376bb0fb21e9cc935` |
| `flutter_rust_bridge.yaml` | `1a3107d0e7a8ad77e68c5d2a00a9e186b7dcf40029aa6ac9e2382548056fa400` |
| `rust/Cargo.lock` | `97ff3cde076b918449b860fd6b9099b3e30372603a9ebc92187d21f24848f559` |
| `pubspec.lock` | `b0677b30481bb5321a7e365eb64dc9b28a71987d3fa32626ff13aa90c328adc8` |

Outputs, in the five-file order above:

```text
8ad49ee50b753135533e82afde6a8c774bbbec137d3149f2c405a7a32494a056
929f3cd44438d48bc4419dd0eaf15747b3afe4a1e5d8df4552b055003f1fa4a8
f06f0a8d43edce4fa9533d3d4c1ba60a7608c830f8d337d073f04f173df08667
95716c60b038c0e5a9e810b0ed9e298841dbc7fe6d90d7283c4214afdd5925d7
b0da786cf712ab4d74aa488a1c25d53b4c6451b48749bae7c5e7f0711bf6ed43
```

Passed locally with the tools and inputs above:

| Check | Result |
| --- | --- |
| Focused `state_work_executor`, `state_trajectory`, `state_session`, `state_number_wall` bridge targets | 14 tests passed |
| `scripts/ci/rust-check.sh` | fmt, warning-denying clippy, 118 workspace tests passed; none ignored |
| Two complete codegen runs and inventory comparison | All five files agree |
| Bridge/smoke-target analyzer and `rust_engine_adapter_test.dart` | No analyzer issues; 3 tests passed |
| `scripts/migration/tests/test_state_session_smoke.py` | 12 tests passed |
| Linux debug trajectory and high-u64 smoke targets | Both compiled with `RUST_CORE=true` |
| Android-x64 debug trajectory and high-u64 smoke targets | Both APKs compiled with `RUST_CORE=true` |
| Root Web debug builds | Both `RUST_CORE=false` and `RUST_CORE=true` compiled |
| Protected-path diff and whitespace check | No app/core/fixture/lock/config drift; clean whitespace |

Web's Wasm dry run still warns about the pinned FRB package's `JSAny` runtime
check. These successful Web debug builds are not Wasm qualification. Android
builds retain the existing Kotlin/Java compatibility warnings. No dependency or
platform configuration was changed to suppress warnings.

The coordinator owns the merged-tree gate. These focused results are not a
full-main result.

## Qualification limits

Legacy `StateSession` synchronous/manual and normal-mode async methods remain
compatible diagnostic bypasses, **outside this service's admission claim**. Each
service instance bounds its own jobs; this is not a process-wide bound across
independent service instances or legacy callers. Whole-session routing and a bypass
audit remain necessary before a full-executor claim.

Linux/APK smoke-target compilation and both root Web flag builds are compilation
checks only. They do not execute an installed scheduler or qualify the future app,
whole-executor responsiveness, browser/native presentation, physical hardware,
throughput or latency. Flags remain default-off. Original replay, exact-u64,
last-good and provenance gates remain unchanged, as do
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[ADR 0006](../adr/0006-native-demonstration-performance-is-target-specific.md).
Installed trajectory/u64 execution has its existing separate task route; no new
live qualification follows from this service.
