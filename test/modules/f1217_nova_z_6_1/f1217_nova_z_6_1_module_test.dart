// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1217_nova_z_6_1/f1217_nova_z_6_1_module.dart';

void main() {
  test('F1217NovaZ61 instantiates', () {
    final m = F1217NovaZ61();
    expect(m.id, 'f1217_nova_z_6_1');
    expect(m.shader, 'shaders/f1217_nova_z_6_1_gpu.frag');
  });

  test('F1217NovaZ61 presets are well-formed', () {
    final m = F1217NovaZ61();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1217NovaZ61 metadata is consistent', () {
    final m = F1217NovaZ61();
    expect(m.metadata.id, m.id);
  });
}
