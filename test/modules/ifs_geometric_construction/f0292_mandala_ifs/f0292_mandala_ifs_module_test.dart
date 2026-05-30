// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0292_mandala_ifs/f0292_mandala_ifs_module.dart';

void main() {
  test('F0292MandalaIfs instantiates', () {
    final m = F0292MandalaIfs();
    expect(m.id, 'f0292_mandala_ifs');
    expect(m.shader, 'shaders/f0292_mandala_ifs_gpu.frag');
  });

  test('F0292MandalaIfs presets are well-formed', () {
    final m = F0292MandalaIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0292MandalaIfs metadata is consistent', () {
    final m = F0292MandalaIfs();
    expect(m.metadata.id, m.id);
  });
}
