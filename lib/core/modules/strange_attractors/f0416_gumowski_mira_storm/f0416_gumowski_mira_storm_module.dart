// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0416_gumowski_mira_storm_presets.dart';
import 'f0416_gumowski_mira_storm_variants.dart';
import 'f0416_gumowski_mira_storm_metadata.dart';

/// Gumowski-Mira Storm — Strange Attractors.
class F0416GumowskiMiraStorm extends AttractorModule {
  F0416GumowskiMiraStorm()
      : super(
          id: 'f0416_gumowski_mira_storm',
          shader: 'shaders/f0416_gumowski_mira_storm_gpu.frag',
        );

  @override
  F0416GumowskiMiraStormMetadata get metadata => F0416GumowskiMiraStormMetadata.instance;

  @override
  List<F0416GumowskiMiraStormPreset> get presets => F0416GumowskiMiraStormPresets.all;

  @override
  List<F0416GumowskiMiraStormVariant> get variants => F0416GumowskiMiraStormVariants.all;

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
