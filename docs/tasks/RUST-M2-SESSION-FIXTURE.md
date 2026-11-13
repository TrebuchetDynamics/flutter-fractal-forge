# Whole-session native fixture: compile-only result

## Boundary

The inert target is
[`rust_state_whole_session_smoke_test.dart`](../../integration_test/migration/rust_state_whole_session_smoke_test.dart).
Its native assertions are **unexecuted**. Linux and Android-x64 compilation is not
installed transport, scheduler latency, full-M2, browser or hardware qualification.
No device was installed, launched or changed by this task.

This implements the [compile-only plan](RUST-PLAN-10.md#compile-only-native-fixture)
and reuses the [existing adapter](RUST-M2-SESSION-ADAPTER.md), generated physical/
timeline APIs and shared work service. The
[engine boundary](../engineering/spec.md#planned-rust-engine-boundary),
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[ADR 0006](../adr/0006-native-demonstration-performance-is-target-specific.md)
remain unchanged. No domain math, timer, production input route, renderer, store,
owner switch, module admission, dependency or generated binding was added.
Original replay, exact-value, last-good and default-off gates remain in force.

## Launcher and assertions

Use the existing
[`run_state_session_smoke.py`](../../scripts/migration/run_state_session_smoke.py)
with `--session -- COMMAND ARGS...`. This fourth mode is mutually exclusive with
`--extended` and `--trajectory`; the default remains the original four-module mode.
The new projection includes complete records for exactly mandelbrot, julia,
cantor_set, recursive_sine_sphere, kaleidoscope_basic, kaleidoscope_fractal,
number_wall, thomas_attractor, four_wing and lorenz_2d. Original record order and
numeric token spelling are retained. Existing original SHA-256 checks, old mode
outputs/hashes, define-override refusal and the actual Flutter-encoded aggregate
limit of 32768 bytes are preserved. No input is truncated or copied into a catalog.

Actual projection identities pinned by the new target:

| Envelope | Bytes | Projected SHA-256 |
| --- | ---: | --- |
| modules | 4850 | `8176789bab9eeb2459bf2be0f60cc70318f3b33a7e2edaed66083b5fee147b39` |
| parameters | 34764 | `6317622c1a5b517ea9acac7f0056aa3277e2942d34161bd03d9571276040c2b0` |
| presets | 14783 | `972583d9991f557edc0ac362e74da73368f8109651cce700fb308b4d466754a3` |
| capabilities | 19405 | `51b302655322d01383d378caf384977512eaff514bdc72fea3b22020f8490530` |

The encoded aggregate is **14224/32768 bytes** with `RUST_CORE=true` for both
native builds (14203 bytes without that extra define). The launcher tests compare
complete token-preserving records and provenance, pin all old projections through
the unchanged original targets, and reject missing, duplicate, tampered and
conflicting inputs before launch.

One native test exercises raw wheel/drag/pump, unsupported rejection and last-good
retention; seeded parameter token replacement/ticks independent of morph progress;
morph replacement/completion; typed load, effects and immutable checkpoints;
scheduled prime/composite wall results, wall/trajectory cancellation and trajectory
terminal frames; post-close read retention; and fixed native BigInt outputs above
2^53 through u64::MAX. Wall module selection itself uses the service, not an
ordinary batch bypass. Polling has a 30-second deadline, 5-second per-read timeout
and operation/phase/error/checkpoint diagnostics. Cancellation invalidates adapter
poll admission; it does not claim that a race with completed work always wins.

The adapter owns its Session, timeline handles and tickets. Its native backend
releases temporary generated handles. Fixture teardown closes the adapter before
its composition-owned service, and disposes the neutral engine, direct counter
Session and all retained counter snapshots. The direct Session is used only for
the existing fixed-u64 diagnostic seam, not as a scheduled-work bypass.

## Source, tools and build identities

Source base: `0330ef6e3c43cc7c6b69604bb441aa6f05fdbea0`. This task changes only
the launcher, its tests, the new target and this note. Unchanged Git tree objects:

- Generated `packages/fractal_engine_bridge/lib/src/rust`:
  `7253fd393e6153e84942a4201ac31ce1c5a796e4`.
- Native `rust`: `76e897167d12fcfe9e788cac5d4007e5ed4acc24`.

SHA-256 of the compiled target is
`437d510be42ba7de4e030325db94b06acaffd5e20ee564dcacc6efedb36b11d7`;
the launcher is `0d3004190acfd0009a25d0888d6e9e698d8be52745ab562f73379241f049d058`.
The original four input identities remain in the launcher's `ORIGINAL_SHA256` map;
each build verified them before projecting. Protected paths and lockfiles passed
an unchanged-diff check against the source base.

Checks used the existing pinned cache, with offline lock-enforced Pub resolution:
Flutter 3.47.9 (`c197ca5199`), Dart 3.13.7, Rust 1.95.0
(`59807616e`), FRB runtime/codegen 2.13.0 and cargo-expand 1.0.127.
Python was `/usr/bin/python3` 3.12.3 with pytest 9.0.2/Jinja2 3.1.6 and callable
`markupsafe.soft_str`. No ambient SDK fallback or installation was used.

| Check | Result |
| --- | --- |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass: 14 cases. |
| `flutter analyze --no-pub integration_test/migration/rust_state_whole_session_smoke_test.dart lib/core/services/engine` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_state_session_adapter_test.dart test/migration/rust_engine_adapter_test.dart` | Pass: 11 tests. |
| `--session -- flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_whole_session_smoke_test.dart` | Pass: compiled only. |
| Same launcher with `flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_whole_session_smoke_test.dart` | Pass with cached target-enabled `RUSTC`: compiled only. |
| `flutter build web --debug --no-pub --dart-define=RUST_CORE=false` and `RUST_CORE=true` | Both pass; existing FRB Wasm dry-run warning remains. These are JavaScript builds, not browser execution or Wasm proof. |
| Protected-path diff and `git diff --check` | Pass. |
| Scoped Docs Sync Maintain readback | Pass: local links/anchors, target/launcher and artifact hashes, explicit unexecuted boundary and repeat-read byte stability. `docs.py stale/check` report no role manifest; no shared task/history files changed. |

Artifact SHA-256 (local compile outputs, not loaded-library evidence):

| Artifact | SHA-256 |
| --- | --- |
| `build/linux/x64/debug/bundle/flutter_fractals` | `2811fce1e8b5e9a90d68ed3e699c914fd7e781e2d013ce18543137617d2e3218` |
| Linux bundle `lib/libfractal_bridge.so` | `90cda52022d36ae36a07a2214c5921dd59ec77c4085d5f0fb2d14eae63385377` |
| `build/app/outputs/flutter-apk/app-debug.apk` | `3bf28fcac0f7103d24729a8f7a53e71f194c85ca92d19f96220398550a6efaf1` |
| APK `lib/x86_64/libfractal_bridge.so` | `0d40510d199921e9188e0be31d481ff1cdd6d463b1b490387a965928df2c530f` |

This retry reuses the earlier scoped fixture implementation, with all checks above
rerun in `autowork-RUST-M2-SESSION-FIXTURE-r2`. Artifact hashes above identify
this checkout's fresh builds, not the earlier attempt's outputs. The existing
launcher, adapter, service and fixed-counter seam are reused; no second launcher,
new kernels or production routing were needed.

Full check: runner gate.

## Pending official execution

Separate current-source official Linux and standing Waydroid runs must execute
this target using `--session`, the existing integrationDriver terminal-receipt
mechanism, current assigned ports/TMPDIR and a finite run timeout. Bind the exact
source, four input/projection identities, generated tree, tool/build identities,
artifact hashes, mapped library path/hash, nonrendering backend, terminal test
result and cleanup. The target prints the actual mapped Rust library hash and
`rendering=false`; compile output above does not substitute for that readback.

For Android, follow the
[standing Waydroid transport and consent contract](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target):
revalidate serial/model/boot and working `get-state`, use matching
`ANDROID_DEVICE`/`ANDROID_DISPOSABLE_DEVICE`, coordinate device contention and
retain app/process/handle cleanup evidence. Do not reset the container or infer
new device/publication authority. Waydroid remains container functional evidence.

All [remaining proof](RUST-PLAN-10.md#remaining-proof-and-continuation) is retained.
No scheduler-latency, full-M2, browser, hardware-GPU or performance gate is closed.
