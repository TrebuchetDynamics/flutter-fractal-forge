// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1144_nebulabrot/f1144_nebulabrot_module.dart';

void main() {
  test('F1144Nebulabrot instantiates', () {
    final m = F1144Nebulabrot();
    expect(m.id, 'f1144_nebulabrot');
    expect(m.shader, 'shaders/f1144_nebulabrot_gpu.frag');
  });

  test('F1144Nebulabrot presets are well-formed', () {
    final m = F1144Nebulabrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1144Nebulabrot metadata is consistent', () {
    final m = F1144Nebulabrot();
    expect(m.metadata.id, m.id);
  });
}
