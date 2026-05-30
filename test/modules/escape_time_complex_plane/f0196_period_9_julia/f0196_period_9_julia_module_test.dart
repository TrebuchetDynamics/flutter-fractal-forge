// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0196_period_9_julia/f0196_period_9_julia_module.dart';

void main() {
  test('F0196Period9Julia instantiates', () {
    final m = F0196Period9Julia();
    expect(m.id, 'f0196_period_9_julia');
    expect(m.shader, 'shaders/f0196_period_9_julia_gpu.frag');
  });

  test('F0196Period9Julia presets are well-formed', () {
    final m = F0196Period9Julia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0196Period9Julia metadata is consistent', () {
    final m = F0196Period9Julia();
    expect(m.metadata.id, m.id);
  });
}
