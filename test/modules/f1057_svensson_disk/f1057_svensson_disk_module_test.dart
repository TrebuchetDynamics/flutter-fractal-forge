// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1057_svensson_disk/f1057_svensson_disk_module.dart';

void main() {
  test('F1057SvenssonDisk instantiates', () {
    final m = F1057SvenssonDisk();
    expect(m.id, 'f1057_svensson_disk');
    expect(m.shader, 'shaders/f1057_svensson_disk_gpu.frag');
  });

  test('F1057SvenssonDisk presets are well-formed', () {
    final m = F1057SvenssonDisk();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1057SvenssonDisk metadata is consistent', () {
    final m = F1057SvenssonDisk();
    expect(m.metadata.id, m.id);
  });
}
