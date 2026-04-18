// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1084_bogdanov_chaos/f1084_bogdanov_chaos_module.dart';

void main() {
  test('F1084BogdanovChaos instantiates', () {
    final m = F1084BogdanovChaos();
    expect(m.id, 'f1084_bogdanov_chaos');
    expect(m.shader, 'shaders/f1084_bogdanov_chaos_gpu.frag');
  });

  test('F1084BogdanovChaos presets are well-formed', () {
    final m = F1084BogdanovChaos();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1084BogdanovChaos metadata is consistent', () {
    final m = F1084BogdanovChaos();
    expect(m.metadata.id, m.id);
  });
}
