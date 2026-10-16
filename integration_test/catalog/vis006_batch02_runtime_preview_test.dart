import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.perpendicular_mandelbrot',
      'Perpendicular Mandelbrot', 'perpendicular_mandelbrot'),
  RuntimePreviewTarget('core.lambda', 'Lambda Fractal', 'lambda'),
  RuntimePreviewTarget(
      'core.magnet_type_1', 'Magnet Fractal (Type I)', 'magnet_type_1'),
  RuntimePreviewTarget(
      'core.magnet_type_2', 'Magnet Fractal (Type II)', 'magnet_type_2'),
  RuntimePreviewTarget(
      'core.magnet_type_3', 'Magnet Fractal (Type III)', 'magnet_type_3'),
  RuntimePreviewTarget('core.power_sum', 'Power Sum Fractal', 'power_sum'),
  RuntimePreviewTarget('core.cactus', 'Cactus Fractal', 'cactus'),
  RuntimePreviewTarget('core.astroid', 'Astroid Fractal', 'astroid'),
  RuntimePreviewTarget('core.deltoid', 'Deltoid Fractal', 'deltoid'),
  RuntimePreviewTarget('core.eisenstein', 'Eisenstein Fractal', 'eisenstein'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch02',
    description: 'VIS-006 batch 02 runtime catalog previews capture GPU pixels',
  );
}
