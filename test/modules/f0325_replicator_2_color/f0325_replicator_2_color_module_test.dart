// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0325_replicator_2_color/f0325_replicator_2_color_module.dart';

void main() {
  test('F0325Replicator2Color instantiates', () {
    final m = F0325Replicator2Color();
    expect(m.id, 'f0325_replicator_2_color');
    expect(m.shader, 'shaders/f0325_replicator_2_color_gpu.frag');
  });

  test('F0325Replicator2Color presets are well-formed', () {
    final m = F0325Replicator2Color();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0325Replicator2Color metadata is consistent', () {
    final m = F0325Replicator2Color();
    expect(m.metadata.id, m.id);
  });
}
