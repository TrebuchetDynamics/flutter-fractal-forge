// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0236_octogree/f0236_octogree_module.dart';

void main() {
  test('F0236Octogree instantiates', () {
    final m = F0236Octogree();
    expect(m.id, 'f0236_octogree');
    expect(m.shader, 'shaders/f0236_octogree_gpu.frag');
  });

  test('F0236Octogree presets are well-formed', () {
    final m = F0236Octogree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0236Octogree metadata is consistent', () {
    final m = F0236Octogree();
    expect(m.metadata.id, m.id);
  });
}
