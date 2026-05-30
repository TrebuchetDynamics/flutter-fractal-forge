// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1059_svensson_mist/f1059_svensson_mist_module.dart';

void main() {
  test('F1059SvenssonMist instantiates', () {
    final m = F1059SvenssonMist();
    expect(m.id, 'f1059_svensson_mist');
    expect(m.shader, 'shaders/f1059_svensson_mist_gpu.frag');
  });

  test('F1059SvenssonMist presets are well-formed', () {
    final m = F1059SvenssonMist();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1059SvenssonMist metadata is consistent', () {
    final m = F1059SvenssonMist();
    expect(m.metadata.id, m.id);
  });
}
