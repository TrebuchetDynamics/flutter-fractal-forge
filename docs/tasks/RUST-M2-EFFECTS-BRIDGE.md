# RUST-M2-EFFECTS-BRIDGE — Inert typed effect transport

## Scope and API

This result extends [the opaque state bridge](RUST-M2-BRIDGE.md), using the
[decided interfaces](RUST-PLAN-05.md#current-source-and-decided-interfaces).
The baseline is `4453cb62292464561edb7c5b54f9bcbd6700152d`.
It provides Rust boundary and build evidence only. It does not qualify native
execution of the new effects or expand the prior four-module scalar proof.

[`StateCommand`](../../rust/crates/fractal-bridge/src/api.rs) adds eleven
synchronous opaque named constructors. Detached, read-only `StateSnapshot`
handles add matching getters. Each constructor maps directly to its existing
`fractal_core::session::Command` variant; each getter delegates to core.

| Rust constructor/getter | Generated Dart name | Rust / Dart value |
| --- | --- | --- |
| `glow_enabled` | `glowEnabled` | `bool` / `bool` |
| `glow_sigma` | `glowSigma` | `f64` / `double` |
| `glow_intensity` | `glowIntensity` | `f64` / `double` |
| `fluid_mode_enabled` | `fluidModeEnabled` | `bool` / `bool` |
| `fluid_strength` | `fluidStrength` | `f64` / `double` |
| `rotation_locked` | `rotationLocked` | `bool` / `bool` |
| `kaleidoscope_enabled` | `kaleidoscopeEnabled` | `bool` / `bool` |
| `kaleidoscope_sectors` | `kaleidoscopeSectors` | `i64` / `PlatformInt64` |
| `kaleidoscope_mirror` | `kaleidoscopeMirror` | `bool` / `bool` |
| `kaleidoscope_rotation` | `kaleidoscopeRotation` | `f64` / `double` |
| `kaleidoscope_mirror_mode` | `kaleidoscopeMirrorMode` | `i64` / `PlatformInt64` |

Dart constructors are static methods with a required `value` argument. Getters
are zero-argument methods. Generated calls use synchronous FRB transport.
The signed integer codecs use `getPlatformInt64`/`putPlatformInt64` in Dart and
`read_i64`/`write_i64` in Rust. Existing identity/revision fields remain unsigned
`u64` / Dart `BigInt`; no identity or revision setter is added.

Core remains the sole normalization and policy owner. Default ambient effects
are glow disabled, sigma 1.0, intensity 0.35, fluid disabled, strength 1.0 and
rotation unlocked. Ordinary kaleidoscope defaults are disabled, eight sectors,
mirror true, rotation 0.0 and mirror mode zero. Sigma clamps to 0.1–5.0,
intensity to 0.0–1.0, strength to 0.0–2.0, sectors to even values in 4–16 and
mirror mode to 0–3. NaN bounded inputs retain the current value; infinities clamp.
Kaleidoscope rotation accepts only finite inputs and otherwise retains its value.
Rotation lock is gesture policy and does not reject direct rotation commands.

Only `kaleidoscope_basic` and `kaleidoscope_fractal` force enabled/16 sectors/mode 3.
Their first hidden restore state stays private across consecutive forced modules.
An ordinary-module transition restores that state. Resets and presets retain
effects; only session reset clears rotation lock. Load reapplies module policy,
including when no new module ID is supplied. Presets do not select their module.

### Reuse and deliberate omissions

- Reuse the existing opaque synchronous command/snapshot API, session mutex,
  detached core snapshots, ordered atomic batches and lifecycle errors.
- Reuse all four original baseline envelopes and core's source-derived effect
  oracles. Add no copied fixtures, mathematical callbacks, mutable restore DTOs,
  alternate state owner or bridge-side normalization.
- Regenerate all five outputs owned by
  [`flutter_rust_bridge.yaml`](../../flutter_rust_bridge.yaml); no handwritten glue.
  FRB's signed integer codec needs no new dependency.
- Preserve core, dependency manifests/locks, baseline bytes, build rules,
  app/adapter/renderer routing, default-off behavior and `rendering=false`.
  No Number Walls transport, executor, new native fixture or device installation.

## Executed offline checks

Setup used Flutter 3.47.9/Dart 3.13.7, matching `fdroid/flutter.version`, Rust
1.95.0, FRB 2.11.1 and cargo-expand 1.0.127. Existing shared SDK/Pub/Cargo caches
and private `TMPDIR` were reused. Provisioned `/usr/bin/python3` imported pytest,
Jinja2 and MarkupSafe successfully. Root `flutter pub get --offline
--enforce-lockfile` regenerated checkout-local metadata without a lockfile change.
FRB warned that the bridge package has no separate lockfile; its manifest pins
FRB 2.11.1 and the root lock resolves that version. No lockfile was added.

| Check | Result |
| --- | --- |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-bridge --test state_effects --test state_session --locked --offline` | Pass: three new effect tests and four existing state-session tests. |
| `autowork-run scripts/ci/rust-check.sh` | Pass: formatting, denied-warning clippy, 33 workspace tests and doc-test targets. |
| `flutter_rust_bridge_codegen generate --config-file flutter_rust_bridge.yaml`, twice; compare complete SHA-256 inventories | Pass: all five files identical between generations; inventory below. |
| `flutter analyze --no-pub packages/fractal_engine_bridge/lib` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart` | Pass: three tests. |
| `autowork-run timeout --kill-after=10s 900 /usr/bin/python3 scripts/migration/run_state_session_smoke.py -- flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_session_smoke_test.dart` | Pass: linked Linux regression fixture compiled; bundle contains `lib/libfractal_bridge.so`. |
| `RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" autowork-run timeout --kill-after=10s 1200 /usr/bin/python3 scripts/migration/run_state_session_smoke.py -- flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_session_smoke_test.dart` | Pass: APK built and contains `lib/x86_64/libfractal_bridge.so`; not installed. |
| `autowork-run timeout --kill-after=10s 900 flutter build web --debug --no-pub --dart-define=RUST_CORE=false` | Pass. |
| Same Web command with `--dart-define=RUST_CORE=true` | Pass; native loading remains excluded. |
| `git diff --exit-code -- lib migration/baseline integration_test scripts flutter_rust_bridge.yaml rust/Cargo.lock pubspec.lock && git diff --check` | Pass: excluded paths preserved and clean whitespace. |

Rust commands selected `CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0` and the pinned
Rust toolchain on PATH. Android reused the existing target-enabled cached `RUSTC`.
Existing Gradle/AGP/Kotlin and Java source/target-version warnings stayed visible;
no validation bypass was used. Each native fixture build retained the existing
four-module projection and 9704/32768-byte aggregate guard.
The coordinator's merged-tree full gate is separate and was not run by this worker.

### Public Rust boundary evidence

The new [state_effects tests](../../rust/crates/fractal-bridge/tests/state_effects.rs)
initially failed on the absent public methods, then passed after the direct mappings.
They cover defaults for all six supported modules, every new constructor/getter,
boolean toggles, floating bounds/NaN/infinities, signed integer extremes, even
sectors and gesture-only rotation lock. They also cover:

- Ordered multi-command batches publishing exactly once.
- Forced-to-forced-to-ordinary restoration after forced edits.
- Failed candidates that would corrupt hidden restoration if rollback leaked,
  stale revisions, wrong-session rejection and unchanged last-good effects.
- Retained snapshots, independent sessions, duplicate shutdown, post-close
  snapshot/batch errors and retained getters after close.
- Parameter/view/session resets, same-module selection, preset module retention,
  load with absent/present module IDs and restoration after forced load transitions.

### Complete deterministic generated inventory

Both complete generations produced these SHA-256 values:

| Path | SHA-256 |
| --- | --- |
| `rust/crates/fractal-bridge/src/frb_generated.rs` | `e97ae63373d6dbdb59cc7b85398d3f2aa809760d9369b92a9831a080d3191ef0` |
| `packages/fractal_engine_bridge/lib/src/rust/api.dart` | `afe74c4dff51c35be8c20f94a632c2947b8bf7d6039bb60a45ebe318ad03f3d3` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.dart` | `6fbe3e4778371d48e841987f0c6283f0416d93e33a66bb0439b6dda64dfcc8a4` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.io.dart` | `8a654e81d8fe2a454ae72d5bde9e95ae98da191e4b5e5652bf53997790f686aa` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.web.dart` | `3e495ac75a3d18372997320cc0778d44c7d41566e31978bce8c496a111af74e8` |

## Qualification limits and continuation

The old four-module scalar fixture does not call any new effect method. These
builds prove regression linkage/compilation, not new-effects codec execution.
Prior installed Linux/Waydroid scalar results in
[RUST-PLAN-05](RUST-PLAN-05.md#finished-evidence-and-limits) remain unchanged.
A later planner must create a reachable native effects/forced-restoration fixture
before installed round-trip qualification. Reachable high-u64 output transport,
full-session ownership, Number Walls job/executor transport, browser execution
and hardware/GPU/performance proof remain separate work. No runtime proof is
upgraded here; Web builds do not prove browser or WASM execution.

## Scoped documentation maintenance

Docs Sync Maintain is limited to this API/result note. The
[planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary) and
[opt-in native probe](../engineering/spec.md#opt-in-native-engine-probe) were
inspected and remain unchanged: the inert API adds no app integration or policy.
The existing glossary and transport result remain applicable. No task-store,
shared history or role-manifest edits are included.

Scoped readback verifies local links/anchors, all eleven Rust/Dart mappings and
synchronous calls, the full five-file inventory, build logs/artifact presence
and the proof limits above. Bundled `docs.py stale .` and `docs.py check .` exit 0
with `no manifest at docs/roles.json`; this is not repository-wide link coverage.
Repeat readback preserves this note's bytes. The coordinator owns the changelog
proposal, integration and closeout Docs Sync pass.
