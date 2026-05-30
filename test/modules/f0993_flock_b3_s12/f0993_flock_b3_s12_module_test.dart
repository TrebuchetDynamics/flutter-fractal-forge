// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0993_flock_b3_s12/f0993_flock_b3_s12_module.dart';

void main() {
  test('F0993FlockB3S12 instantiates', () {
    final m = F0993FlockB3S12();
    expect(m.id, 'f0993_flock_b3_s12');
    expect(m.shader, 'shaders/f0993_flock_b3_s12_gpu.frag');
  });

  test('F0993FlockB3S12 presets are well-formed', () {
    final m = F0993FlockB3S12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0993FlockB3S12 metadata is consistent', () {
    final m = F0993FlockB3S12();
    expect(m.metadata.id, m.id);
  });
}
