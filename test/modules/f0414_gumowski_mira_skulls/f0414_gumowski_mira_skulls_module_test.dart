// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0414_gumowski_mira_skulls/f0414_gumowski_mira_skulls_module.dart';

void main() {
  test('F0414GumowskiMiraSkulls instantiates', () {
    final m = F0414GumowskiMiraSkulls();
    expect(m.id, 'f0414_gumowski_mira_skulls');
    expect(m.shader, 'shaders/f0414_gumowski_mira_skulls_gpu.frag');
  });

  test('F0414GumowskiMiraSkulls presets are well-formed', () {
    final m = F0414GumowskiMiraSkulls();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0414GumowskiMiraSkulls metadata is consistent', () {
    final m = F0414GumowskiMiraSkulls();
    expect(m.metadata.id, m.id);
  });
}
