import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.log_spiral', 'Log Spiral Fractal', 'log_spiral'),
  RuntimePreviewTarget('core.lyapunov', 'Lyapunov Fractal', 'lyapunov'),
  RuntimePreviewTarget(
      'core.logistic_lyapunov', 'Logistic Lyapunov', 'logistic_lyapunov'),
  RuntimePreviewTarget(
      'core.circle_map_lyapunov', 'Circle Map Lyapunov', 'circle_map_lyapunov'),
  RuntimePreviewTarget(
      'core.sine_map_lyapunov', 'Sine Map Lyapunov', 'sine_map_lyapunov'),
  RuntimePreviewTarget('core.tent_map', 'Tent Map', 'tent_map'),
  RuntimePreviewTarget('core.hopalong', 'Hopalong Attractor', 'hopalong'),
  RuntimePreviewTarget(
      'core.pickover_biomorph', 'Pickover Biomorph', 'pickover_biomorph'),
  RuntimePreviewTarget(
      'core.feigenbaum', 'Feigenbaum Logistic Map', 'feigenbaum'),
  RuntimePreviewTarget('core.gauss_map', 'Gauss Map', 'gauss_map'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch18',
    description: 'VIS-006 batch 18 runtime catalog previews capture GPU pixels',
  );
}
