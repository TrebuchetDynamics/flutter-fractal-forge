import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.secant_cosecant', 'Secant/Cosecant Map', 'secant_cosecant'),
  RuntimePreviewTarget('core.taylor', 'Taylor Series Fractal', 'taylor'),
  RuntimePreviewTarget(
      'core.rational_map', 'Rational Map Fractal', 'rational_map'),
  RuntimePreviewTarget(
      'core.lattes_map_julia', 'Lattès Map Julia Set', 'lattes_map_julia'),
  RuntimePreviewTarget('core.complex_henon_julia_slice',
      'Complex Hénon Julia Slice', 'complex_henon_julia_slice'),
  RuntimePreviewTarget('core.matrix_logistic_spectrum',
      'Matrix Logistic Spectrum', 'matrix_logistic_spectrum'),
  RuntimePreviewTarget('core.barnsley_j2', 'Barnsley J2', 'barnsley_j2'),
  RuntimePreviewTarget('core.barnsley_j3', 'Barnsley J3', 'barnsley_j3'),
  RuntimePreviewTarget('core.celtic_julia', 'Celtic Julia', 'celtic_julia'),
  RuntimePreviewTarget('core.buffalo_julia', 'Buffalo Julia', 'buffalo_julia'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch16',
    description: 'VIS-006 batch 16 runtime catalog previews capture GPU pixels',
  );
}
