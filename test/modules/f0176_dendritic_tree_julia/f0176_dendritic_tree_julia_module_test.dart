// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0176_dendritic_tree_julia/f0176_dendritic_tree_julia_module.dart';

void main() {
  test('F0176DendriticTreeJulia instantiates', () {
    final m = F0176DendriticTreeJulia();
    expect(m.id, 'f0176_dendritic_tree_julia');
    expect(m.shader, 'shaders/f0176_dendritic_tree_julia_gpu.frag');
  });

  test('F0176DendriticTreeJulia presets are well-formed', () {
    final m = F0176DendriticTreeJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0176DendriticTreeJulia metadata is consistent', () {
    final m = F0176DendriticTreeJulia();
    expect(m.metadata.id, m.id);
  });
}
