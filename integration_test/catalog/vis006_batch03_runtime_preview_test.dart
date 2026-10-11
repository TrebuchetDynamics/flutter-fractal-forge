import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.druid', 'Druid Fractal', 'druid'),
  RuntimePreviewTarget(
      'core.inverse_mandelbrot', 'Inverse Mandelbrot', 'inverse_mandelbrot'),
  RuntimePreviewTarget('core.glynn', 'Glynn Fractal', 'glynn'),
  RuntimePreviewTarget('core.simonbrot', 'Simonbrot', 'simonbrot'),
  RuntimePreviewTarget('core.shark_fin', 'Shark Fin', 'shark_fin'),
  RuntimePreviewTarget('core.manowar', 'Manowar Fractal', 'manowar'),
  RuntimePreviewTarget('core.spider', 'Spider Fractal', 'spider'),
  RuntimePreviewTarget('core.collatz', 'Collatz Fractal', 'collatz'),
  RuntimePreviewTarget('core.popcorn', 'Popcorn Fractal', 'popcorn'),
  RuntimePreviewTarget('core.talis', 'Talis Fractal', 'talis'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch03',
    description: 'VIS-006 batch 03 runtime catalog previews capture GPU pixels',
  );
}
