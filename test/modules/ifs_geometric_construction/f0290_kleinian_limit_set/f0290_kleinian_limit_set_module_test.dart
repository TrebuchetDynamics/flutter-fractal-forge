// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0290_kleinian_limit_set/f0290_kleinian_limit_set_module.dart';

void main() {
  test('F0290KleinianLimitSet instantiates', () {
    final m = F0290KleinianLimitSet();
    expect(m.id, 'f0290_kleinian_limit_set');
    expect(m.shader, 'shaders/f0290_kleinian_limit_set_gpu.frag');
  });

  test('F0290KleinianLimitSet presets are well-formed', () {
    final m = F0290KleinianLimitSet();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0290KleinianLimitSet metadata is consistent', () {
    final m = F0290KleinianLimitSet();
    expect(m.metadata.id, m.id);
  });
}
