import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';

void main() {
  group('CPU refinement patch pack', () {
    test('critical formulas are native (not synthetic fallback)', () {
      expect(hasNativeCpuFormula('phoenix'), isTrue);
      expect(hasNativeCpuFormula('multibrot4'), isTrue);
      expect(hasNativeCpuFormula('multibrot5'), isTrue);
      expect(hasNativeCpuFormula('weierstrass_p'), isTrue);
    });

    test('VIS-006 batch 20 formulas render finite CPU frames', () async {
      const moduleIds = <String>[
        'mimura_murray_predator_prey',
        'stable_square_turing_model',
        'flow_lenia',
        'coupled_logistic_map_lattice',
        'langton_ant',
        'turmite',
        'wireworld',
        'sandpile',
        'dla',
        'forest_fire',
      ];

      for (final moduleId in moduleIds) {
        expect(hasNativeCpuFormula(moduleId), isTrue, reason: moduleId);
        final frame = await renderCpuFrame(
          moduleId: moduleId,
          viewPan: Vector2.zero(),
          viewZoom: 1.0,
          iterations: 64,
          bailout: 4.0,
          juliaC: Vector2.zero(),
          width: 24,
          height: 24,
          sampleCount: 1,
        );
        expect(frame.rgba, hasLength(24 * 24 * 4), reason: moduleId);
        expect(
          frame.rgba.asMap().entries.any(
                (entry) => entry.key % 4 != 3 && entry.value != 0,
              ),
          isTrue,
          reason: '$moduleId should produce visible CPU output',
        );
      }
    });

    test('module-aware CPU defaults are stable', () {
      expect(cpuControlScalarForModule('nova', const {}), 1.0);
      expect(
          cpuControlScalarForModule('nova', const {'relaxation': 1.75}), 1.75);
      expect(cpuControlScalarForModule('mandelbrot', const {}), 4.0);

      final phoenixDefault = cpuJuliaCForModule('phoenix', const {});
      expect(phoenixDefault.x, closeTo(0.5667, 1e-6));
      expect(phoenixDefault.y, closeTo(0.0, 1e-6));

      final phoenixCustom = cpuJuliaCForModule('phoenix', const {
        'phoenixCReal': 0.2,
        'phoenixCImag': -0.3,
      });
      expect(phoenixCustom.x, closeTo(0.2, 1e-6));
      expect(phoenixCustom.y, closeTo(-0.3, 1e-6));
    });

    test('multibrot4/5 and phoenix are visually differentiated', () async {
      const width = 56;
      const height = 56;
      const iterations = 96;
      const bailout = 4.0;
      final viewPan = Vector2(-0.5, 0.0);
      const viewZoom = 1.1;
      final juliaC = Vector2(0.5667, 0.0);

      final mandelbrot = await renderCpuFrame(
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

      final multibrot4 = await renderCpuFrame(
        moduleId: 'multibrot4',
        viewPan: viewPan,
        viewZoom: viewZoom,
        iterations: iterations,
        bailout: bailout,
        juliaC: juliaC,
        width: width,
        height: height,
        sampleCount: 1,
      );

      final multibrot5 = await renderCpuFrame(
        moduleId: 'multibrot5',
        viewPan: viewPan,
        viewZoom: viewZoom,
        iterations: iterations,
        bailout: bailout,
        juliaC: juliaC,
        width: width,
        height: height,
        sampleCount: 1,
      );

      final phoenix = await renderCpuFrame(
        moduleId: 'phoenix',
        viewPan: Vector2(0.0, 0.0),
        viewZoom: 1.2,
        iterations: iterations,
        bailout: bailout,
        juliaC: juliaC,
        width: width,
        height: height,
        sampleCount: 1,
      );

      double diffRatio(CpuRenderFrame a, CpuRenderFrame b) {
        int diff = 0;
        final total = a.width * a.height;
        for (int i = 0; i < a.rgba.length; i += 4) {
          final dr = (a.rgba[i] - b.rgba[i]).abs();
          final dg = (a.rgba[i + 1] - b.rgba[i + 1]).abs();
          final db = (a.rgba[i + 2] - b.rgba[i + 2]).abs();
          if (dr + dg + db >= 14) diff++;
        }
        return diff / total;
      }

      expect(diffRatio(multibrot4, mandelbrot), greaterThan(0.08));
      expect(diffRatio(multibrot5, mandelbrot), greaterThan(0.08));
      expect(diffRatio(multibrot4, multibrot5), greaterThan(0.04));
      expect(diffRatio(phoenix, mandelbrot), greaterThan(0.08));
    });
  });
}
