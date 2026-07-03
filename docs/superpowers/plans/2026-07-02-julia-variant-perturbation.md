# Julia-Variant Perturbation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the flat-render bug in core Julia GPU perturbation and extend deep-zoom perturbation to ~31 Julia-variant fractals via a julia-mode flag, with zero new shader delta functions.

**Architecture:** A Julia variant of any base formula runs the identical perturbation delta iteration with the `dc` term zeroed and the pixel offset entering through `dz₀` instead; the reference orbit is seeded `z₀ = center` with fixed `c`. One flag uniform (`uExtra2`) switches the existing shader into this mode; one variant table in Dart maps catalog IDs to (base formula, fixed c). The duplicate `julia_perturb_module.dart` is deleted.

**Tech Stack:** Flutter 3.44 / Dart 3, SkSL fragment shaders (no `%` on ints, no `clamp(int,int,int)`), `flutter test`, integration tests on `-d linux` (use `xvfb-run` when headless).

**Spec:** `docs/superpowers/specs/2026-07-02-julia-variant-perturbation-design.md`

**Verified facts this plan relies on** (re-verify only if a step contradicts them):
- Shader `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`: `dz` init `vec2(0.0)` for all formulas (~line 128); `deltaJulia(Zn, dz)` has no `dc` term (~line 54) → formula 1 renders flat (dz ≡ 0). `uExtra2` is currently always sent as 0.0 by both wrapper modules.
- `computeEscapeTimePerturbOrbitBytes` (in `lib/core/modules/escape_time_perturb_module.dart`, landed in commit `fd72b705`) stores Z₀ first and has period detection; `computeJuliaPerturbOrbitBytes` (julia module) stores Z₁ first — off-by-one vs the shader's `fetchOrbit(n) ↔ dz_n` alignment.
- Routing gate: `lib/features/renderer/policy/precision_ladder_policy.dart:293` — `moduleId == 'julia' || kPerturbableEscapeTimeIds.contains(moduleId)`.
- Resolver: `lib/features/renderer/policy/render_plan.dart:47-55` special-cases `'julia'` → `buildJuliaPerturbModule`, else `buildEscapeTimePerturbModule`.
- Fixed-c seeds hardcoded in standalone variant shaders: celtic_julia `(-0.70176, -0.3842)`, buffalo_julia `(-0.45, 0.1428)`, burning_ship_julia `(-0.52, -0.42)` (locked by `test/modules/burning_ship_julia_visual_contract_test.dart`), tricorn_julia `(-0.12, 0.74)`.
- f-series preset julias (`lib/core/modules/builders/shared_catalogs/shared_julia_catalog.dart`) expose `juliaCReal`/`juliaCImag` params defaulting to per-entry c.
- `multibrot*_julia` IDs do NOT exist in the catalog (TODO P1-1b was aspirational); `phoenix_julia` and all cubic/power/trig/perpendicular variants are OUT OF SCOPE (spec: no shader delta or unverified seeding).

---

### Task 1: Julia seeding in the unified orbit computation

**Files:**
- Modify: `lib/core/modules/escape_time_perturb_module.dart` (function `computeEscapeTimePerturbOrbitBytes`)
- Test: `test/perturb_orbit_julia_seed_test.dart` (create)

- [ ] **Step 1: Write the failing test**

Create `test/perturb_orbit_julia_seed_test.dart`:

