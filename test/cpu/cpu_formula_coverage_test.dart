import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';

const _dataDrivenIfsFormulaIds = <String>{
  'sierpinski_triangle',
  'sierpinski_carpet',
  'koch_snowflake',
  'dragon_curve',
  'barnsley_fern',
  'pythagorean_tree',
  'hilbert_curve',
  'peano_curve',
  'gosper_curve',
  'levy_c_curve',
  'levy_tapestry',
  'golden_dragon',
  'twin_dragon',
  'terdragon',
  'chair_tiling',
  'koch_anti_snowflake',
  'quadratic_koch_island',
  'cyclosorus_fern',
  'menger_sponge_2d',
  'vicsek_fractal',
  'penrose_tiling',
  'fibonacci_word',
  'rauzy_fractal',
  'pinwheel_tiling',
  'z_order_curve',
  'greek_cross_fractal',
  'sierpinski_pentagon',
  'hexaflake',
  'pentaflake',
  'cantor_dust',
  'apollonian_gasket',
  'ford_circles',
  'steiner_chain',
  'cesaro_fractal',
  'cantor_set',
  'fractal_canopy',
};

const _dataDrivenAttractorFormulaIds = <String>{
  'benesi',
  'pseudo_kleinian',
  'henon',
  'tinkerbell',
  'gingerbreadman',
  'lozi',
  'duffing',
  'ikeda',
  'clifford',
  'gumowski_mira',
  'arnold_cat',
  'standard_map',
  'zaslavsky',
  'kicked_rotator',
  'chua_circuit',
  'sprott_a',
  'burke_shaw',
  'arneodo',
  'thomas_attractor',
  'four_wing',
  'lorenz_2d',
  'rossler_2d',
  'dadras',
  'chen',
  'lu_chen',
  'halvorsen',
  'scroll_waves',
  'rikitake',
  'aizawa',
  'rabinovich_fabrikant',
  'nose_hoover',
  'moore_spiegel',
  'hadley',
  'genesio_tesi',
  'liu_chen',
  'newton_leipnik',
  'bouali',
};

void main() {
  group('CPU Formula Registry', () {
    test('data-driven approximations stay native and cached', () {
      for (final id in {
        ..._dataDrivenIfsFormulaIds,
        ..._dataDrivenAttractorFormulaIds,
      }) {
        expect(hasNativeCpuFormula(id), isTrue, reason: id);
        expect(
          identical(
            cpuFormulaForModuleId(id),
            cpuFormulaForModuleId(id),
          ),
          isTrue,
          reason: '$id should reuse its lazily created formula',
        );
      }
    });

    test('resolves every escape-time catalog module id', () {
      final unresolved = <String>[];
      for (final cfg in escapeTimeCatalog) {
        final formula = cpuFormulaForModuleId(cfg.id);
        final color = formula(0.0, 0.0, 32, 4.0, Vector2.zero());
        final valid =
            color.$1.isFinite && color.$2.isFinite && color.$3.isFinite;
        if (!valid) {
          unresolved.add(cfg.id);
        }
      }
      expect(
        unresolved,
        isEmpty,
        reason:
            'CPU formula resolver produced invalid output for: ${unresolved.join(', ')}',
      );
    });

    test('non-mandelbrot formulas differ from Mandelbrot baseline', () async {
      const width = 64;
      const height = 64;

      // One standard view for consistent comparisons.
      final viewPan = Vector2(-0.5, 0.0);
      const viewZoom = 3.0;
      const iterations = 80;
      const bailout = 4.0;
      final juliaC = Vector2(-0.8, 0.156);

      final baseline = await renderCpuFrame(
        moduleId: 'mandelbrot',
        viewPan: viewPan,
        viewZoom: viewZoom,
        iterations: iterations,
        bailout: bailout,
        juliaC: juliaC,
        width: width,
        height: height,
        sampleCount: 1,
      );

      for (final cfg in escapeTimeCatalog) {
        if (cfg.id == 'mandelbrot') continue;

        final frame = await renderCpuFrame(
          moduleId: cfg.id,
          viewPan: viewPan,
          viewZoom: viewZoom,
          iterations: iterations,
          bailout: bailout,
          juliaC: juliaC,
          width: width,
          height: height,
          sampleCount: 1,
        );

        int diff = 0;
        final total = width * height;
        for (int i = 0; i < frame.rgba.length; i += 4) {
          final dr = (frame.rgba[i] - baseline.rgba[i]).abs();
          final dg = (frame.rgba[i + 1] - baseline.rgba[i + 1]).abs();
          final db = (frame.rgba[i + 2] - baseline.rgba[i + 2]).abs();
          if (dr + dg + db >= 10) diff++;
        }

        final ratio = diff / total;
        expect(
          ratio,
          greaterThan(0.05),
          reason:
              'CPU formula for ${cfg.id} is too similar to Mandelbrot baseline (diffRatio=${ratio.toStringAsFixed(3)}).',
        );
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('renders non-black ratio above 1%', () async {
      const width = 64;
      const height = 64;

      final viewPan = Vector2(-0.5, 0.0);
      const viewZoom = 3.0;
      const iterations = 80;
      const bailout = 4.0;
      final juliaC = Vector2(-0.8, 0.156);

      for (final cfg in escapeTimeCatalog) {
        final frame = await renderCpuFrame(
          moduleId: cfg.id,
          viewPan: viewPan,
          viewZoom: viewZoom,
          iterations: iterations,
          bailout: bailout,
          juliaC: juliaC,
          width: width,
          height: height,
          sampleCount: 1,
        );

        int nonBlack = 0;
        for (int i = 0; i < frame.rgba.length; i += 4) {
          if (frame.rgba[i] > 8 ||
              frame.rgba[i + 1] > 8 ||
              frame.rgba[i + 2] > 8) {
            nonBlack++;
          }
        }
        final ratio = nonBlack / (width * height);
        expect(
          ratio,
          greaterThan(0.01),
          reason:
              '${cfg.id} produced too many black pixels (nonBlackRatio=${ratio.toStringAsFixed(3)}).',
        );
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
