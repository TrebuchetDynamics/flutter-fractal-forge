import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_view_input_bounds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

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

    test('preserves current rotation component when candidate is non-finite',
        () {
      expect(
        FractalViewInputBounds.normalizeRotationComponent(
          candidate: double.nan,
          current: 0.75,
        ),
        0.75,
      );
      expect(
        FractalViewInputBounds.normalizeRotationComponent(
          candidate: double.infinity,
          current: double.nan,
        ),
        0.0,
      );
    });

    test('normalizes externally loaded view snapshots as one invariant', () {
      final normalized = FractalViewInputBounds.normalizeView(
        candidate: FractalViewState(
          pan: Vector2(double.nan, double.infinity),
          zoom: double.nan,
          rotation: Vector3(double.nan, double.infinity, 3),
        ),
        current: FractalViewState(
          pan: Vector2(0.5, -0.5),
          zoom: 42.0,
          rotation: Vector3(0.25, double.nan, -1),
        ),
        moduleId: 'mandelbrot',
      );

      expect(normalized.zoom, 42.0);
      expect(normalized.pan.x, 0.5);
      expect(normalized.pan.y, FractalViewInputBounds.maxPan);
      expect(normalized.rotation, Vector3(0.25, 0.0, 3));
    });

    test('normalizes mixed finite and non-finite rotation updates', () {
      final normalized = FractalViewInputBounds.normalizeRotation(
        candidate: Vector3(double.nan, double.infinity, 2.0),
        current: Vector3(0.25, -0.5, 1.0),
      );

      expect(normalized, Vector3(0.25, -0.5, 2.0));
    });
  });
}
