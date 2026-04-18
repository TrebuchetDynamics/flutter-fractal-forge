// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1143_anti_buddhabrot/f1143_anti_buddhabrot_module.dart';

void main() {
  test('F1143AntiBuddhabrot instantiates', () {
    final m = F1143AntiBuddhabrot();
    expect(m.id, 'f1143_anti_buddhabrot');
    expect(m.shader, 'shaders/f1143_anti_buddhabrot_gpu.frag');
  });

  test('F1143AntiBuddhabrot presets are well-formed', () {
    final m = F1143AntiBuddhabrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1143AntiBuddhabrot metadata is consistent', () {
    final m = F1143AntiBuddhabrot();
    expect(m.metadata.id, m.id);
  });
}
