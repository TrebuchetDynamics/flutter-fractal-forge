# RUST-M2-PHYSICAL-ORACLE — Ordered physical input observations

## Scope and status

The [oracle](../../migration/oracles/physical-events.json) captures production
Flutter input handling for a future ordered Rust Session transaction owner.
It is a local candidate for coordinator integration, not an app routing change.
The [accepted design](RUST-PLAN-08.md#physical-event-oracle),
[engine boundary](../engineering/spec.md#planned-rust-engine-boundary) and
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) remain unchanged.
The existing [Rust physical kernel](RUST-M2-PHYSICAL.md) is numerical-only.
This task adds no Rust event owner.

## Clock seam and producer

[`FractalRenderer.gestureClock`](../../lib/features/renderer/widgets/renderer/fractal_renderer.dart)
is an optional constructor argument with `DateTime.now` as its default.
The five gesture wall-time reads use it: velocity fallback, duplicate suppression,
two-finger start, two-finger elapsed time and raw double-tap time.
`ScaleUpdateDetails.sourceTimeStamp` still takes precedence, including zero.
Animation controllers still use elapsed pump time. Palette transitions and GPU
frame metrics retain their independent `DateTime.now` reads.
No threshold, recognizer, callback policy, camera math or production route changed.

The [focused test](../../test/migration/physical_events_oracle_test.dart) executes
[the producer](../../test/migration/support/physical_events_oracle.dart) twice.
Raw pointer and wheel events enter Flutter through `sendEventToBinding`.
No scale callbacks are substituted as physical inputs. The separate clock-seam
case invokes scale callbacks only to check missing-source-time fallback.
It also checks the omitted clock against the real current wall time, without sleeps.

The renderer uses the existing lightweight `overrideChild` harness and a 300×240
viewport. A nested horizontal control participates in the real gesture arena.
A nested Focus control consumes key down/repeat/up without camera movement.
For viewer keys, the harness mounts the real viewer, obtains its existing Focus
callback, and retains its state offstage with focus excluded. It routes keys
through that callback in a minimal nested Focus tree. It records the viewer's
Explore/Walk mode explicitly. Gaussian Walk observations prove outer-handler
suppression, not the excluded walk widget's own key consumption. Existing viewer
and HUD regressions remain separate guards for full widget routing.

## Contract and coverage

Schema 1 has runtime metadata, `source_bindings` and 67 scenarios. Each scenario
contains an ID, initial state, ordered `input` and `expected` checkpoints.

- Initial state includes module, parameters, camera, effects and viewport.
  Renderer cases also record initial focus/control value, animation flag and clocks.
- `seq` is zero-based within each scenario. Pointer events record ID, device kind,
  buttons, local pixels and `sourceUs`. Wheel events record kind, buttons, delta,
  focal pixels and source time. Dispatched kind/buttons are checked against input.
- `wall.us` sets logical wall microseconds since `2026-01-01T00:00:00Z`.
  `pump.us` advances Flutter animation/recognizer time by a separate duration.
  Pointer source microseconds are independent of both. Simulated key source time
  is zero, as supplied by Flutter's pinned key simulator.
- Focus, key down/repeat/up, module selection and disposal are explicit actions.
  Checkpoints record their input sequence, camera, all parameters (including
  adaptive iterations), effects, ordered start/end/correction callbacks, nested
  control values, routed key results, clock-read count and disposal status.

Coverage includes drag/fling at 8333/16667/33333/100000-us pump cadences, last-five
velocity samples, the 5-pixel/reference-frame admission boundary, 2D pan bounds,
3D orbit signs/tilt bounds, pinch, handoff, pinch inertia, rotation lock, wheel
focal zoom, hard zoom limits and Cantor's 0.2 minimum. Cadence comparisons retain
`1e-8` tolerance. The source graph retains the existing momentum constants:
16000-us reference frames, 0.95/0.92 retention, 0.1/0.0001 cutoffs, two-second
flings, zoom admission above 0.01 and strength-0.5 soft bands.

Twist cases use 0.119999/0.12/0.120001 radians. Two-finger cases cross
219/220/221 ms and 17.999/18/18.001 pixels, with stationary cases too.
Raw double-tap cases cross 279/280/281 ms and 27.999/28/28.001 pixels.
Duplicate suppression crosses 119/120/121 ms. The wall clock and Flutter pumps
are deliberately independent, so raw fallback and recognizer paths stay distinct.

The fixture preserves an existing observation: admitted two-finger taps in these
sequences have an extra start callback, then the recognizer's one-finger handoff
stops their zoom animation. Their final zoom remains unchanged. Rejected neighbors
lack that extra start. This is source behavior, not a new tap policy or proof that
every physical device has that result.

Cancel, replacement input, module change and disposal cover momentum ownership.
Replacement/module/disposal also interrupt double-tap interpolation. Settled and
later checkpoints freeze exactly-once completion and prevent abandoned owners
from completing a replacement interaction. Viewer cases preserve rotated keyboard
pan, arrow/zoom/reset mappings, ignored repeats/up events and Gaussian precedence.

## Provenance and scratch export

The 303 SHA-256 bindings include the complete transitive local import/export/part
graph rooted at renderer, viewer and producer/test, plus the lockfile and SDK pin.
They explicitly include gesture helpers, controller, viewer interactions and HUD.
Selected Flutter gesture, focus, keyboard, animation and test-simulator sources
are also bound. This is not a claim to bind the full Flutter SDK dependency graph.
No machine paths or capture timestamps are stored in the document.

Normal runs compare the whole immutable fixture, reject source-hash and nested
camera expectation mutations, and verify that fixture bytes never change.
Only an explicit define enables scratch export:

```sh
flutter test --no-pub test/migration/physical_events_oracle_test.dart --dart-define=MIGRATION_PHYSICAL_EVENTS_OUT="$TMPDIR/physical-a"
flutter test --no-pub test/migration/physical_events_oracle_test.dart --dart-define=MIGRATION_PHYSICAL_EVENTS_OUT="$TMPDIR/physical-b"
diff -ru "$TMPDIR/physical-a" "$TMPDIR/physical-b"
```

Use the pinned offline Flutter/PUB_CACHE setup from root `AGENTS.md`, with a private
`TMPDIR`. Output must be absolute, empty and inside that scratch root. On Linux,
the scratch root must have no group/other permissions. Relative paths, parent
traversal, checkout destinations, resolved checkout symlinks and nonempty output
are rejected. Traversal is checked before directory creation. Negative tests verify
that refusal creates neither the missing prefix nor a checkout directory.
Export bypasses only the committed-fixture comparison, not double execution or
behavior/mutation checks. Review source hashes and outcomes before a separate
explicit promotion. Tests never promote output or refresh M0 fixtures.

## Retained reference provenance recovery

This candidate continues `268764f9e00889c7071a24ff6bc8870708c121c4`.
Its clock-only production diff and physical scenario inputs/outcomes are unchanged.
On this attempt's baseline, four physical-oracle source hashes changed in existing
history storage, viewer and sheet sources. Two fresh private captures agree with
each other and the retained candidate's complete document except those bindings.

The held `203a53ef675d1544cc42a95beb3eba176e55d12b` integration failed the
physical-oracle comparison after `UI-OVERLAY-SHELL-INSETS-02` landed in baseline
`38d61d5156b47cd03a384c985c2531c7370b0225`. Its transitive viewer graph still
bound the previous `app_bottom_sheet.dart` bytes. This retry changes only that
binding relative to the held candidate: private recaptures match all 67 raw-event
sequences, expected checkpoints, runtime metadata and other 302 source bindings.
The normal immutable comparison and mutation checks remain unchanged. No source
binding is removed or ignored; future graph drift still fails the comparison.

The clock seam changed sources bound by the historical reference renders.
The reproduced `reference_render_test` setup failed on source-map equality, then
teardown failed because setup captured no records. The recovery preserves every
original file in `migration/baseline`, including both reference manifests/images.
It does not regenerate the historical baseline or remove source bindings.

The new [source-transition sidecar](../../migration/oracles/reference-source-transitions.json)
contains the complete 725-entry before map, complete 726-entry after map and
SHA-256 hashes for all 31 original baseline files. The
[transition guard](../../test/migration/support/reference_source_transition.dart)
requires exact equality with both retained manifests, the actual current source
map and the actual fixture inventory. An independent hardcoded digest anchors
the whole fixture inventory, so sidecar edits cannot bless replacement images.
The only changed source paths allowed are renderer, gesture handler and
`reference_capture.dart`. The only added path allowed is the transition helper.
Removed bindings or unrelated source changes fail, even with a matching sidecar.

The [reference capture helper](../../test/migration/support/reference_capture.dart)
keeps its input, backend, toolchain, shader, image-health and historical
capture-to-capture checks. It additionally requires actual current renders to
match retained same-backend pixels and image/metadata hashes exactly.
All 11 current renders produced zero changed pixels. This is offline software
backend evidence, not hardware or cross-backend image parity.

The [focused transition test](../../test/migration/reference_source_transition_test.dart)
rejects changed/added/removed bindings in both maps, unrelated runtime drift,
manifest/image/M0 hash mutations, coordinated fixture/sidecar edits and transition
metadata mutation. It verifies unchanged sidecar and original fixture bytes.
Two independently generated private sidecar copies also agree byte-for-byte.
The sidecar is reviewed provenance, not a general drift waiver or an automatic
fixture update route. Normal reference and physical checks never rewrite it.

## Checks and limits

Flutter 3.47.9/Dart 3.13.7 matched `fdroid/flutter.version`. The prescribed
`/usr/bin/python3` imports and offline lockfile-enforced package resolution passed.

| Check | Result |
|---|---|
| Task-scoped `flutter analyze --no-pub` for both production files and both new Dart files | Passed, no issues. |
| `flutter test --no-pub test/migration/physical_events_oracle_test.dart` | Passed, two tests including two complete oracle executions and exact committed-fixture comparison. |
| Two scratch exports above and their directory diff | Passed, byte-identical output, with unchanged retained physical inputs/outcomes. |
| `flutter analyze --no-pub test/migration/reference_render_test.dart test/migration/support/reference_capture.dart test/migration/reference_source_transition_test.dart test/migration/support/reference_source_transition.dart` | Passed, no issues. |
| `autowork-run timeout 900 flutter test --no-pub test/migration/reference_source_transition_test.dart test/migration/reference_render_test.dart` | Passed, all 13 tests including 11 actual renders with zero pixel differences. |
| Private sidecar generation twice and directory diff | Passed, byte-identical complete maps and immutable fixture hashes. |
| Existing renderer gesture, controls HUD, viewer widget, tap-classification, pan-momentum and zoom-momentum tests | Passed, all 268 tests through `autowork-run timeout 900 flutter test --no-pub` with the six task-named paths. |
| Fixture source-binding and sequence inspection | Passed, all 303 hashes matched their files, 67 unique scenario IDs and contiguous input sequences. |
| `git diff --exit-code -- rust packages migration/baseline pubspec.lock && git diff --check` | Passed, excluded owners and lockfile unchanged. |
| Scoped Docs Sync Maintain readback and local link/anchor check | Passed, this note's APIs, counts, commands and observations checked against source, fixture and test output. |

Scoped Maintain updates only this designated component note. The spec and ADR
already separate current Flutter ownership from the future Rust boundary.
There is no `docs/roles.json`; generic Docs Sync checks add no content coverage.
Shared task records and release history remain coordinator-owned.

Reuse includes the production renderer/controller/viewer handlers, existing
Provider/storage test setup, locked hashing dependency and canonical JSON writer.
No dependency, generated bridge, application flag, M0 baseline or Rust changes.
The reference recovery reuses the existing source graph, canonical JSON, real
render readback and metadata checks. No new render harness or baseline capture.
The runner owns the merged-tree full offline gate and independent integration
review. This worker did not run that gate. The historical failed integration
remains unqualified until the runner repeats those checks on the merged tree.
Future Rust Session parity, browser/device routing, hardware rendering and measured
60/120-Hz qualification remain separate work. Offline event observations prove none
of those live or native boundaries.
