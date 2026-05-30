// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1188_newton_z_7_1/f1188_newton_z_7_1_module.dart';

void main() {
  test('F1188NewtonZ71 instantiates', () {
    final m = F1188NewtonZ71();
    expect(m.id, 'f1188_newton_z_7_1');
    expect(m.shader, 'shaders/f1188_newton_z_7_1_gpu.frag');
  });

  test('F1188NewtonZ71 presets are well-formed', () {
    final m = F1188NewtonZ71();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1188NewtonZ71 metadata is consistent', () {
    final m = F1188NewtonZ71();
    expect(m.metadata.id, m.id);
  });
}
