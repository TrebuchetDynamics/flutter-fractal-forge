# RUST-M2-PHYSICAL — Pure physical camera math

## Scope and status

Implemented locally for coordinator review and integration. This exports an inert
`fractal_core::physical_view` kernel, not a physical-input Session transaction or
an app owner switch. The [accepted kernel design](RUST-PLAN-06.md#physical-camera-kernel),
[normative boundary](../engineering/spec.md#planned-rust-engine-boundary) and
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) remain unchanged.

The port follows the equations in
[`gesture_handler.dart`](../../lib/features/renderer/widgets/renderer/input/gesture_handler.dart),
[`pan_momentum.dart`](../../lib/features/renderer/widgets/renderer/input/pan_momentum.dart),
[`zoom_momentum.dart`](../../lib/features/renderer/widgets/renderer/input/zoom_momentum.dart)
and [`gesture_view_bounds.dart`](../../lib/features/renderer/widgets/renderer/input/gesture_view_bounds.dart).
Those Dart owners and their assertions are unchanged.

## API and numerical contract

The [module](../../rust/crates/fractal-core/src/physical_view.rs) is exported from
[`lib.rs`](../../rust/crates/fractal-core/src/lib.rs). It reuses catalog `Dimension`
and the existing [normalization API](RUST-M2-NORMALIZATION.md#public-api).
Viewport arrays are `[width, height]`. Points and deltas use local pixel coordinates.
Rotations are `[x, y, z]` in radians. Geometry functions expect ordinary finite
inputs and usable current/start views, as selected by the input owner.

| Public operation | Contract |
|---|---|
| `screen_delta_to_world(delta, viewport, zoom)` | Pixel delta divided by `max(1, min(width, height))`, then `max(1e-9, zoom)`. Stored 2D rotZ does not rotate screen mapping. |
| `drag_2d(current, delta, viewport)` | Subtract that world delta from current pan, then apply soft pan bands. Other view fields stay unchanged. |
| `camera_target_delta(delta, viewport, zoom, rotation)` | Return XY target displacement from the shader camera-right/up columns. Right motion uses negative pixel x, up motion uses positive pixel y. Scale is `6 / (max(1, height) * max(zoom, 0.1))`. |
| `orbit(current, delta, viewport, horizontal_orbit_sign, rotation_locked)` | Add pitch `-dy * pi / max(1, height)` and yaw `sign * dx * pi / max(1, width)`. Clamp pitch to `±67.5*pi/180`. Gesture lock returns current unchanged. |
| `wheel_zoom_target(current_zoom, scroll_dy)` | Return the unbounded target `current_zoom * exp(-scroll_dy * 0.001)`. Compose with `focal_zoom` and hard normalization. |
| `focal_zoom(current, target_zoom, dimension, viewport, focal)` | Soft-band zoom and keep the focal world point fixed. 2D screen rotation is zero; 3D uses current rotZ. Missing optional viewport or focal leaves pan unchanged. |
| `double_tap_target(current, dimension, viewport, focal)` | Clamp `current.zoom * 2` to default hard zoom bounds before focal endpoint math. This returns an endpoint, not an animation. |
| `pinch(start, current, dimension, gesture)` | Return an anchored pan/zoom candidate for a known viewport. `Pinch` supplies viewport, start/current focal points, scale, caller-selected intentional rotation delta and gesture lock. |
| `advance_pan(velocity, elapsed_us)` | Return `PanStep { displacement, velocity }` for a signed microsecond interval and pixel velocity per reference frame. |
| `advance_zoom(velocity, elapsed_us)` | Return `ZoomStep { log_zoom_delta, velocity }` for the source logarithmic zoom velocity and a signed microsecond interval. |

Pinch zoom uses `start.zoom * scale`. In 2D, the start world point remains under
the current focal point. Stored z rotation becomes start z plus intentional twist,
or start z when locked; the screen mapping still uses zero rotation. In 3D, pan
uses start pan/zoom and current camera axes. With a known viewport, pinch does not
change 3D rotation. Lock does not disable pan or zoom. Direct rotation commands
still use existing normalization, without the gesture tilt cap or lock.

Raw candidates retain strength-0.5 soft bands at default zoom bounds and pan
`[-3, 3]`. Callers must then use `normalize_view(candidate, current, module_id)`.
This preserves hard bounds, including the higher `cantor_set` minimum zoom `0.2`.
The kernel does not relax navigation bounds or create an unchecked `FiniteView`.

Momentum uses 16000-us reference frames and integrates fractional geometric decay
up to the exact speed cutoff. Pan retains `0.95` with cutoff `0.1`; zoom retains
`0.92` with cutoff `0.0001` and travel factor `0.016`. Active velocities do not
move or decay for zero/negative elapsed time. Rest/sub-threshold inputs stop first.
Nonfinite zoom velocity stops without travel. No additional nonfinite pan-velocity
contract is claimed.

## Checks

Setup used the existing isolated Flutter 3.47.9/Dart 3.13.7 and Rust 1.95.0.
Flutter matched `fdroid/flutter.version`. `/usr/bin/python3` 3.12.3 imported pytest
9.0.2, Jinja2 3.1.6 and callable `markupsafe.soft_str`.
`flutter pub get --offline --enforce-lockfile` regenerated checkout-local package
metadata. Both lockfiles retained their original bytes. Rust used
`CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"`; scratch output used private `TMPDIR`.

| Check | Result |
|---|---|
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test physical_view --test normalization --locked --offline` with pinned Rust/cache | Passed: 11 physical kernel tests and five existing normalization tests. |
| `autowork-run timeout 1500 scripts/ci/rust-check.sh` with pinned Rust/cache | Passed: formatting, denied-warning clippy, workspace tests and doc tests, including the platform-dependency guard. |
| `autowork-run timeout 1500 flutter test --no-pub test/renderer/pan_momentum_test.dart test/renderer/zoom_momentum_test.dart test/features/renderer/widgets/renderer/input/gesture_view_bounds_test.dart test/fractal/fractal_renderer_gesture_test.dart` with pinned Flutter/cache | Passed: all 44 unchanged Dart tests. |
| `git diff --exit-code -- lib migration/baseline packages/fractal_engine_bridge rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check` | Passed: reference owners, baseline, bridge and lockfiles unchanged; no whitespace errors. |
| Scoped Docs Sync Maintain readback and local link/anchor check | Passed: documented exports, equations, signs, bounds, ownership gaps and referenced paths checked against source/tests. Repeat readback required no further edits. |

The [public Rust tests](../../rust/crates/fractal-core/tests/physical_view.rs)
cover ordinary finite transforms within absolute `1e-12`, source zoom floors,
module orbit signs, tilt cap, lock behavior and composition with hard bounds.
Momentum retains source one-step tolerances (pan `1e-10`, zoom `1e-12`) and schedule
tolerances (pan `1e-8`, zoom `1e-12`) at cadences 8333/16667/33333/100000 us and
totals 320000/1280000/2000000 us. Tests include exact cutoff travel, both zoom
directions, nonpositive elapsed time and nonfinite zoom velocity.
The merged-tree full offline gate belongs to the runner and was not run here.

## Reuse, omissions and remaining ownership

This change reuses `ViewInput`, catalog `Dimension`, normalization constants and
clamp semantics. It uses only the standard library and existing workspace. No
manifest, dependency, lockfile, generated output, persistence/schema, fixture copy,
keyboard dispatch, bridge route or application consumer changes are needed.

The scoped Docs Sync Maintain pass creates this designated API/result/gap note.
The spec and ADR remain unchanged and valid for an inert kernel. There is no
`docs/roles.json`; generic Docs Sync checks therefore provide no link coverage.
Scoped links and anchors were checked separately. Shared task records and release
history remain coordinator-owned.

Flutter still owns physical event capture, recognition thresholds, raw-pointer
anchor selection, pinch-to-pan handoff, velocity history, fling decisions, boundary
velocity damping, animation interpolation, timers and delayed interaction completion.
The pinch kernel requires a known viewport. Missing-layout gesture fallback and
recognizer decisions remain with the original Dart owner, not a new Rust state
machine. The optional focal rotation override in the private Dart helper has no
current callers; no separate unused override API was added.
A later full ordered Session physical-input transaction port must compose these
operations without changing event ownership. No native renderer, device/browser,
hardware-GPU, latency or 60/120-Hz performance qualification is established here.
