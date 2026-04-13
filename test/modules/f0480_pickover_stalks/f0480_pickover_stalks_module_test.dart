// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0480_pickover_stalks/f0480_pickover_stalks_module.dart';

void main() {
  test('F0480PickoverStalks instantiates', () {
    final m = F0480PickoverStalks();
    expect(m.id, 'f0480_pickover_stalks');
    expect(m.shader, 'shaders/f0480_pickover_stalks_gpu.frag');
  });

  test('F0480PickoverStalks presets are well-formed', () {
    final m = F0480PickoverStalks();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0480PickoverStalks metadata is consistent', () {
    final m = F0480PickoverStalks();
    expect(m.metadata.id, m.id);
  });
}
