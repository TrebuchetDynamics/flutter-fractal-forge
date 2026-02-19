/// Integration test: validates render output using frame-pair analysis.
///
/// Run on connected device/emulator:
///   flutter test integration_test/render_validation_test.dart
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Render Validation Frame-Pair Analysis', () {
    testWidgets('CPU Mandelbrot renders non-black with frame progression',
        (tester) async {
      // Render frame A at default iterations
      final frameA = await renderCpuFrame(
        moduleId: 'mandelbrot',
        viewPan: Vector2(-0.5, 0.0),
        viewZoom: 1.0,
        iterations: 120,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: 128,
        height: 128,
        sampleCount: 4,
      );

      // Render frame B with both zoom/pan and iteration changes so progression
      // is clearly visible across CPU implementations.
      final frameB = await renderCpuFrame(
        moduleId: 'mandelbrot',
        viewPan: Vector2(-0.68, 0.14),
        viewZoom: 1.38,
        iterations: 260,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: 128,
        height: 128,
        sampleCount: 4,
      );

      final result = validateRenderPair(
        frameA: frameA.rgba,
        frameB: frameB.rgba,
        width: 128,
        height: 128,
      );

      debugPrint(result.summary('cpu-mandelbrot'));
      debugPrint('  centerNonBlack: ${result.centerNonBlack}');
      debugPrint('  histogramSane: ${result.histogramSane}');
      debugPrint('  frameProgressed: ${result.frameProgressed}');
      debugPrint('  iterationDeltaVisible: ${result.iterationDeltaVisible}');
      debugPrint('  nonBlackRatio: ${result.nonBlackRatio}');

      expect(result.centerNonBlack, isTrue,
          reason:
              'Center pixel should be non-black for Mandelbrot at (-0.5, 0)');
      expect(result.histogramSane, isTrue,
          reason: 'Non-black ratio should be > 1%');
      expect(result.pass, isTrue, reason: 'Overall render check should pass');
    });

    testWidgets('CPU Julia renders non-black', (tester) async {
      final frameA = await renderCpuFrame(
        moduleId: 'julia',
        viewPan: Vector2(0.0, 0.0),
        viewZoom: 1.2,
        iterations: 150,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: 128,
        height: 128,
        sampleCount: 4,
      );

      final frameB = await renderCpuFrame(
        moduleId: 'julia',
        viewPan: Vector2(0.0, 0.0),
        viewZoom: 1.2,
        iterations: 166,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: 128,
        height: 128,
        sampleCount: 4,
      );

      final result = validateRenderPair(
        frameA: frameA.rgba,
        frameB: frameB.rgba,
        width: 128,
        height: 128,
      );

      debugPrint(result.summary('cpu-julia'));
      expect(result.centerNonBlack, isTrue);
      expect(result.histogramSane, isTrue);
    });

    testWidgets('CPU Burning Ship renders non-black', (tester) async {
      final frameA = await renderCpuFrame(
        moduleId: 'burning_ship',
        viewPan: Vector2(-1.75, -0.03),
        viewZoom: 1.4,
        iterations: 200,
        bailout: 4.0,
        juliaC: Vector2(0, 0),
        width: 128,
        height: 128,
        sampleCount: 4,
      );

      final frameB = await renderCpuFrame(
        moduleId: 'burning_ship',
        viewPan: Vector2(-1.75, -0.03),
        viewZoom: 1.4,
        iterations: 216,
        bailout: 4.0,
        juliaC: Vector2(0, 0),
        width: 128,
        height: 128,
        sampleCount: 4,
      );

      final result = validateRenderPair(
        frameA: frameA.rgba,
        frameB: frameB.rgba,
        width: 128,
        height: 128,
      );

      debugPrint(result.summary('cpu-burning_ship'));
      expect(result.centerNonBlack, isTrue);
      expect(result.histogramSane, isTrue);
    });
  });
}