```dart
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('julia-seeded reference orbit', () {
    // Shader decode of one packed component (r + g/256 + b/65536 over [-4,4)).
    double decodeAt(List<int> bytes, int px) => decodePerturbOrbitComponent(
        bytes[px * 4], bytes[px * 4 + 1], bytes[px * 4 + 2]);

    test('z0 = center, c fixed; stores Z0 first; matches direct iteration',
        () {
      const cr = -1.0; // basilica: 0 -> -1 -> 0 exact 2-cycle from z0=0
      const ci = 0.0;
      const centerX = 0.3;
      const centerY = 0.2;
      const iterations = 100;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: centerX,
        centerY: centerY,
        iterations: iterations,
        juliaCReal: cr,
        juliaCImag: ci,
      );

      // pixel 0 must be Z0 = center (store-before-iterate convention).
      expect(decodeAt(result.bytes, 0), closeTo(centerX, 1e-6));
      expect(decodeAt(result.bytes, 1), closeTo(centerY, 1e-6));

      // Full orbit must match direct double iteration of z^2 + c.
      double zr = centerX, zi = centerY;
      for (var n = 0; n < iterations; n++) {
        if (zr.abs() < 3.9 && zi.abs() < 3.9) {
          expect(decodeAt(result.bytes, n * 2), closeTo(zr, 1e-6),
              reason: 'Re(Z$n)');
          expect(decodeAt(result.bytes, n * 2 + 1), closeTo(zi, 1e-6),
              reason: 'Im(Z$n)');
        }
        final nzr = zr * zr - zi * zi + cr;
        final nzi = 2.0 * zr * zi + ci;
        zr = nzr;
        zi = nzi;
        if (zr * zr + zi * zi > 1e6) break;
      }
    });

    test('period detection still works with a julia seed', () {
      // z0 = 0 with c = -1 is the exact 0,-1 2-cycle.
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: 0.0,
        centerY: 0.0,
        iterations: 500,
        juliaCReal: -1.0,
        juliaCImag: 0.0,
      );
      expect(result.detectedPeriod, 2);
      expect(result.computedIterations, lessThan(10));
    });

    test(
        'delta-recurrence mirror: julia-mode init tracks direct iteration '
        'and the old dz0=0 init provably renders flat (GPU-free regression)',
        () {
      // Mirrors the shader math for formula 0 (deltaMandelbrot):
      //   dzNew = 2*Zn*dz + dz^2 + dc
      // Julia mode: dz0 = pixel offset, dc = 0 (spec design).
      // Old behavior: dz0 = 0 with deltaJulia (no dc) => dz stays 0.
      const cr = -1.0, ci = 0.0;
      const centerX = -0.6180339887498949, centerY = 0.0; // repelling fixed pt
      const offX = 1e-9, offY = 5e-10; // pixel offset at deep zoom
      const iterations = 60;

      // Reference orbit Zn (raw doubles, same recurrence as production).
      final zn = List<(double, double)>.filled(iterations, (0, 0));
      double zr = centerX, zi = centerY;
      for (var n = 0; n < iterations; n++) {
        zn[n] = (zr, zi);
        final nzr = zr * zr - zi * zi + cr;
        final nzi = 2.0 * zr * zi + ci;
        zr = nzr;
        zi = nzi;
      }

      // New semantics: dz0 = offset, dc = 0.
      double dzr = offX, dzi = offY;
      // Direct iteration of the actual pixel point for comparison.
      double pr = centerX + offX, pi = centerY + offY;
      for (var n = 0; n < iterations; n++) {
        final (zrn, zin) = zn[n];
        final fullR = zrn + dzr, fullI = zin + dzi;
        expect(fullR, closeTo(pr, 1e-9 + pr.abs() * 1e-6),
            reason: 'Re mismatch at n=$n');
        expect(fullI, closeTo(pi, 1e-9 + pi.abs() * 1e-6),
            reason: 'Im mismatch at n=$n');
        // dzNew = 2*Zn*dz + dz^2 (dc = 0 in julia mode)
        final ndzr = 2.0 * (zrn * dzr - zin * dzi) + (dzr * dzr - dzi * dzi);
        final ndzi = 2.0 * (zrn * dzi + zin * dzr) + 2.0 * dzr * dzi;
        dzr = ndzr;
        dzi = ndzi;
        final npr = pr * pr - pi * pi + cr;
        final npi = 2.0 * pr * pi + ci;
        pr = npr;
        pi = npi;
      }

      // Old semantics: dz0 = 0 and no dc source term => dz identically 0,
      // i.e. every pixel collapses onto the reference orbit (flat frame).
      double odzr = 0.0, odzi = 0.0;
      for (var n = 0; n < iterations; n++) {
        final (zrn, zin) = zn[n];
        final ndzr = 2.0 * (zrn * odzr - zin * odzi) + (odzr * odzr - odzi * odzi);
        final ndzi = 2.0 * (zrn * odzi + zin * odzr) + 2.0 * odzr * odzi;
        odzr = ndzr;
        odzi = ndzi;
      }
      expect(odzr, 0.0);
      expect(odzi, 0.0);
    });

    test('variant base formulas iterate their own recurrence (celtic)', () {
      const cr = -0.70176, ci = -0.3842; // celtic_julia shader seed
      const centerX = 0.1, centerY = 0.1;
      const iterations = 50;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'celtic',
        centerX: centerX,
        centerY: centerY,
        iterations: iterations,
        juliaCReal: cr,
        juliaCImag: ci,
      );
      double zr = centerX, zi = centerY;
      for (var n = 0; n < iterations; n++) {
        if (zr.abs() < 3.9 && zi.abs() < 3.9) {
          expect(decodeAt(result.bytes, n * 2), closeTo(zr, 1e-6));
          expect(decodeAt(result.bytes, n * 2 + 1), closeTo(zi, 1e-6));
        }
        // Celtic: (|Re(z^2)|, Im(z^2)) + c
        final re2 = zr * zr - zi * zi;
        final im2 = 2.0 * zr * zi;
        zr = re2.abs() + cr;
        zi = im2 + ci;
        if (zr * zr + zi * zi > 1e6) break;
      }
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/perturb_orbit_julia_seed_test.dart`
Expected: FAIL — compile error: `No named parameter with the name 'juliaCReal'`.

