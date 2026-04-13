// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0049_lorenz_96/f0049_lorenz_96_module.dart';

void main() {
  test('F0049Lorenz96 instantiates', () {
    final m = F0049Lorenz96();
    expect(m.id, 'f0049_lorenz_96');
    expect(m.shader, 'shaders/f0049_lorenz_96_gpu.frag');
  });

  test('F0049Lorenz96 presets are well-formed', () {
    final m = F0049Lorenz96();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0049Lorenz96 metadata is consistent', () {
    final m = F0049Lorenz96();
    expect(m.metadata.id, m.id);
  });
}
