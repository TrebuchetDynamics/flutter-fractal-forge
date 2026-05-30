// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0042_sprott_linz_j/f0042_sprott_linz_j_module.dart';

void main() {
  test('F0042SprottLinzJ instantiates', () {
    final m = F0042SprottLinzJ();
    expect(m.id, 'f0042_sprott_linz_j');
    expect(m.shader, 'shaders/f0042_sprott_linz_j_gpu.frag');
  });

  test('F0042SprottLinzJ presets are well-formed', () {
    final m = F0042SprottLinzJ();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0042SprottLinzJ metadata is consistent', () {
    final m = F0042SprottLinzJ();
    expect(m.metadata.id, m.id);
  });
}
