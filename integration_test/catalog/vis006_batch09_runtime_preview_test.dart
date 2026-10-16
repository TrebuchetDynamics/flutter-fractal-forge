import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.fractal_canopy', 'Fractal Canopy', 'fractal_canopy'),
  RuntimePreviewTarget('core.benesi', 'Benesi Fractal', 'benesi'),
  RuntimePreviewTarget(
      'core.schottky_limit_set', 'Schottky Limit Set', 'schottky_limit_set'),
  RuntimePreviewTarget('core.henon', 'Hénon Map', 'henon'),
  RuntimePreviewTarget('core.tinkerbell', 'Tinkerbell Map', 'tinkerbell'),
  RuntimePreviewTarget(
      'core.gingerbreadman', 'Gingerbreadman Map', 'gingerbreadman'),
  RuntimePreviewTarget('core.lozi', 'Lozi Map', 'lozi'),
  RuntimePreviewTarget('core.duffing', 'Duffing Map', 'duffing'),
  RuntimePreviewTarget('core.ikeda', 'Ikeda Map', 'ikeda'),
  RuntimePreviewTarget('core.clifford', 'Clifford Attractor', 'clifford'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch09',
    description: 'VIS-006 batch 09 runtime catalog previews capture GPU pixels',
  );
}
