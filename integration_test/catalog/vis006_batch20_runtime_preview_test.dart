import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.f0155_period_4_julia', 'Period 4 Julia', 'f0155_period_4_julia'),
  RuntimePreviewTarget(
      'core.f0156_period_5_julia', 'Period 5 Julia', 'f0156_period_5_julia'),
  RuntimePreviewTarget(
      'core.f0157_period_6_julia', 'Period 6 Julia', 'f0157_period_6_julia'),
  RuntimePreviewTarget(
      'core.f0158_period_7_julia', 'Period 7 Julia', 'f0158_period_7_julia'),
  RuntimePreviewTarget(
      'core.f0161_swirl_julia', 'Swirl Julia', 'f0161_swirl_julia'),
  RuntimePreviewTarget(
      'core.f0162_lightning_julia', 'Lightning Julia', 'f0162_lightning_julia'),
  RuntimePreviewTarget(
      'core.f0163_filigree_julia', 'Filigree Julia', 'f0163_filigree_julia'),
  RuntimePreviewTarget(
      'core.f0164_spiral_julia', 'Spiral Julia', 'f0164_spiral_julia'),
  RuntimePreviewTarget(
      'core.f0166_chebyshev_julia', 'Chebyshev Julia', 'f0166_chebyshev_julia'),
  RuntimePreviewTarget('core.f0167_cauliflower_bulb_julia',
      'Cauliflower Bulb Julia', 'f0167_cauliflower_bulb_julia'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch20',
    description: 'VIS-006 batch 20 runtime catalog previews capture GPU pixels',
  );
}
