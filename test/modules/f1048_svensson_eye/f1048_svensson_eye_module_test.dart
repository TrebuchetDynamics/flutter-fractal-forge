// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1048_svensson_eye/f1048_svensson_eye_module.dart';

void main() {
  test('F1048SvenssonEye instantiates', () {
    final m = F1048SvenssonEye();
    expect(m.id, 'f1048_svensson_eye');
    expect(m.shader, 'shaders/f1048_svensson_eye_gpu.frag');
  });

  test('F1048SvenssonEye presets are well-formed', () {
    final m = F1048SvenssonEye();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1048SvenssonEye metadata is consistent', () {
    final m = F1048SvenssonEye();
    expect(m.metadata.id, m.id);
  });
}
