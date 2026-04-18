// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0715_rauzy_fractal_tiling/f0715_rauzy_fractal_tiling_module.dart';

void main() {
  test('F0715RauzyFractalTiling instantiates', () {
    final m = F0715RauzyFractalTiling();
    expect(m.id, 'f0715_rauzy_fractal_tiling');
    expect(m.shader, 'shaders/f0715_rauzy_fractal_tiling_gpu.frag');
  });

  test('F0715RauzyFractalTiling presets are well-formed', () {
    final m = F0715RauzyFractalTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0715RauzyFractalTiling metadata is consistent', () {
    final m = F0715RauzyFractalTiling();
    expect(m.metadata.id, m.id);
  });
}
