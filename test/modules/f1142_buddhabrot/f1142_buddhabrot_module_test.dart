// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1142_buddhabrot/f1142_buddhabrot_module.dart';

void main() {
  test('F1142Buddhabrot instantiates', () {
    final m = F1142Buddhabrot();
    expect(m.id, 'f1142_buddhabrot');
    expect(m.shader, 'shaders/f1142_buddhabrot_gpu.frag');
  });

  test('F1142Buddhabrot presets are well-formed', () {
    final m = F1142Buddhabrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1142Buddhabrot metadata is consistent', () {
    final m = F1142Buddhabrot();
    expect(m.metadata.id, m.id);
  });
}
