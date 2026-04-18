// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1006_slow_stains_b36_s378/f1006_slow_stains_b36_s378_module.dart';

void main() {
  test('F1006SlowStainsB36S378 instantiates', () {
    final m = F1006SlowStainsB36S378();
    expect(m.id, 'f1006_slow_stains_b36_s378');
    expect(m.shader, 'shaders/f1006_slow_stains_b36_s378_gpu.frag');
  });

  test('F1006SlowStainsB36S378 presets are well-formed', () {
    final m = F1006SlowStainsB36S378();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1006SlowStainsB36S378 metadata is consistent', () {
    final m = F1006SlowStainsB36S378();
    expect(m.metadata.id, m.id);
  });
}
