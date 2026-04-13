// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0254_pentaplexity/f0254_pentaplexity_module.dart';

void main() {
  test('F0254Pentaplexity instantiates', () {
    final m = F0254Pentaplexity();
    expect(m.id, 'f0254_pentaplexity');
    expect(m.shader, 'shaders/f0254_pentaplexity_gpu.frag');
  });

  test('F0254Pentaplexity presets are well-formed', () {
    final m = F0254Pentaplexity();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0254Pentaplexity metadata is consistent', () {
    final m = F0254Pentaplexity();
    expect(m.metadata.id, m.id);
  });
}
