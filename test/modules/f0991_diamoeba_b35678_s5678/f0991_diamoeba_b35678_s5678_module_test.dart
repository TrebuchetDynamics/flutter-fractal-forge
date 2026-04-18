// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0991_diamoeba_b35678_s5678/f0991_diamoeba_b35678_s5678_module.dart';

void main() {
  test('F0991DiamoebaB35678S5678 instantiates', () {
    final m = F0991DiamoebaB35678S5678();
    expect(m.id, 'f0991_diamoeba_b35678_s5678');
    expect(m.shader, 'shaders/f0991_diamoeba_b35678_s5678_gpu.frag');
  });

  test('F0991DiamoebaB35678S5678 presets are well-formed', () {
    final m = F0991DiamoebaB35678S5678();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0991DiamoebaB35678S5678 metadata is consistent', () {
    final m = F0991DiamoebaB35678S5678();
    expect(m.metadata.id, m.id);
  });
}
