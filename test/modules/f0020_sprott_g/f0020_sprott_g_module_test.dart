// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0020_sprott_g/f0020_sprott_g_module.dart';

void main() {
  test('F0020SprottG instantiates', () {
    final m = F0020SprottG();
    expect(m.id, 'f0020_sprott_g');
    expect(m.shader, 'shaders/f0020_sprott_g_gpu.frag');
  });

  test('F0020SprottG presets are well-formed', () {
    final m = F0020SprottG();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0020SprottG metadata is consistent', () {
    final m = F0020SprottG();
    expect(m.metadata.id, m.id);
  });
}
