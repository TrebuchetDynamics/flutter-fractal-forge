// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1214_nova_z_5_z_2_1/f1214_nova_z_5_z_2_1_module.dart';

void main() {
  test('F1214NovaZ5Z21 instantiates', () {
    final m = F1214NovaZ5Z21();
    expect(m.id, 'f1214_nova_z_5_z_2_1');
    expect(m.shader, 'shaders/f1214_nova_z_5_z_2_1_gpu.frag');
  });

  test('F1214NovaZ5Z21 presets are well-formed', () {
    final m = F1214NovaZ5Z21();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1214NovaZ5Z21 metadata is consistent', () {
    final m = F1214NovaZ5Z21();
    expect(m.metadata.id, m.id);
  });
}
