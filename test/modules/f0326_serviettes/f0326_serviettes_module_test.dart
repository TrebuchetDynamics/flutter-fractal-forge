// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0326_serviettes/f0326_serviettes_module.dart';

void main() {
  test('F0326Serviettes instantiates', () {
    final m = F0326Serviettes();
    expect(m.id, 'f0326_serviettes');
    expect(m.shader, 'shaders/f0326_serviettes_gpu.frag');
  });

  test('F0326Serviettes presets are well-formed', () {
    final m = F0326Serviettes();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0326Serviettes metadata is consistent', () {
    final m = F0326Serviettes();
    expect(m.metadata.id, m.id);
  });
}
