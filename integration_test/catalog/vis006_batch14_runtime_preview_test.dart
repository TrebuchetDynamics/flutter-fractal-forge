import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.householder', 'Householder Fractal', 'householder'),
  RuntimePreviewTarget(
      'core.zeta_newton', 'Riemann Zeta Newton Basins', 'zeta_newton'),
  RuntimePreviewTarget('core.magnet_newton', 'Magnet Newton', 'magnet_newton'),
  RuntimePreviewTarget(
      'core.hypercomplex_newton', 'Hypercomplex Newton', 'hypercomplex_newton'),
  RuntimePreviewTarget('core.quaternion_julia_2d',
      'Quaternion Julia (2D Slice)', 'quaternion_julia_2d'),
  RuntimePreviewTarget(
      'core.tessarine_julia', 'Tessarine Julia', 'tessarine_julia'),
  RuntimePreviewTarget('core.split_complex', 'Split-Complex', 'split_complex'),
  RuntimePreviewTarget('core.dual_complex', 'Dual-Complex', 'dual_complex'),
  RuntimePreviewTarget('core.bicomplex', 'Bicomplex Mandelbrot', 'bicomplex'),
  RuntimePreviewTarget('core.sine_julia', 'Sine Julia', 'sine_julia'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch14',
    description: 'VIS-006 batch 14 runtime catalog previews capture GPU pixels',
  );
}
