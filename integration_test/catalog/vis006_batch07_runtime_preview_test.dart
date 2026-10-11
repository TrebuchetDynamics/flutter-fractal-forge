import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.vicsek_fractal', 'Vicsek Fractal', 'vicsek_fractal'),
  RuntimePreviewTarget(
      'core.penrose_tiling', 'Penrose Tiling', 'penrose_tiling'),
  RuntimePreviewTarget(
      'core.fibonacci_word', 'Fibonacci Word', 'fibonacci_word'),
  RuntimePreviewTarget('core.rauzy_fractal', 'Rauzy Fractal', 'rauzy_fractal'),
  RuntimePreviewTarget('core.arnoux_rauzy_fractal', 'Arnoux-Rauzy Fractal',
      'arnoux_rauzy_fractal'),
  RuntimePreviewTarget('core.dual_substitution_tiling',
      'Dual Substitution Tiling', 'dual_substitution_tiling'),
  RuntimePreviewTarget('core.bedford_mcmullen_carpet',
      'Bedford-McMullen Carpet', 'bedford_mcmullen_carpet'),
  RuntimePreviewTarget('core.self_affine_finite_type',
      'Self-Affine Finite-Type', 'self_affine_finite_type'),
  RuntimePreviewTarget(
      'core.pinwheel_tiling', 'Pinwheel Tiling', 'pinwheel_tiling'),
  RuntimePreviewTarget('core.z_order_curve', 'Z-Order Curve', 'z_order_curve'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch07',
    description: 'VIS-006 batch 07 runtime catalog previews capture GPU pixels',
  );
}