- [ ] **Step 3: Implement julia seeding**

In `lib/core/modules/escape_time_perturb_module.dart`, change the signature and
seeding of `computeEscapeTimePerturbOrbitBytes`:

```dart
/// When [juliaCReal] is non-null the orbit is a Julia reference orbit:
/// z0 = (centerX, centerY) and the iteration constant is the fixed
/// (juliaCReal, juliaCImag) instead of the center (Mandelbrot form).
PerturbOrbitResult computeEscapeTimePerturbOrbitBytes({
  required String moduleId,
  required double centerX,
  required double centerY,
  required int iterations,
  double phoenixP = 0.0,
  double? juliaCReal,
  double? juliaCImag,
}) {
```

and replace the seed block

```dart
  double zr = 0.0;
  double zi = 0.0;
```

with

```dart
  // Note: `juliaCReal ?? centerX` (not a ternary on the nullable) so the
  // result type is non-nullable double.
  final juliaMode = juliaCReal != null;
  final cx = juliaCReal ?? centerX;
  final cy = juliaMode ? (juliaCImag ?? 0.0) : centerY;
  double zr = juliaMode ? centerX : 0.0;
  double zi = juliaMode ? centerY : 0.0;
```

then pass `cx: cx, cy: cy` to `_iterateEscapeTime` (replacing
`cx: centerX, cy: centerY`). Nothing else changes — period detection, escape
break, and encoding are seed-agnostic.

- [ ] **Step 4: Run tests to verify pass (new + regression)**

Run: `flutter test test/perturb_orbit_julia_seed_test.dart test/perturb_orbit_period_test.dart test/perturb_orbit_encoding_test.dart`
Expected: ALL PASS (Mandelbrot-form callers pass no seed → identical behavior).

- [ ] **Step 5: Commit**

```bash
git add lib/core/modules/escape_time_perturb_module.dart test/perturb_orbit_julia_seed_test.dart
git commit -m "Add julia seeding to unified perturbation reference orbit

Co-Authored-By: claude-flow <ruv@ruv.net>"
```

---

### Task 2: Shader julia mode + flat-render regression test (GPU)

**Files:**
- Modify: `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`
- Test: `integration_test/rendering/perturb_julia_flat_render_test.dart` (create)

- [ ] **Step 1: Write the failing integration test**

Create `integration_test/rendering/perturb_julia_flat_render_test.dart`:

