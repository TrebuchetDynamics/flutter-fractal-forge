// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0195_period_8_julia/f0195_period_8_julia_module.dart';

void main() {
  test('F0195Period8Julia instantiates', () {
    final m = F0195Period8Julia();
    expect(m.id, 'f0195_period_8_julia');
    expect(m.shader, 'shaders/f0195_period_8_julia_gpu.frag');
  });

  test('F0195Period8Julia presets are well-formed', () {
    final m = F0195Period8Julia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0195Period8Julia metadata is consistent', () {
    final m = F0195Period8Julia();
    expect(m.metadata.id, m.id);
  });
}
