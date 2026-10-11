import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.moore_spiegel', 'Moore-Spiegel Attractor', 'moore_spiegel'),
  RuntimePreviewTarget('core.hadley', 'Hadley Circulation', 'hadley'),
  RuntimePreviewTarget(
      'core.genesio_tesi', 'Genesio-Tesi Attractor', 'genesio_tesi'),
  RuntimePreviewTarget('core.liu_chen', 'Liu-Chen Attractor', 'liu_chen'),
  RuntimePreviewTarget(
      'core.newton_leipnik', 'Newton-Leipnik Attractor', 'newton_leipnik'),
  RuntimePreviewTarget('core.bouali', 'Bouali Attractor', 'bouali'),
  RuntimePreviewTarget('core.dequan_li', 'Dequan Li Attractor', 'dequan_li'),
  RuntimePreviewTarget('core.coullet', 'Coullet Attractor', 'coullet'),
  RuntimePreviewTarget('core.sakarya', 'Sakarya Attractor', 'sakarya'),
  RuntimePreviewTarget('core.qi_chen', 'Qi-Chen Attractor', 'qi_chen'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch12',
    description: 'VIS-006 batch 12 runtime catalog previews capture GPU pixels',
  );
}
