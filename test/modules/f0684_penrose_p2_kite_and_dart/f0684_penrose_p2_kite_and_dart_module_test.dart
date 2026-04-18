// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0684_penrose_p2_kite_and_dart/f0684_penrose_p2_kite_and_dart_module.dart';

void main() {
  test('F0684PenroseP2KiteAndDart instantiates', () {
    final m = F0684PenroseP2KiteAndDart();
    expect(m.id, 'f0684_penrose_p2_kite_and_dart');
    expect(m.shader, 'shaders/f0684_penrose_p2_kite_and_dart_gpu.frag');
  });

  test('F0684PenroseP2KiteAndDart presets are well-formed', () {
    final m = F0684PenroseP2KiteAndDart();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0684PenroseP2KiteAndDart metadata is consistent', () {
    final m = F0684PenroseP2KiteAndDart();
    expect(m.metadata.id, m.id);
  });
}
