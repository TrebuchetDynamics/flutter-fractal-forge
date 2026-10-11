import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.cosine_julia', 'Cosine Julia', 'cosine_julia'),
  RuntimePreviewTarget('core.tangent', 'Tangent', 'tangent'),
  RuntimePreviewTarget('core.sinh_cosh', 'Sinh Cosh', 'sinh_cosh'),
  RuntimePreviewTarget('core.exponential', 'Exponential', 'exponential'),
  RuntimePreviewTarget('core.zircon_zity', 'Zircon Zity', 'zircon_zity'),
  RuntimePreviewTarget('core.barnsley_j1', 'Barnsley J1', 'barnsley_j1'),
  RuntimePreviewTarget('core.fish', 'Fish Fractal', 'fish'),
  RuntimePreviewTarget('core.ducky', 'Ducky Fractal', 'ducky'),
  RuntimePreviewTarget('core.schroeder', 'Schroeder', 'schroeder'),
  RuntimePreviewTarget(
      'core.secant_fractal', 'Secant Fractal', 'secant_fractal'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch15',
    description: 'VIS-006 batch 15 runtime catalog previews capture GPU pixels',
  );
}
