// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0420_gumowski_mira_propeller_presets.dart';
import 'f0420_gumowski_mira_propeller_variants.dart';
import 'f0420_gumowski_mira_propeller_metadata.dart';

/// Gumowski-Mira Propeller — Strange Attractors.
class F0420GumowskiMiraPropeller extends AttractorModule {
  F0420GumowskiMiraPropeller()
      : super(
          id: 'f0420_gumowski_mira_propeller',
          shader: 'shaders/f0420_gumowski_mira_propeller_gpu.frag',
        );

  @override
  F0420GumowskiMiraPropellerMetadata get metadata => F0420GumowskiMiraPropellerMetadata.instance;

  @override
  List<F0420GumowskiMiraPropellerPreset> get presets => F0420GumowskiMiraPropellerPresets.all;

  @override
  List<F0420GumowskiMiraPropellerVariant> get variants => F0420GumowskiMiraPropellerVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
