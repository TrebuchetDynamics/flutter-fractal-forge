import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.henon', 'Hénon', 'runtime_catalog_preview'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-henon',
    description: 'Hénon runtime catalog preview captures real GPU pixels',
  );
}
