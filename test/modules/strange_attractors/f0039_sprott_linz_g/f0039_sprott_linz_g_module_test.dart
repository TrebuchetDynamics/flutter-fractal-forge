// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0039_sprott_linz_g/f0039_sprott_linz_g_module.dart';

void main() {
  test('F0039SprottLinzG instantiates', () {
    final m = F0039SprottLinzG();
    expect(m.id, 'f0039_sprott_linz_g');
    expect(m.shader, 'shaders/f0039_sprott_linz_g_gpu.frag');
  });

  test('F0039SprottLinzG presets are well-formed', () {
    final m = F0039SprottLinzG();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0039SprottLinzG metadata is consistent', () {
    final m = F0039SprottLinzG();
    expect(m.metadata.id, m.id);
  });
}
