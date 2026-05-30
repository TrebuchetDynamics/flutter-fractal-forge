// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0421_gumowski_mira_lace/f0421_gumowski_mira_lace_module.dart';

void main() {
  test('F0421GumowskiMiraLace instantiates', () {
    final m = F0421GumowskiMiraLace();
    expect(m.id, 'f0421_gumowski_mira_lace');
    expect(m.shader, 'shaders/f0421_gumowski_mira_lace_gpu.frag');
  });

  test('F0421GumowskiMiraLace presets are well-formed', () {
    final m = F0421GumowskiMiraLace();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0421GumowskiMiraLace metadata is consistent', () {
    final m = F0421GumowskiMiraLace();
    expect(m.metadata.id, m.id);
  });
}
