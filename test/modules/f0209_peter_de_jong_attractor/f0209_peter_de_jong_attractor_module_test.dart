// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0209_peter_de_jong_attractor/f0209_peter_de_jong_attractor_module.dart';

void main() {
  test('F0209PeterDeJongAttractor instantiates', () {
    final m = F0209PeterDeJongAttractor();
    expect(m.id, 'f0209_peter_de_jong_attractor');
    expect(m.shader, 'shaders/f0209_peter_de_jong_attractor_gpu.frag');
  });

  test('F0209PeterDeJongAttractor presets are well-formed', () {
    final m = F0209PeterDeJongAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0209PeterDeJongAttractor metadata is consistent', () {
    final m = F0209PeterDeJongAttractor();
    expect(m.metadata.id, m.id);
  });
}
