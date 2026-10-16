import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget(
      'core.buddhabrot_approx', 'Buddhabrot (Approx)', 'buddhabrot_approx'),
  RuntimePreviewTarget(
      'core.anti_buddhabrot', 'Anti-Buddhabrot', 'anti_buddhabrot'),
  RuntimePreviewTarget('core.nebulabrot', 'Nebulabrot (Approx)', 'nebulabrot'),
  RuntimePreviewTarget(
      'core.wolfram_rule30', 'Wolfram Rule 30', 'wolfram_rule30'),
  RuntimePreviewTarget(
      'core.rule90_linear_ca', 'Rule 90 Linear CA', 'rule90_linear_ca'),
  RuntimePreviewTarget(
      'core.rule150_linear_ca', 'Rule 150 Linear CA', 'rule150_linear_ca'),
  RuntimePreviewTarget('core.cyclic_cellular_automaton',
      'Cyclic Cellular Automaton', 'cyclic_cellular_automaton'),
  RuntimePreviewTarget('core.greenberg_hastings_ca', 'Greenberg-Hastings CA',
      'greenberg_hastings_ca'),
  RuntimePreviewTarget('core.klausmeier_vegetation', 'Klausmeier Vegetation',
      'klausmeier_vegetation'),
  RuntimePreviewTarget('core.gerhardt_schuster_tyson_ca',
      'Gerhardt-Schuster-Tyson CA', 'gerhardt_schuster_tyson_ca'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch19',
    description: 'VIS-006 batch 19 runtime catalog previews capture GPU pixels',
  );
}
