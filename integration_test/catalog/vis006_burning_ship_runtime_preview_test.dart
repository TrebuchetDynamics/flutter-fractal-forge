import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.burning_ship', 'Burning Ship', 'runtime_catalog_preview'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-burning-ship',
    description:
        'Burning Ship runtime catalog preview captures real GPU pixels',
  );
}
