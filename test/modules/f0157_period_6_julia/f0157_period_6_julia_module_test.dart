// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0157_period_6_julia/f0157_period_6_julia_module.dart';

void main() {
  test('F0157Period6Julia instantiates', () {
    final m = F0157Period6Julia();
    expect(m.id, 'f0157_period_6_julia');
    expect(m.shader, 'shaders/f0157_period_6_julia_gpu.frag');
  });

  test('F0157Period6Julia presets are well-formed', () {
    final m = F0157Period6Julia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0157Period6Julia metadata is consistent', () {
    final m = F0157Period6Julia();
    expect(m.metadata.id, m.id);
  });
}
