import 'package:flutter_fractals/features/renderer/providers/fractal_view_input_bounds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FractalViewInputBounds', () {
    test('preserves current zoom when candidate is NaN', () {
      expect(
        FractalViewInputBounds.normalizeZoom(
          candidate: double.nan,
          currentZoom: 42.0,
          moduleId: 'mandelbrot',
        ),
        42.0,
      );
    });

    test('falls back to module minimum when current and candidate zoom are NaN',
        () {
      expect(
        FractalViewInputBounds.normalizeZoom(
          candidate: double.nan,
          currentZoom: double.nan,
          moduleId: 'cantor_set',
        ),
        FractalViewInputBounds.cantorSetMinZoom,
      );
    });

    test('preserves current pan component when candidate is NaN', () {
      expect(
        FractalViewInputBounds.normalizePanComponent(
          candidate: double.nan,
          current: -1.25,
        ),
        -1.25,
      );
    });

    test('still clamps finite and infinite candidates to explicit bounds', () {
      expect(
        FractalViewInputBounds.normalizeZoom(
          candidate: double.infinity,
          currentZoom: 1.0,
          moduleId: 'mandelbrot',
        ),
        FractalViewInputBounds.maxZoom,
      );
      expect(
        FractalViewInputBounds.normalizePanComponent(
          candidate: -10.0,
          current: 0.0,
        ),
        FractalViewInputBounds.minPan,
      );
    });
  });
}
