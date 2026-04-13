// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0423_gumowski_mira_coral_reef_presets.dart';
import 'f0423_gumowski_mira_coral_reef_variants.dart';
import 'f0423_gumowski_mira_coral_reef_metadata.dart';

/// Gumowski-Mira Coral Reef — Strange Attractors.
class F0423GumowskiMiraCoralReef extends AttractorModule {
  F0423GumowskiMiraCoralReef()
      : super(
          id: 'f0423_gumowski_mira_coral_reef',
          shader: 'shaders/f0423_gumowski_mira_coral_reef_gpu.frag',
        );

  @override
  F0423GumowskiMiraCoralReefMetadata get metadata => F0423GumowskiMiraCoralReefMetadata.instance;

  @override
  List<F0423GumowskiMiraCoralReefPreset> get presets => F0423GumowskiMiraCoralReefPresets.all;

  @override
  List<F0423GumowskiMiraCoralReefVariant> get variants => F0423GumowskiMiraCoralReefVariants.all;

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
