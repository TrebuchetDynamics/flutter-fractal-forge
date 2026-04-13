// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0154_period_3_julia/f0154_period_3_julia_module.dart';

void main() {
  test('F0154Period3Julia instantiates', () {
    final m = F0154Period3Julia();
    expect(m.id, 'f0154_period_3_julia');
    expect(m.shader, 'shaders/f0154_period_3_julia_gpu.frag');
  });

  test('F0154Period3Julia presets are well-formed', () {
    final m = F0154Period3Julia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0154Period3Julia metadata is consistent', () {
    final m = F0154Period3Julia();
    expect(m.metadata.id, m.id);
  });
}
