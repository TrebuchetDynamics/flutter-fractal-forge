// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0156_period_5_julia/f0156_period_5_julia_module.dart';

void main() {
  test('F0156Period5Julia instantiates', () {
    final m = F0156Period5Julia();
    expect(m.id, 'f0156_period_5_julia');
    expect(m.shader, 'shaders/f0156_period_5_julia_gpu.frag');
  });

  test('F0156Period5Julia presets are well-formed', () {
    final m = F0156Period5Julia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0156Period5Julia metadata is consistent', () {
    final m = F0156Period5Julia();
    expect(m.metadata.id, m.id);
  });
}
