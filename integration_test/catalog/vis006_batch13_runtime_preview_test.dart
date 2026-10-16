import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.yu_wang', 'Yu-Wang Attractor', 'yu_wang'),
  RuntimePreviewTarget('core.zhou_chen', 'Zhou-Chen Attractor', 'zhou_chen'),
  RuntimePreviewTarget('core.tsucs', 'TSUCS Attractor', 'tsucs'),
  RuntimePreviewTarget(
      'core.rayleigh_benard', 'Rayleigh-Bénard Attractor', 'rayleigh_benard'),
  RuntimePreviewTarget('core.robinson', 'Robinson Attractor', 'robinson'),
  RuntimePreviewTarget(
      'core.globo_toroid', 'Globo-Toroid Attractor', 'globo_toroid'),
  RuntimePreviewTarget('core.tamari', 'Tamari Attractor', 'tamari'),
  RuntimePreviewTarget(
      'core.wang_sun_cang', 'Wang-Sun-Cang Attractor', 'wang_sun_cang'),
  RuntimePreviewTarget('core.newton_z3', 'Newton z³', 'newton_z3'),
  RuntimePreviewTarget('core.halley', 'Halley', 'halley'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch13',
    description: 'VIS-006 batch 13 runtime catalog previews capture GPU pixels',
  );
}
