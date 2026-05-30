// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0040_sprott_linz_h/f0040_sprott_linz_h_module.dart';

void main() {
  test('F0040SprottLinzH instantiates', () {
    final m = F0040SprottLinzH();
    expect(m.id, 'f0040_sprott_linz_h');
    expect(m.shader, 'shaders/f0040_sprott_linz_h_gpu.frag');
  });

  test('F0040SprottLinzH presets are well-formed', () {
    final m = F0040SprottLinzH();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0040SprottLinzH metadata is consistent', () {
    final m = F0040SprottLinzH();
    expect(m.metadata.id, m.id);
  });
}
