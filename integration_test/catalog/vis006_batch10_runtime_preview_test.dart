import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.peter_de_jong', 'Peter de Jong', 'peter_de_jong'),
  RuntimePreviewTarget('core.svensson', 'Svensson', 'svensson'),
  RuntimePreviewTarget('core.gumowski_mira', 'Gumowski-Mira', 'gumowski_mira'),
  RuntimePreviewTarget('core.arnold_cat', 'Arnold Cat', 'arnold_cat'),
  RuntimePreviewTarget('core.standard_map', 'Standard Map', 'standard_map'),
  RuntimePreviewTarget('core.zaslavsky', 'Zaslavsky', 'zaslavsky'),
  RuntimePreviewTarget(
      'core.kicked_rotator', 'Kicked Rotator', 'kicked_rotator'),
  RuntimePreviewTarget('core.chua_circuit', 'Chua Circuit', 'chua_circuit'),
  RuntimePreviewTarget('core.sprott_a', 'Sprott Case A', 'sprott_a'),
  RuntimePreviewTarget('core.burke_shaw', 'Burke-Shaw', 'burke_shaw'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch10',
    description: 'VIS-006 batch 10 runtime catalog previews capture GPU pixels',
  );
}
