import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu_render_isolate.dart';
import 'package:flutter_fractals/features/renderer/cpu_viewport_mapping.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  group('CPU viewport mapping', () {
    test('subpixel samples stay inside the normalized viewport', () {
      final viewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: 1.0,
        width: 2,
        height: 2,
      );

      expect(
        viewport.normalizedSample(
          pixel: 0,
          extent: 2,
          sample: 0,
          samplesPerAxis: 1,
        ),
        closeTo(-0.5, 1e-12),
      );
      expect(
        viewport.normalizedSample(
          pixel: 1,
          extent: 2,
          sample: 0,
          samplesPerAxis: 1,
        ),
        closeTo(0.5, 1e-12),
      );
    });

    test('invalid subpixel sample candidates clamp to the pixel footprint', () {
      final viewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: 1.0,
        width: 2,
        height: 2,
      );

      expect(
        viewport.normalizedSample(
          pixel: 1,
          extent: 2,
          sample: 4,
          samplesPerAxis: 2,
        ),
        closeTo(0.75, 1e-12),
      );
      expect(
        viewport.normalizedSample(
          pixel: 0,
          extent: 2,
          sample: -1,
          samplesPerAxis: 2,
        ),
        closeTo(-0.75, 1e-12),
      );
    });

    test('edge pixels preserve iteration-buffer edge-inclusive contract', () {
      final viewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: 1.0,
        width: 2,
        height: 2,
      );

      expect(viewport.normalizedPixel(0, 2), -1.0);
      expect(viewport.normalizedPixel(1, 2), 1.0);
    });

    test('invalid zoom falls back to replayable unit-scale coordinates', () {
      final viewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: double.nan,
        width: 2,
        height: 2,
      );

      expect(viewport.scale, 1.5);
      expect(viewport.coordinate(nx: 0.5, ny: -0.5), (0.75, -0.75));
    });

    test('isolate sample mapping shares invalid zoom normalization', () {
      final coordinate = cpuViewportCoordinateForSample(
        panX: 0.0,
        panY: 0.0,
        zoom: double.nan,
        fullWidth: 2,
        fullHeight: 2,
        x: 1,
        y: 0,
        sampleOffsetX: 0.5,
        sampleOffsetY: 0.5,
      );

      expect(coordinate.x, 0.75);
      expect(coordinate.y, -0.75);
    });

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