```dart
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/services/rendering/perturb_orbit_texture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Regression test for the core-Julia perturbation flat-render bug: with
/// dz never seeded, every pixel evaluated to the reference orbit and the
/// frame was one flat color. Run:
///   xvfb-run -a flutter test integration_test/rendering/perturb_julia_flat_render_test.dart -d linux
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('julia perturbation renders spatially varying output',
      (tester) async {
    await tester.runAsync(() async {
      final program = await ui.FragmentProgram.fromAsset(
          'shaders/escape_time_family/core/escape_time_perturb_gpu.frag');
      final shader = program.fragmentShader();

      // Palette: 256-px gradient (data-exact via the shared rasterizer).
      final paletteBytes = Uint8List(256 * 4);
      for (var x = 0; x < 256; x++) {
        paletteBytes[x * 4] = x;
        paletteBytes[x * 4 + 1] = 255 - x;
        paletteBytes[x * 4 + 2] = 128;
        paletteBytes[x * 4 + 3] = 255;
      }
      final palette = rasterizePerturbOrbitBytes(paletteBytes, 256);

      // Basilica julia (c = -1) centered on the repelling fixed point
      // (1 - sqrt(5))/2 ~ -0.618 (on the Julia set), zoom 1e8: the
      // neighborhood must contain varied escape counts.
      const centerX = -0.6180339887498949;
      const centerY = 0.0;
      const iterations = 500;
      final orbit = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: centerX,
        centerY: centerY,
        iterations: iterations,
        juliaCReal: -1.0,
        juliaCImag: 0.0,
      );
      final orbitTex = rasterizePerturbOrbitBytes(orbit.bytes, iterations * 2);

      shader.setFloat(0, 0.0); // uTime
      shader.setFloat(1, 256.0); // uResolution.x
      shader.setFloat(2, 256.0); // uResolution.y
      shader.setFloat(3, centerX); // uCenter.x
      shader.setFloat(4, centerY); // uCenter.y
      shader.setFloat(5, 1e8); // uZoom
      shader.setFloat(6, iterations.toDouble()); // uIterations
      shader.setFloat(7, 4.0); // uBailout
      shader.setFloat(8, 0.0); // uTransparentBg
      shader.setFloat(9, 1.0); // uFormula = 1 (the historical julia path)
      shader.setFloat(10, 0.0); // uExtra0
      shader.setFloat(11, 0.0); // uExtra1
      shader.setFloat(12, 1.0); // uExtra2 = julia mode
      shader.setImageSampler(0, palette);
      shader.setImageSampler(1, orbitTex);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 256, 256));
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 256, 256),
          ui.Paint()..shader = shader);
      final picture = recorder.endRecording();
      final image = picture.toImageSync(256, 256);
      picture.dispose();

      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final distinct = <int>{};
      for (var i = 0; i < px.length; i += 4) {
        distinct.add((px[i] << 16) | (px[i + 1] << 8) | px[i + 2]);
      }
      image.dispose();
      palette.dispose();
      orbitTex.dispose();

      expect(distinct.length, greaterThan(8),
          reason: 'julia perturbation must not render a flat frame '
              '(got ${distinct.length} distinct colors)');
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails against the current shader (RED)**

Run: `xvfb-run -a flutter test integration_test/rendering/perturb_julia_flat_render_test.dart -d linux`
Expected: FAIL — `distinct.length` is 1 or 2 (flat frame; dz ≡ 0 under formula 1, `uExtra2` ignored).

- [ ] **Step 3: Edit the shader**

In `shaders/escape_time_family/core/escape_time_perturb_gpu.frag`:

(a) Delete the `deltaJulia` function (~line 54):

```glsl
vec2 deltaJulia(vec2 Zn, vec2 dz) {
  return 2.0 * cmul(Zn, dz) + cmul(dz, dz);
}
```

(b) In `main()`, replace

```glsl
  vec2 dc = uv / max(1e-9, uZoom);
  vec2 dz = vec2(0.0);
```

with

```glsl
  // Julia mode (uExtra2 > 0.5): c is constant, so the dc source term is
  // zero and the pixel offset enters through the initial delta instead
  // (z0 = center + offset vs reference z0 = center => dz0 = offset).
  vec2 dc = uv / max(1e-9, uZoom);
  vec2 dz = vec2(0.0);
  if (uExtra2 > 0.5) {
    dz = dc;
    dc = vec2(0.0);
  }
