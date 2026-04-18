// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0698_sphinx_tiling/f0698_sphinx_tiling_module.dart';

void main() {
  test('F0698SphinxTiling instantiates', () {
    final m = F0698SphinxTiling();
    expect(m.id, 'f0698_sphinx_tiling');
    expect(m.shader, 'shaders/f0698_sphinx_tiling_gpu.frag');
  });

  test('F0698SphinxTiling presets are well-formed', () {
    final m = F0698SphinxTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0698SphinxTiling metadata is consistent', () {
    final m = F0698SphinxTiling();
    expect(m.metadata.id, m.id);
  });
}
