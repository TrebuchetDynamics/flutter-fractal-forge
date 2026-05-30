// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0985_2x2_b36_s125/f0985_2x2_b36_s125_module.dart';

void main() {
  test('F09852x2B36S125 instantiates', () {
    final m = F09852x2B36S125();
    expect(m.id, 'f0985_2x2_b36_s125');
    expect(m.shader, 'shaders/f0985_2x2_b36_s125_gpu.frag');
  });

  test('F09852x2B36S125 presets are well-formed', () {
    final m = F09852x2B36S125();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F09852x2B36S125 metadata is consistent', () {
    final m = F09852x2B36S125();
    expect(m.metadata.id, m.id);
  });
}
