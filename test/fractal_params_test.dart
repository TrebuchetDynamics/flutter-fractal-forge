import 'package:flutter_fractals/core/models/fractal_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('FractalParams', () {
    test('equality includes fractalType', () {
      final a = FractalParams(
        rotation: Vector3.zero(),
        mousePos: Vector2.zero(),
        fractalType: FractalType.mandelbulb,
      );
      final b = a.copyWith(fractalType: FractalType.julia);

      expect(a, isNot(equals(b)));
    });

    test('snapshots mutable vectors supplied by callers', () {
      final rotation = Vector3(0.1, 0.2, 0.3);
      final mousePos = Vector2(0.4, 0.5);
      final params = FractalParams(rotation: rotation, mousePos: mousePos);

      rotation.setValues(1.0, 2.0, 3.0);
      mousePos.setValues(4.0, 5.0);

      expect(params.rotation, Vector3(0.1, 0.2, 0.3));
      expect(params.mousePos, Vector2(0.4, 0.5));
    });

    test('exposes vector fields as immutable snapshots', () {
      final params = FractalParams(
        rotation: Vector3(0.1, 0.2, 0.3),
        mousePos: Vector2(0.4, 0.5),
      );

      final exposedRotation = params.rotation;
      final exposedMousePos = params.mousePos;
      exposedRotation.setValues(1.0, 2.0, 3.0);
      exposedMousePos.setValues(4.0, 5.0);

      expect(params.rotation, Vector3(0.1, 0.2, 0.3));
      expect(params.mousePos, Vector2(0.4, 0.5));
    });

    test('copyWith snapshots replacement vectors', () {
      final original = FractalParams(
        rotation: Vector3.zero(),
        mousePos: Vector2.zero(),
      );
      final replacementRotation = Vector3(0.1, 0.2, 0.3);
      final replacementMousePos = Vector2(0.4, 0.5);

      final copy = original.copyWith(
        rotation: replacementRotation,
        mousePos: replacementMousePos,
      );

      replacementRotation.setValues(1.0, 2.0, 3.0);
      replacementMousePos.setValues(4.0, 5.0);

      expect(copy.rotation, Vector3(0.1, 0.2, 0.3));
      expect(copy.mousePos, Vector2(0.4, 0.5));
      expect(original.rotation, Vector3.zero());
      expect(original.mousePos, Vector2.zero());
    });
  });
}
