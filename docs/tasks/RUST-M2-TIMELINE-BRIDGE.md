# RUST-M2-TIMELINE-BRIDGE — Session timeline transport

## Boundary and reuse

This implements the [timeline transport plan](RUST-PLAN-10.md#timeline-transport)
from baseline `49f9ff9cd1ba0f56f564c0d133bcc10fa4a2475e`.
The [planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary),
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[ADR 0006](../adr/0006-native-demonstration-performance-is-target-specific.md)
remain unchanged. Flutter remains the production state and rendering owner.
`RUST_CORE` remains default-off. No app routes, fixtures, locks or build rules change.

The transport reuses the existing core owners:

- [Parameter timelines](RUST-M2-PARAM-TIMELINE.md) validate complete typed targets,
  interpolate each explicit callback, and own replacement/cancellation rules.
- [Morph timelines](RUST-M2-MORPH-TIMELINE.md) own independent generations and
  cubic progress. Module selection has an explicit animation override. Same-module,
  nonanimated selection/load and reset do not acquire blanket morph cancellation.
- [Seeded randomization](RUST-M2-RANDOM-STATE.md) owns the signed-i64 VM algorithm,
  exact typed targets and successful-only, single-entry wall undo.
  The new `Session::start_seeded_param_timeline` calls `general_targets` with
  `SeededRandom`, then delegates to `start_param_timeline`. There is no second
  random algorithm or Dart target/interpolation math.

## Public seam

[`api.rs`](../../rust/crates/fractal-bridge/src/api.rs) exposes normal-mode FRB
methods on the same `StateSession` mutex:

- `start_param_timeline` and `start_seeded_param_timeline` return a
  `StateParamTimelineStart`. Its read-only getters return a Session-bound opaque
  token and detached snapshot captured under one lock. Numeric target spelling
  stays distinct from text. Non-finite float targets reject without publication.
- Parameter and morph tick/cancel methods borrow opaque tokens. There is no
  caller numeric constructor. Core retains identity, revision, stale-generation,
  idempotent completion and shutdown rules.
- `apply_batch_with_module_animation` delegates the explicit animation option.
  Existing `apply_batch` retains source defaults.
- `randomize_params` delegates immediate ordinary seeded randomization.
  `undo_number_wall_randomization` returns changed/snapshot under one lock.
  Snapshot getters expose undo availability, morph progress, previous module ID,
  `is_morphing` and the optional opaque morph token. Retained values are detached
  from subsequent ticks and Session shutdown.

The bridge adds no clock, timer, entropy or executor. Source scheduling remains
36 callbacks at integer 16-ms intervals. Rust consumes one explicit callback per
tick. This is a logical scheduling model, **not a measured 600-ms duration**.
Deferred wall publication retains the current morph progress through the existing
core publication owner.

## Verification and generated inventory

The pinned preflight used Flutter 3.47.9/Dart 3.13.7, Rust 1.95.0,
FRB runtime/Dart/codegen 2.13.0 and cargo-expand 1.0.127. Python 3.12.3 imported
pytest 9.0.2, Jinja2 3.1.6 and callable `markupsafe.soft_str`.
`flutter pub get --offline --enforce-lockfile` preserved both lockfiles.

Two complete codegen runs produced the same five SHA-256 values:

| Generated file | SHA-256 |
| --- | --- |
| `rust/crates/fractal-bridge/src/frb_generated.rs` | `8ae8c4276f5690ecacc22cff91452ae18446ce6d5e37d54e452b0fd87939616c` |
| `packages/fractal_engine_bridge/lib/src/rust/api.dart` | `7c95604b41bd2d2412f612737a27e565fac527151aff84009b7e388ed74391d8` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.dart` | `167ac8f31981abf894b58a4a8bd2d48107381f1611e16077fe4533cc7fc4b608` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.io.dart` | `0ae8ed973d9b45b7fa8cccfbbc6bc1b0c155d5aa6608de3828b4a5ee00f327b4` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.web.dart` | `485a77f04178e2578080771647ae61286b45356579370cc755f30f911fb85b46` |

Generated-source readback shows normal dispatch for mutations, borrowed token
codecs, signed-i64 seed transport and read-only result getters. Generated bodies
were not edited by hand.

The focused Rust checks cover the new `state_timelines` bridge cases and existing
`state_session`, `state_number_wall`, `state_work_executor`, `session_param_timeline`,
`session_morph_timeline`, `session_randomization` and `session_replay` tests.
The new bridge cases compare all 36 parameter/morph callbacks with core, replacement,
foreign/stale/idempotent behavior, explicit animation, typed target rejection,
unchanged unavailable undo and retained metadata after shutdown. The extended
randomization case compares seeded animation completion against every admitted
ordinary module's source-bound immediate oracle. Existing composed tests retain
hidden-owner rejection/overflow checks, deferred wall morph preservation,
successful-only undo and all 68 replay outputs.

Executed checks on this candidate:

| Check | Result |
| --- | --- |
| Named bridge timeline/session/wall/executor tests | Pass |
| Named core parameter/morph/randomization/replay tests | Pass |
| `scripts/ci/rust-check.sh` | Formatting, denied-warning clippy and 125 tests pass; no ignored tests |
| Bridge Dart analysis and four named Flutter test files | No analyzer issues; 11 tests pass |
| Smoke launcher Python tests | 12 tests pass |
| Trajectory Linux / Android-x64 APK builds | Both compile; 6952/32768 encoded input bytes |
| Extended-u64 Linux / Android-x64 APK builds | Both compile; 12288/32768 encoded input bytes |
| Complete five-file generation repeated twice | Equal hashes, as listed above |
| Root Web builds with `RUST_CORE=false` and `true` | Both compile |

Both Web builds report the FRB 2.13.0 `invalid_runtime_check_with_js_interop_types`
WASM dry-run warning. The successful JavaScript builds do not qualify WASM.

The full offline integration check belongs to the merged-tree runner gate.
The scoped component-note readback checks links, anchors, generated hashes,
public method names and qualification limits. Shared planning/history/task-store
files are unchanged; their closeout remains coordinator-owned.

## Remaining proof

These are source-derived and Rust differential checks, not installed app evidence.
The existing trajectory/u64 Linux and Android-x64 smoke targets are compile-only
checks. Neither their native assertions nor new Dart timeline calls are executed
by compilation. Root Web builds do not qualify Rust WASM or browser behavior.

Staged scheduled wall randomization remains unavailable. The bridge does not expose
the diagnostic core randomization begin/drain as a scheduled operation. Non-skipped
Dart morph, unsupported module branches, installed app behavior, external tick
scheduling and hardware timing remain unqualified. The original exact-value,
last-good, replay, native installation and M2 migration gates remain in force.
No device execution, owner switch, flag enablement or full-M2 claim is included.
