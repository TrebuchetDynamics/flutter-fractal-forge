// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0025_sprott_l/f0025_sprott_l_module.dart';

void main() {
  test('F0025SprottL instantiates', () {
    final m = F0025SprottL();
    expect(m.id, 'f0025_sprott_l');
    expect(m.shader, 'shaders/f0025_sprott_l_gpu.frag');
  });

  test('F0025SprottL presets are well-formed', () {
    final m = F0025SprottL();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0025SprottL metadata is consistent', () {
    final m = F0025SprottL();
    expect(m.metadata.id, m.id);
  });
}
