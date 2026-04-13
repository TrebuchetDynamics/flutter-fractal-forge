// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0270_n_flake_general/f0270_n_flake_general_module.dart';

void main() {
  test('F0270NFlakeGeneral instantiates', () {
    final m = F0270NFlakeGeneral();
    expect(m.id, 'f0270_n_flake_general');
    expect(m.shader, 'shaders/f0270_n_flake_general_gpu.frag');
  });

  test('F0270NFlakeGeneral presets are well-formed', () {
    final m = F0270NFlakeGeneral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0270NFlakeGeneral metadata is consistent', () {
    final m = F0270NFlakeGeneral();
    expect(m.metadata.id, m.id);
  });
}
