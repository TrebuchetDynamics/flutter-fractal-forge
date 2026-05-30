// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1003_plow_world_b378_s012345678/f1003_plow_world_b378_s012345678_module.dart';

void main() {
  test('F1003PlowWorldB378S012345678 instantiates', () {
    final m = F1003PlowWorldB378S012345678();
    expect(m.id, 'f1003_plow_world_b378_s012345678');
    expect(m.shader, 'shaders/f1003_plow_world_b378_s012345678_gpu.frag');
  });

  test('F1003PlowWorldB378S012345678 presets are well-formed', () {
    final m = F1003PlowWorldB378S012345678();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1003PlowWorldB378S012345678 metadata is consistent', () {
    final m = F1003PlowWorldB378S012345678();
    expect(m.metadata.id, m.id);
  });
}
