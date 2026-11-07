# Burning Ship software-readback prerequisite

## Evidence and contract boundary

RUST-M0-IMAGES attempt 1 was blocked, not completed. Read in place:

- `.git/autowork-execution/slot-history/RUST-M0-IMAGES/1/slot-data/attempt-1/report.json`
  and `contract.txt` in the repository common Git directory. The runner archived
  the original `slot-data/RUST-M0-IMAGES/attempt-1/` evidence there.
- `/var/tmp/aw-1000-48137133-2/burning_ship_readback_test.dart` and
  `burning-ship-isolated.log`: the independent existing catalog draw/readback
  seam produced exactly 65,536 opaque black pixels at 256×256, time zero,
  unmodified `burning_ship` defaults. It did not use the candidate capture helper.
- The report records ten other reference states and seven existing catalog
  health cases passing, Burning Ship image health failing, and no complete
  manifest, artifact promotion or commit. The full gate and two completed
  reference captures were not delivered.

Reported source revision: `8345b8e2e296211c2d596eaeb4e451793e16d742`.
Reported registered shader SHA-256:
`3056d5a7b226ae13f049a8da9c6f49c073a2589a85b25ff212904f44ba8db7a3`.
The worker's pinned environment preflight and focused analysis passed; those
results are not a renderer or full-gate pass. Scratch paths are historical local
evidence, not portable artifacts or required coordinator receipts.

