// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0417_gumowski_mira_peacock/f0417_gumowski_mira_peacock_module.dart';

void main() {
  test('F0417GumowskiMiraPeacock instantiates', () {
    final m = F0417GumowskiMiraPeacock();
    expect(m.id, 'f0417_gumowski_mira_peacock');
    expect(m.shader, 'shaders/f0417_gumowski_mira_peacock_gpu.frag');
  });

  test('F0417GumowskiMiraPeacock presets are well-formed', () {
    final m = F0417GumowskiMiraPeacock();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0417GumowskiMiraPeacock metadata is consistent', () {
    final m = F0417GumowskiMiraPeacock();
    expect(m.metadata.id, m.id);
  });
}
