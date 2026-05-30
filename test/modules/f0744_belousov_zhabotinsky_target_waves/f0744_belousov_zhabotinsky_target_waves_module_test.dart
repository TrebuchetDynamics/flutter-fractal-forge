// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0744_belousov_zhabotinsky_target_waves/f0744_belousov_zhabotinsky_target_waves_module.dart';

void main() {
  test('F0744BelousovZhabotinskyTargetWaves instantiates', () {
    final m = F0744BelousovZhabotinskyTargetWaves();
    expect(m.id, 'f0744_belousov_zhabotinsky_target_waves');
    expect(
        m.shader, 'shaders/f0744_belousov_zhabotinsky_target_waves_gpu.frag');
  });

  test('F0744BelousovZhabotinskyTargetWaves presets are well-formed', () {
    final m = F0744BelousovZhabotinskyTargetWaves();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0744BelousovZhabotinskyTargetWaves metadata is consistent', () {
    final m = F0744BelousovZhabotinskyTargetWaves();
    expect(m.metadata.id, m.id);
  });
}
