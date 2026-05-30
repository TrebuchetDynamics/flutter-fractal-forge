// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0155_period_4_julia/f0155_period_4_julia_module.dart';

void main() {
  test('F0155Period4Julia instantiates', () {
    final m = F0155Period4Julia();
    expect(m.id, 'f0155_period_4_julia');
    expect(m.shader, 'shaders/f0155_period_4_julia_gpu.frag');
  });

  test('F0155Period4Julia presets are well-formed', () {
    final m = F0155Period4Julia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0155Period4Julia metadata is consistent', () {
    final m = F0155Period4Julia();
    expect(m.metadata.id, m.id);
  });
}
