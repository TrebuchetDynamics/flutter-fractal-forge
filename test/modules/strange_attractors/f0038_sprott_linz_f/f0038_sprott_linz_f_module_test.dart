// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0038_sprott_linz_f/f0038_sprott_linz_f_module.dart';

void main() {
  test('F0038SprottLinzF instantiates', () {
    final m = F0038SprottLinzF();
    expect(m.id, 'f0038_sprott_linz_f');
    expect(m.shader, 'shaders/f0038_sprott_linz_f_gpu.frag');
  });

  test('F0038SprottLinzF presets are well-formed', () {
    final m = F0038SprottLinzF();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0038SprottLinzF metadata is consistent', () {
    final m = F0038SprottLinzF();
    expect(m.metadata.id, m.id);
  });
}
