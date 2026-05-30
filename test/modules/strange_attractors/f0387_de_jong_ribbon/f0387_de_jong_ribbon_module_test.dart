// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0387_de_jong_ribbon/f0387_de_jong_ribbon_module.dart';

void main() {
  test('F0387DeJongRibbon instantiates', () {
    final m = F0387DeJongRibbon();
    expect(m.id, 'f0387_de_jong_ribbon');
    expect(m.shader, 'shaders/f0387_de_jong_ribbon_gpu.frag');
  });

  test('F0387DeJongRibbon presets are well-formed', () {
    final m = F0387DeJongRibbon();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0387DeJongRibbon metadata is consistent', () {
    final m = F0387DeJongRibbon();
    expect(m.metadata.id, m.id);
  });
}
