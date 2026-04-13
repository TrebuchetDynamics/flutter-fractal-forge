// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0158_period_7_julia/f0158_period_7_julia_module.dart';

void main() {
  test('F0158Period7Julia instantiates', () {
    final m = F0158Period7Julia();
    expect(m.id, 'f0158_period_7_julia');
    expect(m.shader, 'shaders/f0158_period_7_julia_gpu.frag');
  });

  test('F0158Period7Julia presets are well-formed', () {
    final m = F0158Period7Julia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0158Period7Julia metadata is consistent', () {
    final m = F0158Period7Julia();
    expect(m.metadata.id, m.id);
  });
}
