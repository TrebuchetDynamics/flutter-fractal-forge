# RUST-M2-PHYSICAL-BRIDGE — Typed raw physical transport

## Boundary and API

This implements the inert transport from
[the physical transport design](RUST-PLAN-10.md#physical-transport), using the
existing [physical clocks](RUST-M2-PHYSICAL-TIME.md#api-and-clocks) and
[planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary).
The [domain ownership ADR](../adr/0005-rust-owns-all-mathematical-domain-logic.md)
and [target-specific qualification limits](../adr/0006-native-demonstration-performance-is-target-specific.md)
remain unchanged. Flutter retains arena, focus, nested-control, HUD and keyboard
routing. This does not enable a flag or replace the production camera owner.

[`api.rs`](../../rust/crates/fractal-bridge/src/api.rs) adds:

- Opaque `StatePhysicalInput` constructors for pointer, wheel, key, focus, wall,
  pump and `dispose_input` (Dart `disposeInput`, avoiding opaque-handle `dispose`).
  Pointer phases/kinds, keys/phases and focus are typed enums, not string commands.
- Opaque `StatePhysicalEvent::new(sequence, source_us, consumed, input)`.
  Source time is optional; source, wall and pump clocks remain separate.
- `StateViewport { width, height }`, optionally supplied per batch in logical pixels.
  No camera deltas, resolved scale geometry or Flutter camera math cross this seam.
- `StateSession::physical_generation()`, a locked read of the actual owner, including
  before the first event. Callers must not fabricate an initial zero.
- `StateSession::apply_physical_async`, generated as `Future<StatePhysicalResult>`.
  It uses the existing FRB pool and the same Session mutex as snapshots, commands,
  work and shutdown. It calls core `Session::apply_physical` once per batch and
  captures generation before releasing that lock.
- Detached result getters `snapshot`, `generation`, `interactions` and `keys`.
  Ordered logical vectors are copied on read; the snapshot is retained independently
  of later mutation or shutdown. Raw candidate camera updates are deliberately not
  exported: the normalized snapshot is the only camera result.

All identity, revision, pointer, button, sequence and generation fields retain Rust
`u64` and generated Dart `BigInt`. Source/wall/delta times retain Rust `i64` and
FRB `PlatformInt64` (native Dart integer, Web BigInt); no float conversion is added.
Validation stays in core, including consumed routing, sequence monotonicity, invalid
geometry, negative pump deltas and checked time arithmetic. Rejected batches do not
publish visible state or hidden pointer/time/generation changes. Empty batches do
not increment revision; each accepted nonempty batch publishes once. Abandoned
pump generations still consume sequence and publish the original no-op revision.

## Verification and limits

[`state_physical.rs`](../../rust/crates/fractal-bridge/tests/state_physical.rs)
contains two public-seam tests. The first maps bounded supported raw inputs from
[the frozen oracle](../../migration/oracles/physical-events.json): wheel focal zoom
and double-interruption drag/pump camera checkpoints, with `1e-8` tolerance. It also
checks exact ordered interaction/key results, every key/phase, focus, consumed
routing and one revision per batch. The second checks active-animation rollback
for mixed invalid/sequence/overflow batches, foreign/stale owners, abandoned pumps,
empty publication, optional viewport/source time, full-width pointer/buttons/
sequence and signed-time inputs, disposal and retained getters after shutdown.
The bridge has no JSON dependency; selected oracle inputs/checkpoints are mapped
directly into constructors, not a refreshed oracle or a new camera policy.

| Check | Result |
| --- | --- |
| Pinned setup and offline lock-enforced pub get | Passed: Flutter 3.47.9/Dart 3.13.7, Rust 1.95.0, provisioned Python imports; locks unchanged. |
| Bridge `state_physical`, `state_session`, `state_work_executor` | Passed: 9 tests. |
| Core `session_physical_events`, `session_physical_time`, `session_replay` | Passed: 8 tests; unchanged 67-scenario/382-checkpoint timed oracle and original replay. |
| `scripts/ci/rust-check.sh` | Passed: fmt, denied-warning clippy, 125 workspace tests/doc tests. |
| Two `scripts/ci/rust-bridge-codegen.sh` runs and five-file SHA-256 comparison | Passed: identical Rust/API/common/IO/Web outputs, FRB 2.13.0 and cargo-expand 1.0.127. |
| Bridge Flutter analyzer and `rust_engine_adapter_test.dart` | Passed: no analyzer issues; 3 tests. |
| `scripts/migration/tests/test_state_session_smoke.py` | Passed: 12 tests. |
| Existing trajectory and extended-u64 targets | Passed: Linux debug and Android x64 debug APK builds through `run_state_session_smoke.py`; compilation only. |
| Web debug, RUST_CORE false and true | Passed: both builds; this does not execute a browser or load native Rust on Web. |
| Protected-path diff and whitespace check | Passed: production Dart, fixtures, scripts, integration tests, core, locks and bridge configuration unchanged. |
| Scoped Docs Sync Maintain | Passed: component source/API/test readback, local links/anchors, task validation and repeat byte-stability check. `docs.py check .` reports no role manifest; scoped readback supplies the coverage. |

The runner owns the merged-tree full check. Generated signatures, Rust execution
and target compilation are separate evidence; none establishes installed generated
physical-event assertions. Full module/app/device/browser/hardware and performance
qualification remain pending. Unsupported Mandelbulb/quaternion and Gaussian
walk-key cases remain pure-only under the unchanged core oracle; this adds no
module admission. Native rendering, haptics, capture handlers, new scheduling
runtimes and production ownership switches are omitted.

Scoped Maintain updates only this designated component note. Existing spec/ADRs
remain valid; shared planning/task status and release history remain coordinator
owned. The read-only pruning plan changes no task records. Reuse is limited to the
existing core transaction/reducer, session mutex, opaque transport conventions,
FRB generator and original fixtures. No manifest, dependency, lock, schema, build
rule or CI change is needed.
