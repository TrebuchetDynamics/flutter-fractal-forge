// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1216_nova_z_4_z_1/f1216_nova_z_4_z_1_module.dart';

void main() {
  test('F1216NovaZ4Z1 instantiates', () {
    final m = F1216NovaZ4Z1();
    expect(m.id, 'f1216_nova_z_4_z_1');
    expect(m.shader, 'shaders/f1216_nova_z_4_z_1_gpu.frag');
  });

  test('F1216NovaZ4Z1 presets are well-formed', () {
    final m = F1216NovaZ4Z1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1216NovaZ4Z1 metadata is consistent', () {
    final m = F1216NovaZ4Z1();
    expect(m.metadata.id, m.id);
  });
}
