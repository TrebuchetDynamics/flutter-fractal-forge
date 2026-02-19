import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/features/renderer/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';

void main() {
  group('CPU Formula Registry', () {
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
