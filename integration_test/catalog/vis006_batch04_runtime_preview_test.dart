import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.tetration', 'Tetration Fractal', 'tetration'),
  RuntimePreviewTarget(
      'core.sierpinski_triangle', 'Sierpinski Triangle', 'sierpinski_triangle'),
  RuntimePreviewTarget(
      'core.sierpinski_carpet', 'Sierpinski Carpet', 'sierpinski_carpet'),
  RuntimePreviewTarget(
      'core.koch_snowflake', 'Koch Snowflake', 'koch_snowflake'),
  RuntimePreviewTarget('core.dragon_curve', 'Dragon Curve', 'dragon_curve'),
  RuntimePreviewTarget('core.barnsley_fern', 'Barnsley Fern', 'barnsley_fern'),
  RuntimePreviewTarget(
      'core.pythagorean_tree', 'Pythagorean Tree', 'pythagorean_tree'),
  RuntimePreviewTarget('core.hilbert_curve', 'Hilbert Curve', 'hilbert_curve'),
  RuntimePreviewTarget('core.peano_curve', 'Peano Curve', 'peano_curve'),
  RuntimePreviewTarget('core.gosper_curve', 'Gosper Curve', 'gosper_curve'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch04',
    description: 'VIS-006 batch 04 runtime catalog previews capture GPU pixels',
  );
}
