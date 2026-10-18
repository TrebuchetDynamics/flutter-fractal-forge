import 'package:integration_test/integration_test.dart';
import 'runtime_preview_harness.dart';

const _targets = <RuntimePreviewTarget>[
  RuntimePreviewTarget('core.mimura_murray_predator_prey',
      'Mimura-Murray Predator-Prey', 'mimura_murray_predator_prey'),
  RuntimePreviewTarget('core.stable_square_turing_model',
      'Stable-Square Turing Model', 'stable_square_turing_model'),
  RuntimePreviewTarget('core.flow_lenia', 'Flow-Lenia', 'flow_lenia'),
  RuntimePreviewTarget('core.coupled_logistic_map_lattice',
      'Coupled Logistic Map Lattice', 'coupled_logistic_map_lattice'),
  RuntimePreviewTarget('core.langton_ant', "Langton's Ant", 'langton_ant'),
  RuntimePreviewTarget('core.turmite', 'Turmite', 'turmite'),
  RuntimePreviewTarget('core.wireworld', 'Wireworld', 'wireworld'),
  RuntimePreviewTarget('core.sandpile', 'Abelian Sandpile', 'sandpile'),
  RuntimePreviewTarget('core.dla', 'DLA (Approximation)', 'dla'),
  RuntimePreviewTarget('core.forest_fire', 'Forest Fire Model', 'forest_fire'),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerRuntimePreview(
    _targets,
    'build/test_output/vis006-batch20-corrected',
    description:
        'VIS-006 batch 20 corrected runtime catalog previews capture GPU pixels',
  );
}
