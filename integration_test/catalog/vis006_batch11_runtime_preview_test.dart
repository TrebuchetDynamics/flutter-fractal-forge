import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.arneodo', 'Arneodo', 'arneodo'),
  RuntimePreviewTarget('core.dadras', 'Dadras', 'dadras'),
  RuntimePreviewTarget('core.chen', 'Chen', 'chen'),
  RuntimePreviewTarget('core.lu_chen', 'Lu-Chen', 'lu_chen'),
  RuntimePreviewTarget('core.halvorsen', 'Halvorsen', 'halvorsen'),
  RuntimePreviewTarget('core.scroll_waves', 'Scroll Waves', 'scroll_waves'),
  RuntimePreviewTarget('core.rikitake', 'Rikitake', 'rikitake'),
  RuntimePreviewTarget('core.aizawa', 'Aizawa', 'aizawa'),
  RuntimePreviewTarget('core.rabinovich_fabrikant', 'Rabinovich-Fabrikant',
      'rabinovich_fabrikant'),
  RuntimePreviewTarget('core.nose_hoover', 'Nose-Hoover', 'nose_hoover'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch11',
    description: 'VIS-006 batch 11 runtime catalog previews capture GPU pixels',
  );
}
