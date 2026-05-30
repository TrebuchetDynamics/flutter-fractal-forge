// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1192_newton_z_3_z/f1192_newton_z_3_z_module.dart';

void main() {
  test('F1192NewtonZ3Z instantiates', () {
    final m = F1192NewtonZ3Z();
    expect(m.id, 'f1192_newton_z_3_z');
    expect(m.shader, 'shaders/f1192_newton_z_3_z_gpu.frag');
  });

  test('F1192NewtonZ3Z presets are well-formed', () {
    final m = F1192NewtonZ3Z();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1192NewtonZ3Z metadata is consistent', () {
    final m = F1192NewtonZ3Z();
    expect(m.metadata.id, m.id);
  });
}