Sources: [accepted migration invariant and baseline](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration),
[rendering interface](../engineering/spec.md#rendering-interface), and
[failure behavior](../engineering/spec.md#failure-behavior).
The accepted baseline names this actual module/default; substitution or accepting
black output would hide a failure. A pre-existing implementation defect can be
repaired without changing the intended formula or introducing a new product.
Keep that repair in RUST-M0-SHIP-REPAIR, not in the capture task, whose original
Scope, Acceptance, Checks, Touches and production-change prohibition stay intact.
RUST-M0-IMAGES consumes the repaired renderer and refreshed source-bound inventory;
its added dependency is a real producer prerequisite, not overlap scheduling.

## Bounded implementation approach

1. Reproduce the reported failure with a new standalone
   `test/modules/burning_ship_default_render_health_test.dart`, using the real
   registry descriptor, registered FragmentProgram, uniform setter and existing
   catalog readback seam. Keep the shader alive through readback. Retain exact
   command, source, backend, dimensions, state, alpha and pixel-health evidence.
   No dependency on the unfinished image harness or its uncommitted files.
2. Diagnose the registered
   `shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag`.
   Source inspection identifies `z = vec2(0.0)` followed by `cpowReal(abs(z), power)`;
   `cpowReal` clamps radius but still evaluates `atan(z.y, z.x)` at the origin.
   Undefined zero-angle evaluation is a hypothesis, not an established root cause.
   Confirm or reject it experimentally before editing. If confirmed, use the
   smallest mathematically equivalent zero/power handling, accounting for the
   derivative's `power - 1.0` exponent as well as the ordinary recurrence.
   Preserve nonzero behavior, fractional/integer power semantics, palette modes,
   pan orientation, default values, uniform ABI and module identity. No alternate
   shader, CPU fallback, changed view or backend substitution.
3. Require failing-before/passing-after real default readback and an independent
   recurrence/classification check at selected interior and escaping samples.
   Include representative integer/fractional powers and normal-map mode so a
   default-only shortcut cannot disable existing controls. Keep classification
   checks separate from palette equality and from mathematical qualification.
   Run existing pan, consolidation, degree and CPU regressions unchanged.
4. A shader edit changes hashes in all five baseline inventory documents:
   `modules.json`, `parameters.json`, `presets.json`, `capabilities.json`, and
   `shader-contracts.json`. Use the existing MIGRATION_BASELINE_OUT exporter twice
   into private empty scratch directories, compare, review the actual source/hash
   diff and explicitly promote. Descriptor/defaults/capability payloads and binding
   layouts must stay unchanged; only justified shader-source/provenance hashes
   change. Do not hand-edit hashes or refresh unrelated replay expectations.
5. Record the actual diagnosis, before/after results and limitations here, run the
   focused commands and unchanged pinned offline gate in the task Checks, and
   preserve pubspec.lock. A missing tool, timeout, SDK-only defect or a repair
   requiring formula/default/ABI changes remains a precise blocker; this contract
   supplies no authority for those changes or SDK/host modification.

## Capture continuation

After the repair lands, RUST-M0-IMAGES must independently rerun all its original
checks, finish both captures and measured variance, and explicitly promote the
complete manifest and PNGs. Preserve the idle uncommitted candidate in
`.worktrees/autowork-RUST-M0-IMAGES`; adopting it requires a fresh activity check.
Do not close either task or qualify RUST-ENGINE-001 from this planning document.
Software readback is not device/browser, hardware-GPU or mathematical acceptance.

## Producer diagnosis and offline evidence

Execution base: `c103e2bb0835508f49e1a72ee40a267d3d39a382`.
The standalone regression reuses the catalog's registered module, uniform setter,
FragmentProgram, Picture and raw-RGBA readback. It keeps the shader alive until
readback and does not use the unfinished capture candidate.

The only production change defines the angle as zero at the exact complex origin.
All nonzero inputs still use the original `atan` expression. The existing
`max(length(z), 1e-12)` and `pow(r, p)` remain unchanged. This also preserves the
regularized derivative call with exponent `power - 1`: exponent zero returns one,
and negative exponents remain finite before multiplication by the zero sign gate.
No early return of zero for every exponent was introduced. The real module clamps
power to `[1, 16]` before setting uniforms, so negative derivative exponents are
not exposed by its controls. No formula, derivative update, palette, pan mapping,
default, uniform slot, module ID, SDK or dependency changed.

### Controlled reproduction

All runs used pinned Flutter tester software rendering, not a CPU replacement or
hardware GPU. Run from the checkout root with:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
flutter test --no-pub test/modules/burning_ship_default_render_health_test.dart --reporter expanded
```

The default is 256×256, time zero, opaque, power 2, 300 iterations, bailout 4,
palette 0, pan `(-0.5, 0)` and zoom `0.35`. The test obtains these settings from
the real default preset, not a replacement state.

| Shader | Terminal result | Default pixel readback |
|---|---|---|
| Original `3056d5a7…ba8db7a3` | FAIL | 65,536 opaque black pixels, one RGB color, nonblack ratio 0, luminance standard deviation 0 |
| Origin-angle guard only | PASS | 1,207 RGB colors, nonblack ratio 0.7862, luminance standard deviation 45.3509, every alpha 255 |
| Original shader restored byte-for-byte | FAIL | Same all-black result; independent escaping sample also incorrectly remained transparent |
| Guard reapplied, final focused run | PASS | Same healthy default metrics; all classification and normal-map samples pass |

This original/guard/original/guard sequence isolates the undefined origin-angle
path. It does not identify a particular internal Skia instruction or certify
other backends. A zero radius alone was not the cause: the original already
clamped it to `1e-12`. Transparency was not the cause: every default alpha was 255.
A normal-map-only derivative defect cannot explain the default failure: scheme 0
never enters that branch. Uniform, default, pan and palette hypotheses do not
require changes: the angle-only intervention repairs the same registered draw.
No SDK upgrade or quadratic-only fast path is needed.

The second test keeps classification separate from color. With 40 steps and
radius 4, independent scalar-complex evaluation of
`z_next = (|Re(z)| + i|Im(z)|)^p + c` classifies `c=0` and `c=(-0.2,-0.1)` as bounded for powers 1, 1.5, 2, 2.5 and 3.
At `c=(-0.8,-0.6)`, powers 1, 1.5 and 2 remain bounded, while 2.5 and 3 escape
at zero-based steps 14 and 5. Transparent-interior readbacks assert those
classifications for both palette and normal-map modes. Additional escaping
samples compare RGB with independent scalar recurrence, abs-sign-gated derivative,
light angle zero, palette zero and sRGB transfer calculations. The table is in
the test, with a two-level tolerance per 8-bit RGB channel, not an image golden.
These selected samples guard controls and shading, not mathematical qualification.

Final shader SHA-256:
`cc27b6f847e8fa2c9f9f6a4c8d309f497f72d1f70d6dfb698c6a2a7c601b3511`.
Final standalone test SHA-256:
`8246ff3f0166e0b4b86ebb127fe921784cbf957271096b85568c3a0fa9559fec`.

### Executed checks and inventory promotion

- Environment preflight: PASS. `flutter --version` matches
  `fdroid/flutter.version` (3.47.9, Dart 3.13.7). `/usr/bin/python3` is 3.12.3,
  imports pytest 9.0.2 and Jinja2 3.1.6, and has callable `markupsafe.soft_str`.
- `flutter pub get --offline --enforce-lockfile`: PASS. Before and after,
  `pubspec.lock` SHA-256 is
  `d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`.
- The following unchanged selection, plus the new regression: PASS, 41 tests.
  The potentially long command ran through `autowork-run timeout 900`.

```sh
flutter test --no-pub \
  test/modules/burning_ship_default_render_health_test.dart \
  test/modules/burning_ship_pan_direction_test.dart \
  test/modules/burning_ship_consolidation_test.dart \
  test/modules/burning_ship_julia_visual_contract_test.dart \
  test/renderer/burning_ship_degree_rendering_test.dart \
  test/cpu/cpu_burning_ship_iterator_test.dart \
  test/shaders/escape_time_family/families/burning_ship_shader_assets_test.dart \
  test/modules/escape_time_uniform_contract_test.dart \
  test/modules/escape_time_shader_manifest_test.dart \
  test/modules/catalog_preset_render_health_test.dart --reporter expanded
```

Two empty, private absolute scratch exports used the unchanged exporter:

```sh
flutter test --no-pub test/migration/baseline_contracts_test.dart --dart-define=MIGRATION_BASELINE_OUT="$TMPDIR/ship-contracts-a" --reporter expanded
flutter test --no-pub test/migration/baseline_contracts_test.dart --dart-define=MIGRATION_BASELINE_OUT="$TMPDIR/ship-contracts-b" --reporter expanded
diff -r "$TMPDIR/ship-contracts-a" "$TMPDIR/ship-contracts-b"
flutter test --no-pub test/migration/baseline_contracts_test.dart test/migration/state_replay_test.dart --reporter expanded
```

Both exports passed (two tests each), and their recursive diff was empty.
Structural review found exactly two changed provenance values in each of the five
JSONs: the registered shader hash and the resulting source-set hash. Every payload,
including descriptors, defaults, capabilities and binding layouts, was equal.
Only then were those five exported files explicitly copied into the baseline.
The default baseline and unchanged state/precision replay checks passed (four tests).
No hashes or replay expectations were hand-edited.

The merged-tree full offline gate belongs to the coordinator under the worker
execution rules. It was not run or claimed here. Reference images, repeat-capture
variance, device/browser, hardware-GPU and mathematical acceptance remain open.
The original RUST-M0-IMAGES candidate and all its acceptance checks are unchanged.
