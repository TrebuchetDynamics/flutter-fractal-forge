// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0210_svensson_attractor/f0210_svensson_attractor_module.dart';

void main() {
  test('F0210SvenssonAttractor instantiates', () {
    final m = F0210SvenssonAttractor();
    expect(m.id, 'f0210_svensson_attractor');
    expect(m.shader, 'shaders/f0210_svensson_attractor_gpu.frag');
  });

  test('F0210SvenssonAttractor presets are well-formed', () {
    final m = F0210SvenssonAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0210SvenssonAttractor metadata is consistent', () {
    final m = F0210SvenssonAttractor();
    expect(m.metadata.id, m.id);
  });
}
