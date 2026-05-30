// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0035_sprott_linz_c/f0035_sprott_linz_c_module.dart';

void main() {
  test('F0035SprottLinzC instantiates', () {
    final m = F0035SprottLinzC();
    expect(m.id, 'f0035_sprott_linz_c');
    expect(m.shader, 'shaders/f0035_sprott_linz_c_gpu.frag');
  });

  test('F0035SprottLinzC presets are well-formed', () {
    final m = F0035SprottLinzC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0035SprottLinzC metadata is consistent', () {
    final m = F0035SprottLinzC();
    expect(m.metadata.id, m.id);
  });
}
