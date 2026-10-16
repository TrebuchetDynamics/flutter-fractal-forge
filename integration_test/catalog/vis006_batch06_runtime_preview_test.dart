import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.levy_c_curve', 'Levy C Curve', 'levy_c_curve'),
  RuntimePreviewTarget('core.levy_tapestry', 'Levy Tapestry', 'levy_tapestry'),
  RuntimePreviewTarget('core.golden_dragon', 'Golden Dragon', 'golden_dragon'),
  RuntimePreviewTarget('core.twin_dragon', 'Twin Dragon', 'twin_dragon'),
  RuntimePreviewTarget('core.terdragon', 'Terdragon', 'terdragon'),
  RuntimePreviewTarget('core.chair_tiling', 'Chair Tiling', 'chair_tiling'),
  RuntimePreviewTarget(
      'core.koch_anti_snowflake', 'Koch Anti-Snowflake', 'koch_anti_snowflake'),
  RuntimePreviewTarget('core.quadratic_koch_island', 'Quadratic Koch Island',
      'quadratic_koch_island'),
  RuntimePreviewTarget(
      'core.cyclosorus_fern', 'Cyclosorus Fern', 'cyclosorus_fern'),
  RuntimePreviewTarget(
      'core.menger_sponge_2d', 'Menger Sponge 2D', 'menger_sponge_2d'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch06',
    description: 'VIS-006 batch 06 runtime catalog previews capture GPU pixels',
  );
}
