// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0285_coastline_ifs/f0285_coastline_ifs_module.dart';

void main() {
  test('F0285CoastlineIfs instantiates', () {
    final m = F0285CoastlineIfs();
    expect(m.id, 'f0285_coastline_ifs');
    expect(m.shader, 'shaders/f0285_coastline_ifs_gpu.frag');
  });

  test('F0285CoastlineIfs presets are well-formed', () {
    final m = F0285CoastlineIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0285CoastlineIfs metadata is consistent', () {
    final m = F0285CoastlineIfs();
    expect(m.metadata.id, m.id);
  });
}