```

(c) Replace the formula-1 dispatch branch

```glsl
    } else if (formula == 1) {
      dzNew = deltaJulia(Zn, dz);
```

with

```glsl
    } else if (formula == 1) {
      // Legacy julia formula id: identical to Mandelbrot's delta; julia
      // behavior comes from the uExtra2 mode (dc = 0, dz0 = offset).
      dzNew = deltaMandelbrot(Zn, dz, dc);
```

No other shader lines change. Note the SkSL constraints (no `%` on ints, no
int clamp) — this edit uses neither.

- [ ] **Step 4: Run integration test to verify pass (GREEN), plus GPU byte test**

Run: `xvfb-run -a flutter test integration_test/rendering/perturb_julia_flat_render_test.dart integration_test/rendering/perturb_orbit_texture_gpu_test.dart -d linux`
Expected: ALL PASS.

- [ ] **Step 5: Verify non-julia paths are untouched (unit + shader diagnostics)**

Run: `flutter test test/perturb_orbit_period_test.dart test/perturb_orbit_encoding_test.dart test/perturb_orbit_texture_test.dart && flutter test test/shaders/ 2>/dev/null || flutter test test/ --plain-name "shader" 2>&1 | tail -5`
Expected: PASS (when `uExtra2 == 0.0` — every existing caller — dz/dc are bit-identical to before).

- [ ] **Step 6: Commit**

```bash
git add shaders/escape_time_family/core/escape_time_perturb_gpu.frag integration_test/rendering/perturb_julia_flat_render_test.dart
git commit -m "Fix julia perturbation flat render with shader julia mode

dz was never seeded for formula 1 (deltaJulia has no dc source term),
so dz stayed identically zero and every pixel rendered the reference
orbit value. uExtra2 now switches julia mode: dz0 = pixel offset,
dc = 0, reusing each base formula's existing delta.

Co-Authored-By: claude-flow <ruv@ruv.net>"
```

---

### Task 3: Variant table + julia-mode uniforms in the wrapper module

**Files:**
- Modify: `lib/core/modules/escape_time_perturb_module.dart`
- Test: `test/perturb_julia_variant_table_test.dart` (create)

- [ ] **Step 1: Write the failing test**

Create `test/perturb_julia_variant_table_test.dart`:

```dart
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('julia variant perturbation specs', () {
    test('core julia and verified family variants are present', () {
      expect(kJuliaVariantSpecs['julia']!.baseId, 'mandelbrot');
      expect(kJuliaVariantSpecs['celtic_julia']!.baseId, 'celtic');
      expect(kJuliaVariantSpecs['celtic_julia']!.cReal, -0.70176);
      expect(kJuliaVariantSpecs['celtic_julia']!.cImag, -0.3842);
      expect(kJuliaVariantSpecs['buffalo_julia']!.cReal, -0.45);
      expect(kJuliaVariantSpecs['burning_ship_julia']!.cReal, -0.52);
      expect(kJuliaVariantSpecs['tricorn_julia']!.cImag, 0.74);
    });

    test('f-series preset julias route as z^2+c with param-sourced c', () {
      for (final id in [
        'f0143_dendrite_julia',
        'f0146_basilica_julia',
        'f0158_period_7_julia',
        'f0176_dendritic_tree_julia',
      ]) {
        final spec = kJuliaVariantSpecs[id];
        expect(spec, isNotNull, reason: id);
        expect(spec!.baseId, 'mandelbrot', reason: id);
        expect(spec.cReal, isNull,
            reason: '$id must read c from juliaCReal/juliaCImag params');
      }
    });

    test('every spec baseId maps to a real shader formula', () {
      const knownBaseIds = {
        'mandelbrot', 'burning_ship', 'buffalo', 'tricorn', 'celtic',
        'multibrot3', 'multibrot4', 'multibrot5', 'phoenix',
      };
      for (final spec in kJuliaVariantSpecs.values) {
        expect(knownBaseIds, contains(spec.baseId));
      }
    });

    test('excluded families are not present', () {
      for (final id in [
        'phoenix_julia', 'celtic_cubic_julia', 'burning_ship_perp_julia',
        'cosine_julia', 'perpendicular_julia', 'dual_quaternion_julia',
      ]) {
        expect(kJuliaVariantSpecs.containsKey(id), isFalse, reason: id);
      }
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/perturb_julia_variant_table_test.dart`
Expected: FAIL — `kJuliaVariantSpecs` undefined.

- [ ] **Step 3: Verify the f-series shared shader is z²+c before including it**

Run: `grep -n "shaderAsset" lib/core/modules/builders/shared_catalogs/shared_julia_catalog.dart | head -2`, then grep that asset for its iteration: `grep -n "z = \|z2\|cpow2" shaders/<that asset path> | head -8`
Decision rule: if the iteration is `z = z^2 + c` (any spelling: `cpow2(z) + c`, `vec2(z.x*z.x - z.y*z.y, 2*z.x*z.y) + c`), keep the 26 f-series rows in Step 4. If it is anything else, delete the f-series rows from the table and from the Step 1 test, and note the exclusion in the commit message.

- [ ] **Step 4: Implement the variant table and wrapper wiring**

In `lib/core/modules/escape_time_perturb_module.dart`, add below
`kPerturbableEscapeTimeIds`:

```dart
/// Deep-zoom perturbation spec for a Julia-variant catalog ID.
///
/// [baseId] selects the delta formula family (see [formulaForId]).
/// [cReal]/[cImag] are the fixed Julia constant; when null the wrapper reads
/// the module's 'juliaCReal'/'juliaCImag' params instead (f-series presets
/// and core julia expose them).
class JuliaVariantSpec {
  final String baseId;
  final double? cReal;
  final double? cImag;
  const JuliaVariantSpec(this.baseId, [this.cReal, this.cImag]);
}

/// Catalog IDs routed to GPU perturbation in julia mode. Constants are the
/// cSeed values hardcoded in each variant's standalone shader (locked for
/// burning_ship_julia by burning_ship_julia_visual_contract_test).
const Map<String, JuliaVariantSpec> kJuliaVariantSpecs = {
  'julia': JuliaVariantSpec('mandelbrot'),
  'celtic_julia': JuliaVariantSpec('celtic', -0.70176, -0.3842),
  'buffalo_julia': JuliaVariantSpec('buffalo', -0.45, 0.1428),
  'burning_ship_julia': JuliaVariantSpec('burning_ship', -0.52, -0.42),
  'tricorn_julia': JuliaVariantSpec('tricorn', -0.12, 0.74),
  // Preset-c z^2 julias (c comes from juliaCReal/juliaCImag params).
  'f0143_dendrite_julia': JuliaVariantSpec('mandelbrot'),
  'f0144_airplane_julia': JuliaVariantSpec('mandelbrot'),
  'f0145_seahorse_valley_julia': JuliaVariantSpec('mandelbrot'),
  'f0146_basilica_julia': JuliaVariantSpec('mandelbrot'),
  'f0147_san_marco_julia': JuliaVariantSpec('mandelbrot'),
  'f0148_kaleidoscope_julia': JuliaVariantSpec('mandelbrot'),
  'f0149_cactus_julia': JuliaVariantSpec('mandelbrot'),
  'f0150_fatou_dust_julia': JuliaVariantSpec('mandelbrot'),
  'f0151_siegel_disk_julia': JuliaVariantSpec('mandelbrot'),
  'f0152_galaxy_julia': JuliaVariantSpec('mandelbrot'),
  'f0153_dragon_julia': JuliaVariantSpec('mandelbrot'),
  'f0154_period_3_julia': JuliaVariantSpec('mandelbrot'),
  'f0155_period_4_julia': JuliaVariantSpec('mandelbrot'),
  'f0156_period_5_julia': JuliaVariantSpec('mandelbrot'),
  'f0157_period_6_julia': JuliaVariantSpec('mandelbrot'),
  'f0158_period_7_julia': JuliaVariantSpec('mandelbrot'),
  'f0161_swirl_julia': JuliaVariantSpec('mandelbrot'),
  'f0162_lightning_julia': JuliaVariantSpec('mandelbrot'),
  'f0163_filigree_julia': JuliaVariantSpec('mandelbrot'),
  'f0164_spiral_julia': JuliaVariantSpec('mandelbrot'),
  'f0166_chebyshev_julia': JuliaVariantSpec('mandelbrot'),
  'f0167_cauliflower_bulb_julia': JuliaVariantSpec('mandelbrot'),
  'f0173_mini_brot_julia': JuliaVariantSpec('mandelbrot'),
  'f0174_elephant_valley_julia': JuliaVariantSpec('mandelbrot'),
  'f0175_near_elephant_julia': JuliaVariantSpec('mandelbrot'),
  'f0176_dendritic_tree_julia': JuliaVariantSpec('mandelbrot'),
};
```

In `buildEscapeTimePerturbModule`, replace

```dart
  final id = standardModule.id;
  final formula = formulaForId(id);
```

with

```dart
  final id = standardModule.id;
  final variant = kJuliaVariantSpecs[id];
  final formula = formulaForId(variant?.baseId ?? id);
```

Inside `setUniforms`, after the `colorSpeed` line add:

```dart
      double? juliaCReal;
      double? juliaCImag;
      if (variant != null) {
        juliaCReal =
            variant.cReal ?? readDouble(state.params, 'juliaCReal', -0.8);
        juliaCImag =
            variant.cImag ?? readDouble(state.params, 'juliaCImag', 0.156);
      }
```

pass them through the cache call:

```dart
      final orbitTex = _EscapeTimePerturbOrbitCache.instance.orbitTexture(
        moduleId: variant?.baseId ?? id,
        centerX: state.view.pan.x,
        centerY: state.view.pan.y,
        iterations: iterations,
        phoenixP: phoenixP,
        juliaCReal: juliaCReal,
        juliaCImag: juliaCImag,
      );
```

and change the uExtra2 uniform from `shader.setFloat(12, 0.0);` to:

```dart
      shader.setFloat(12, variant != null ? 1.0 : 0.0); // uExtra2 = julia mode
```

In `_EscapeTimePerturbOrbitCache.orbitTexture`, add the parameters and key
components:

```dart
  ui.Image orbitTexture({
    required String moduleId,
    required double centerX,
    required double centerY,
    required int iterations,
    double phoenixP = 0.0,
    double? juliaCReal,
    double? juliaCImag,
  }) {
    final key =
        '$moduleId|${centerX.toStringAsFixed(12)}|${centerY.toStringAsFixed(12)}'
        '|$iterations|${phoenixP.toStringAsFixed(8)}'
        '|${juliaCReal?.toStringAsFixed(12)}|${juliaCImag?.toStringAsFixed(12)}';
```

and forward `juliaCReal: juliaCReal, juliaCImag: juliaCImag` in its
`computeEscapeTimePerturbOrbitBytes` call.

- [ ] **Step 5: Run tests to verify pass**

Run: `flutter test test/perturb_julia_variant_table_test.dart test/perturb_orbit_julia_seed_test.dart test/perturb_orbit_period_test.dart test/perturb_orbit_encoding_test.dart && dart analyze lib/core/modules/escape_time_perturb_module.dart`
Expected: ALL PASS, analyzer clean.

- [ ] **Step 6: Commit**

```bash
git add lib/core/modules/escape_time_perturb_module.dart test/perturb_julia_variant_table_test.dart
git commit -m "Add julia-variant perturbation table and julia-mode uniforms

Co-Authored-By: claude-flow <ruv@ruv.net>"
```

---

### Task 4: Routing — gate, resolver, delete the duplicate julia module

**Files:**
- Modify: `lib/features/renderer/policy/precision_ladder_policy.dart:293`
- Modify: `lib/features/renderer/policy/render_plan.dart:32-56`
- Delete: `lib/core/modules/julia_perturb_module.dart`
- Modify: `test/julia_perturb_orbit_encoding_test.dart` (retarget to unified function)
- Test: `test/features/renderer/renderer_plan_policy_test.dart` (extend)

- [ ] **Step 1: Write the failing routing test**

Append inside `main()` in
`test/features/renderer/renderer_plan_policy_test.dart` (it already imports
`ModuleRegistry`, `RendererPlanModuleResolver`, `RendererPlan`, and defines
`precisionPolicy` at the top of `main()`):

```dart
  test('routes julia variants to the perturbation wrapper at deep zoom', () {
    final registry = ModuleRegistry();
    final resolver = RendererPlanModuleResolver();
    for (final id in ['julia', 'celtic_julia', 'f0146_basilica_julia']) {
      final module = registry.byId(id);
      final resolved = resolver.resolve(
        plan: RendererPlan.gpu(
          precisionPolicy.decide(
            moduleId: id,
            dimension: FractalDimension.twoD,
            zoom: 1e10,
          ),
        ),
        module: module,
      );
      expect(
        resolved.shaderAsset,
        'shaders/escape_time_family/core/escape_time_perturb_gpu.frag',
        reason: id,
      );
    }
  });
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/renderer/renderer_plan_policy_test.dart`
Expected: The new test FAILS for `celtic_julia`/`f0146_basilica_julia`
(these IDs don't pass the precision gate yet). `julia` may pass via the old
special case.

- [ ] **Step 3: Update the gate and resolver**

In `lib/features/renderer/policy/precision_ladder_policy.dart` line 293,
replace:

```dart
      moduleId == 'julia' || kPerturbableEscapeTimeIds.contains(moduleId);
```

with:

```dart
      kJuliaVariantSpecs.containsKey(moduleId) ||
          kPerturbableEscapeTimeIds.contains(moduleId);
```

(add the import of `escape_time_perturb_module.dart` if not present).

In `lib/features/renderer/policy/render_plan.dart`, delete the julia special
case and field:

```dart
  FractalModule? _juliaPerturbModule;
```
```dart
    if (module.id == 'julia') {
      return _juliaPerturbModule ??= buildJuliaPerturbModule(module);
    }
```

and remove the now-unused import of `julia_perturb_module.dart`.

- [ ] **Step 4: Retarget the julia encoding test and delete the old module**

Check remaining references first:

Run: `grep -rn "julia_perturb_module\|computeJuliaPerturbOrbitBytes\|buildJuliaPerturbModule" lib/ test/ integration_test/`
Expected referencers: `test/julia_perturb_orbit_encoding_test.dart` only (fix
any others found the same way — swap to the unified function/module).

Rewrite `test/julia_perturb_orbit_encoding_test.dart` to exercise the unified
path (note the convention change: Z₀ = center is stored FIRST now):

```dart
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Julia perturbation reference orbit encoding (unified path)', () {
    const intendedResolution = 8.0 / 16777216.0;

    test('orbit bytes decode to ~24-bit precision against direct iteration',
        () {
      const cReal = -0.8;
      const cImag = 0.156;
      const centerX = 0.05;
      const centerY = 0.02;
      const iterations = 200;

      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: centerX,
        centerY: centerY,
        iterations: iterations,
        juliaCReal: cReal,
        juliaCImag: cImag,
      );

      // Store-Z0-first: pixel 0 is the center itself.
      double zr = centerX;
      double zi = centerY;
      var maxError = 0.0;
      var compared = 0;
      for (var n = 0; n < iterations; n++) {
        for (final (value, px) in [(zr, n * 2), (zi, n * 2 + 1)]) {
          if (value.abs() >= 3.9) continue;
          final i = px * 4;
          final decoded = decodePerturbOrbitComponent(
              result.bytes[i], result.bytes[i + 1], result.bytes[i + 2]);
          final error = (decoded - value).abs();
          if (error > maxError) maxError = error;
          compared++;
        }
        final nzr = zr * zr - zi * zi + cReal;
        final nzi = 2.0 * zr * zi + cImag;
        zr = nzr;
        zi = nzi;
        if (zr * zr + zi * zi > 1e6) break;
      }

      expect(compared, greaterThan(100));
      expect(maxError, lessThanOrEqualTo(intendedResolution * 1.5));
    });
  });
}
```

Then delete the module:

```bash
git rm lib/core/modules/julia_perturb_module.dart
```

- [ ] **Step 5: Run the routing + orbit suites**

Run: `flutter test test/features/renderer/renderer_plan_policy_test.dart test/julia_perturb_orbit_encoding_test.dart test/perturb_julia_variant_table_test.dart test/memory_lifecycle_regression_test.dart && dart analyze lib/features/renderer/policy/ lib/core/modules/escape_time_perturb_module.dart`
Expected: ALL PASS, analyzer clean.

- [ ] **Step 6: Commit**

```bash
git add -u lib/features/renderer/policy/ test/features/renderer/renderer_plan_policy_test.dart test/julia_perturb_orbit_encoding_test.dart
git commit -m "Route julia variants through unified perturbation wrapper

Deletes julia_perturb_module.dart: the escape-time wrapper now serves
julia mode, removing the Z1-first orbit off-by-one and the last
duplicate orbit code path.

Co-Authored-By: claude-flow <ruv@ruv.net>"
```

---

### Task 5: Full validation sweep + docs

**Files:**
- Modify: `TODO.md` (P1-1b status)

- [ ] **Step 1: Run the full related test battery**

Run:
```bash
flutter test test/perturb_orbit_julia_seed_test.dart test/perturb_julia_variant_table_test.dart test/julia_perturb_orbit_encoding_test.dart test/perturb_orbit_period_test.dart test/perturb_orbit_encoding_test.dart test/perturb_orbit_texture_test.dart test/features/renderer/renderer_plan_policy_test.dart test/memory_lifecycle_regression_test.dart test/catalog_id_integrity_test.dart test/modules/burning_ship_julia_visual_contract_test.dart
xvfb-run -a flutter test integration_test/rendering/perturb_julia_flat_render_test.dart integration_test/rendering/perturb_orbit_texture_gpu_test.dart -d linux
```
Expected: ALL PASS except `catalog_id_integrity_test` which has a PRE-EXISTING
failure in this worktree (module count 1592 vs 981 lock, from the in-flight
catalog expansion — NOT caused by this work; this plan adds no modules). If
any OTHER test in that file fails, stop and investigate.

- [ ] **Step 2: Update TODO.md P1-1b**

In `TODO.md`, under `#### P1-1b: Extend Perturbation to Julia Variants`,
replace the target list items 1–5 with:

```markdown
- [x] `julia` — core Julia (2026-07-02: flat-render bug fixed; unified into
  escape-time wrapper via julia mode, `julia_perturb_module.dart` deleted)
- [x] `celtic_julia`, `buffalo_julia`, `burning_ship_julia`, `tricorn_julia`
  (2026-07-02: julia-mode flag reusing base deltas)
- [x] 26 preset-c julias (`f0143`–`f0176` series) routed as z²+c julia mode
- [ ] `phoenix_julia`, cubic/power/trig/perpendicular variants — need new
  shader deltas; deferred (see spec Out of scope)
```

- [ ] **Step 3: Commit and push**

```bash
git add TODO.md
git commit -m "Mark TODO P1-1b julia-variant perturbation progress

Co-Authored-By: claude-flow <ruv@ruv.net>"
git push
```

---

## Verification summary (what proves the feature)

| Claim | Proof |
|---|---|
| Julia orbit seeding correct | `test/perturb_orbit_julia_seed_test.dart` (direct-iteration comparison, Z₀-first, period detection) |
| Flat-render bug fixed on GPU | `integration_test/rendering/perturb_julia_flat_render_test.dart` (RED before shader fix → GREEN after) |
| Non-julia paths bit-identical | uExtra2 stays 0.0 for them + existing perturbation suites green |
| Variants routed at deep zoom | renderer_plan_policy routing test |
| No duplicate orbit code remains | `julia_perturb_module.dart` deleted; grep in Task 4 Step 4 |
| cSeed constants faithful | table values match shader constants; burning_ship locked by existing visual-contract test |
