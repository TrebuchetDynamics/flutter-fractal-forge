import 'package:flutter_fractals/core/models/fractal_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('FractalParams equality includes fractalType', () {
    final a = FractalParams(
      rotation: Vector3.zero(),
      mousePos: Vector2.zero(),
      fractalType: FractalType.mandelbulb,
    );
    final b = a.copyWith(fractalType: FractalType.julia);

    expect(a, isNot(equals(b)));
  });
}
