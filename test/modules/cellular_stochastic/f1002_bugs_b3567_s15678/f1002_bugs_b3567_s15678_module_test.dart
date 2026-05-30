// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1002_bugs_b3567_s15678/f1002_bugs_b3567_s15678_module.dart';

void main() {
  test('F1002BugsB3567S15678 instantiates', () {
    final m = F1002BugsB3567S15678();
    expect(m.id, 'f1002_bugs_b3567_s15678');
    expect(m.shader, 'shaders/f1002_bugs_b3567_s15678_gpu.frag');
  });

  test('F1002BugsB3567S15678 presets are well-formed', () {
    final m = F1002BugsB3567S15678();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1002BugsB3567S15678 metadata is consistent', () {
    final m = F1002BugsB3567S15678();
    expect(m.metadata.id, m.id);
  });
}
