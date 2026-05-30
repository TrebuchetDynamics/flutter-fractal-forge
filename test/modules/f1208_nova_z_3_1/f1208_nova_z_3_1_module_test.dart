// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1208_nova_z_3_1/f1208_nova_z_3_1_module.dart';

void main() {
  test('F1208NovaZ31 instantiates', () {
    final m = F1208NovaZ31();
    expect(m.id, 'f1208_nova_z_3_1');
    expect(m.shader, 'shaders/f1208_nova_z_3_1_gpu.frag');
  });

  test('F1208NovaZ31 presets are well-formed', () {
    final m = F1208NovaZ31();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1208NovaZ31 metadata is consistent', () {
    final m = F1208NovaZ31();
    expect(m.metadata.id, m.id);
  });
}
