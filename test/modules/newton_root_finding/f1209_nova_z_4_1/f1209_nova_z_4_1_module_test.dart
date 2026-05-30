// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1209_nova_z_4_1/f1209_nova_z_4_1_module.dart';

void main() {
  test('F1209NovaZ41 instantiates', () {
    final m = F1209NovaZ41();
    expect(m.id, 'f1209_nova_z_4_1');
    expect(m.shader, 'shaders/f1209_nova_z_4_1_gpu.frag');
  });

  test('F1209NovaZ41 presets are well-formed', () {
    final m = F1209NovaZ41();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1209NovaZ41 metadata is consistent', () {
    final m = F1209NovaZ41();
    expect(m.metadata.id, m.id);
  });
}
