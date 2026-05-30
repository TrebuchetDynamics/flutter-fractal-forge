// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0819_arnold_tongues_bifurcation/f0819_arnold_tongues_bifurcation_module.dart';

void main() {
  test('F0819ArnoldTonguesBifurcation instantiates', () {
    final m = F0819ArnoldTonguesBifurcation();
    expect(m.id, 'f0819_arnold_tongues_bifurcation');
    expect(m.shader, 'shaders/f0819_arnold_tongues_bifurcation_gpu.frag');
  });

  test('F0819ArnoldTonguesBifurcation presets are well-formed', () {
    final m = F0819ArnoldTonguesBifurcation();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0819ArnoldTonguesBifurcation metadata is consistent', () {
    final m = F0819ArnoldTonguesBifurcation();
    expect(m.metadata.id, m.id);
  });
}
