import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';

void main() {
  group('FractalViewState', () {
    group('initial', () {
      test('creates state with zoom 1.0', () {
        final state = FractalViewState.initial();
        expect(state.zoom, 1.0);
      });

      test('creates state with zero pan', () {
        final state = FractalViewState.initial();
        expect(state.pan.x, 0.0);
        expect(state.pan.y, 0.0);
      });

      test('creates state with zero rotation', () {
        final state = FractalViewState.initial();
        expect(state.rotation.x, 0.0);
        expect(state.rotation.y, 0.0);
        expect(state.rotation.z, 0.0);
      });
    });

    group('copyWith', () {
      test('replaces only zoom when specified', () {
        final original = FractalViewState.initial();
        final copy = original.copyWith(zoom: 3.5);

        expect(copy.zoom, 3.5);
        expect(copy.pan.x, original.pan.x);
        expect(copy.pan.y, original.pan.y);
        expect(copy.rotation.x, original.rotation.x);
        expect(copy.rotation.y, original.rotation.y);
        expect(copy.rotation.z, original.rotation.z);
      });

      test('replaces only pan when specified', () {
        final original = FractalViewState.initial();
        final newPan = Vector2(1.5, -0.5);
        final copy = original.copyWith(pan: newPan);

        expect(copy.pan.x, 1.5);
        expect(copy.pan.y, -0.5);
        expect(copy.zoom, original.zoom);
        expect(copy.rotation.x, original.rotation.x);
      });

      test('replaces only rotation when specified', () {
        final original = FractalViewState.initial();
        final newRotation = Vector3(0.1, 0.2, 0.3);
        final copy = original.copyWith(rotation: newRotation);

        expect(copy.rotation.x, closeTo(0.1, 1e-6));
        expect(copy.rotation.y, closeTo(0.2, 1e-6));
        expect(copy.rotation.z, closeTo(0.3, 1e-6));
        expect(copy.zoom, original.zoom);
        expect(copy.pan.x, original.pan.x);
      });

      test('replaces all fields when all specified', () {
        final original = FractalViewState.initial();
        final newPan = Vector2(2.0, 3.0);
        final newRotation = Vector3(0.5, 1.0, 1.5);
        final copy = original.copyWith(
          pan: newPan,
          zoom: 10.0,
          rotation: newRotation,
        );

        expect(copy.zoom, 10.0);
        expect(copy.pan.x, 2.0);
        expect(copy.pan.y, 3.0);
        expect(copy.rotation.x, closeTo(0.5, 1e-6));
        expect(copy.rotation.y, closeTo(1.0, 1e-6));
        expect(copy.rotation.z, closeTo(1.5, 1e-6));
      });

      test('preserves all fields when no args provided', () {
        final original = FractalViewState(
          pan: Vector2(-0.5, 0.2),
          zoom: 3.0,
          rotation: Vector3(0.1, 0.2, 0.3),
        );
        final copy = original.copyWith();

        expect(copy.zoom, original.zoom);
        expect(copy.pan.x, original.pan.x);
        expect(copy.pan.y, original.pan.y);
        expect(copy.rotation.x, original.rotation.x);
        expect(copy.rotation.y, original.rotation.y);
        expect(copy.rotation.z, original.rotation.z);
      });

      test('returns a new instance, not the same reference', () {
        final original = FractalViewState.initial();
        final copy = original.copyWith(zoom: 2.0);
        expect(identical(original, copy), isFalse);
      });
    });

    group('constructor', () {
      test('stores all provided values', () {
        final pan = Vector2(1.0, 2.0);
        final rotation = Vector3(0.3, 0.6, 0.9);
        final state = FractalViewState(pan: pan, zoom: 5.0, rotation: rotation);

        expect(state.zoom, 5.0);
        expect(state.pan.x, 1.0);
        expect(state.pan.y, 2.0);
        expect(state.rotation.x, closeTo(0.3, 1e-6));
        expect(state.rotation.y, closeTo(0.6, 1e-6));
        expect(state.rotation.z, closeTo(0.9, 1e-6));
      });

      test('snapshots mutable vectors supplied by callers', () {
        final pan = Vector2(1.0, 2.0);
        final rotation = Vector3(0.3, 0.6, 0.9);
        final state = FractalViewState(pan: pan, zoom: 5.0, rotation: rotation);

        pan.setValues(7.0, 8.0);
        rotation.setValues(9.0, 10.0, 11.0);

        expect(state.pan.x, 1.0);
        expect(state.pan.y, 2.0);
        expect(state.rotation.x, closeTo(0.3, 1e-6));
        expect(state.rotation.y, closeTo(0.6, 1e-6));
        expect(state.rotation.z, closeTo(0.9, 1e-6));
      });
    });
  });
}
