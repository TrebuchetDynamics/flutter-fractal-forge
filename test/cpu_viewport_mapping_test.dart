import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  group('CPU viewport mapping', () {
    test('single-pixel iteration buffer samples the viewport center', () async {
      final buffer = await renderCpuIterationBuffer(
        moduleId: 'mandelbrot',
        viewPan: Vector2(-0.5, 0.0),
        viewZoom: 1.0,
        iterations: 50,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: 1,
        height: 1,
      );

      expect(buffer, isNotNull);
      expect(buffer!.single, 50);
    });
  });
}
