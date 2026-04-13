// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0059_shimizu_morioka/f0059_shimizu_morioka_module.dart';

void main() {
  test('F0059ShimizuMorioka instantiates', () {
    final m = F0059ShimizuMorioka();
    expect(m.id, 'f0059_shimizu_morioka');
    expect(m.shader, 'shaders/f0059_shimizu_morioka_gpu.frag');
  });

  test('F0059ShimizuMorioka presets are well-formed', () {
    final m = F0059ShimizuMorioka();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0059ShimizuMorioka metadata is consistent', () {
    final m = F0059ShimizuMorioka();
    expect(m.metadata.id, m.id);
  });
}
