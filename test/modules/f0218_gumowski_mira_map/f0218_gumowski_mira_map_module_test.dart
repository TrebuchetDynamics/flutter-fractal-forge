// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0218_gumowski_mira_map/f0218_gumowski_mira_map_module.dart';

void main() {
  test('F0218GumowskiMiraMap instantiates', () {
    final m = F0218GumowskiMiraMap();
    expect(m.id, 'f0218_gumowski_mira_map');
    expect(m.shader, 'shaders/f0218_gumowski_mira_map_gpu.frag');
  });

  test('F0218GumowskiMiraMap presets are well-formed', () {
    final m = F0218GumowskiMiraMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0218GumowskiMiraMap metadata is consistent', () {
    final m = F0218GumowskiMiraMap();
    expect(m.metadata.id, m.id);
  });
}
