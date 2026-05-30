// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1232_elliptic_function_julia/f1232_elliptic_function_julia_module.dart';

void main() {
  test('F1232EllipticFunctionJulia instantiates', () {
    final m = F1232EllipticFunctionJulia();
    expect(m.id, 'f1232_elliptic_function_julia');
    expect(m.shader, 'shaders/f1232_elliptic_function_julia_gpu.frag');
  });

  test('F1232EllipticFunctionJulia presets are well-formed', () {
    final m = F1232EllipticFunctionJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1232EllipticFunctionJulia metadata is consistent', () {
    final m = F1232EllipticFunctionJulia();
    expect(m.metadata.id, m.id);
  });
}
