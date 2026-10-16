import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.phoenix', 'Phoenix', 'phoenix'),
  RuntimePreviewTarget('core.tricorn', 'Tricorn', 'tricorn'),
  RuntimePreviewTarget('core.celtic', 'Celtic', 'celtic'),
  RuntimePreviewTarget('core.buffalo', 'Buffalo', 'buffalo'),
  RuntimePreviewTarget('core.multibrot3', 'Multibrot 3', 'multibrot3'),
  RuntimePreviewTarget('core.nova', 'Nova', 'nova'),
  RuntimePreviewTarget('core.nova_julia', 'Nova Julia', 'nova-julia'),
  RuntimePreviewTarget('core.fatou', 'Fatou', 'fatou'),
  RuntimePreviewTarget('core.gamma_fractal', 'Gamma Fractal', 'gamma-fractal'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-{outputName}',
    description: '{id} runtime catalog preview captures GPU pixels',
    perTargetTests: true,
  );
}
