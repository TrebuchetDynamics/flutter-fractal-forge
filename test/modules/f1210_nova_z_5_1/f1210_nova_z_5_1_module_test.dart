// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1210_nova_z_5_1/f1210_nova_z_5_1_module.dart';

void main() {
  test('F1210NovaZ51 instantiates', () {
    final m = F1210NovaZ51();
    expect(m.id, 'f1210_nova_z_5_1');
    expect(m.shader, 'shaders/f1210_nova_z_5_1_gpu.frag');
  });

  test('F1210NovaZ51 presets are well-formed', () {
    final m = F1210NovaZ51();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1210NovaZ51 metadata is consistent', () {
    final m = F1210NovaZ51();
    expect(m.metadata.id, m.id);
  });
}
