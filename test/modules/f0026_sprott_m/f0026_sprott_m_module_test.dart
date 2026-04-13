// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0026_sprott_m/f0026_sprott_m_module.dart';

void main() {
  test('F0026SprottM instantiates', () {
    final m = F0026SprottM();
    expect(m.id, 'f0026_sprott_m');
    expect(m.shader, 'shaders/f0026_sprott_m_gpu.frag');
  });

  test('F0026SprottM presets are well-formed', () {
    final m = F0026SprottM();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0026SprottM metadata is consistent', () {
    final m = F0026SprottM();
    expect(m.metadata.id, m.id);
  });
}
