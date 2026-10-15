import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.arneodo', 'Arneodo', 'runtime_catalog_preview'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-arneodo',
    description: 'Arneodo runtime catalog preview captures real GPU pixels',
  );
}
