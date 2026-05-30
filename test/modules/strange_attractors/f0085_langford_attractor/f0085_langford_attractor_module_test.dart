// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0085_langford_attractor/f0085_langford_attractor_module.dart';

void main() {
  test('F0085LangfordAttractor instantiates', () {
    final m = F0085LangfordAttractor();
    expect(m.id, 'f0085_langford_attractor');
    expect(m.shader, 'shaders/f0085_langford_attractor_gpu.frag');
  });

  test('F0085LangfordAttractor presets are well-formed', () {
    final m = F0085LangfordAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0085LangfordAttractor metadata is consistent', () {
    final m = F0085LangfordAttractor();
    expect(m.metadata.id, m.id);
  });
}
