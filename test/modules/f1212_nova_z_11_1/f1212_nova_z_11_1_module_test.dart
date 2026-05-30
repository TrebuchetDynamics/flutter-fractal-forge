// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1212_nova_z_11_1/f1212_nova_z_11_1_module.dart';

void main() {
  test('F1212NovaZ111 instantiates', () {
    final m = F1212NovaZ111();
    expect(m.id, 'f1212_nova_z_11_1');
    expect(m.shader, 'shaders/f1212_nova_z_11_1_gpu.frag');
  });

  test('F1212NovaZ111 presets are well-formed', () {
    final m = F1212NovaZ111();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1212NovaZ111 metadata is consistent', () {
    final m = F1212NovaZ111();
    expect(m.metadata.id, m.id);
  });
}
