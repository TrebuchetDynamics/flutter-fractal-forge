// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f0012_nova_fractal/f0012_nova_fractal_module.dart';

void main() {
  test('F0012NovaFractal instantiates', () {
    final m = F0012NovaFractal();
    expect(m.id, 'f0012_nova_fractal');
    expect(m.shader, 'shaders/f0012_nova_fractal_gpu.frag');
  });

  test('F0012NovaFractal presets are well-formed', () {
    final m = F0012NovaFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0012NovaFractal metadata is consistent', () {
    final m = F0012NovaFractal();
    expect(m.metadata.id, m.id);
  });
}
