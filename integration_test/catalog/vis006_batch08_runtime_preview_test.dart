import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.greek_cross_fractal', 'Greek Cross Fractal', 'greek_cross_fractal'),
  RuntimePreviewTarget(
      'core.sierpinski_pentagon', 'Sierpinski Pentagon', 'sierpinski_pentagon'),
  RuntimePreviewTarget('core.hexaflake', 'Hexaflake', 'hexaflake'),
  RuntimePreviewTarget('core.pentaflake', 'Pentaflake', 'pentaflake'),
  RuntimePreviewTarget('core.cantor_dust', 'Cantor Dust', 'cantor_dust'),
  RuntimePreviewTarget(
      'core.apollonian_gasket', 'Apollonian Gasket', 'apollonian_gasket'),
  RuntimePreviewTarget('core.ford_circles', 'Ford Circles', 'ford_circles'),
  RuntimePreviewTarget('core.steiner_chain', 'Steiner Chain', 'steiner_chain'),
  RuntimePreviewTarget(
      'core.cesaro_fractal', 'Cesàro Fractal', 'cesaro_fractal'),
  RuntimePreviewTarget('core.cantor_set', 'Cantor Set', 'cantor_set'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch08',
    description: 'VIS-006 batch 08 runtime catalog previews capture GPU pixels',
  );
}
