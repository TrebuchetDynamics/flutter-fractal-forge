import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.perpendicular_julia', 'Perpendicular Julia', 'perpendicular_julia'),
  RuntimePreviewTarget('core.tricorn_julia', 'Tricorn Julia', 'tricorn_julia'),
  RuntimePreviewTarget(
      'core.burning_ship_julia', 'Burning Ship Julia', 'burning_ship_julia'),
  RuntimePreviewTarget(
      'core.multibrot_neg2', 'Multibrot d=-2', 'multibrot_neg2'),
  RuntimePreviewTarget('core.heart', 'Heart Fractal', 'heart'),
  RuntimePreviewTarget(
      'core.cosine_mandelbrot', 'Cosine Mandelbrot', 'cosine_mandelbrot'),
  RuntimePreviewTarget(
      'core.tangent_mandelbrot', 'Tangent Mandelbrot', 'tangent_mandelbrot'),
  RuntimePreviewTarget(
      'core.sinh_mandelbrot', 'Sinh Mandelbrot', 'sinh_mandelbrot'),
  RuntimePreviewTarget(
      'core.cosh_mandelbrot', 'Cosh Mandelbrot', 'cosh_mandelbrot'),
  RuntimePreviewTarget(
      'core.tanh_mandelbrot', 'Tanh Mandelbrot', 'tanh_mandelbrot'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch17',
    description: 'VIS-006 batch 17 runtime catalog previews capture GPU pixels',
  );
}
