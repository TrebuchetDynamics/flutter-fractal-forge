// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1211_nova_z_7_1/f1211_nova_z_7_1_module.dart';

void main() {
  test('F1211NovaZ71 instantiates', () {
    final m = F1211NovaZ71();
    expect(m.id, 'f1211_nova_z_7_1');
    expect(m.shader, 'shaders/f1211_nova_z_7_1_gpu.frag');
  });

  test('F1211NovaZ71 presets are well-formed', () {
    final m = F1211NovaZ71();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1211NovaZ71 metadata is consistent', () {
    final m = F1211NovaZ71();
    expect(m.metadata.id, m.id);
  });
}
