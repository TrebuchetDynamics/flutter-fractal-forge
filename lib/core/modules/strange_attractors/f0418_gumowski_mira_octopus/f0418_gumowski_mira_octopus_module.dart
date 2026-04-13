// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0418_gumowski_mira_octopus_presets.dart';
import 'f0418_gumowski_mira_octopus_variants.dart';
import 'f0418_gumowski_mira_octopus_metadata.dart';

/// Gumowski-Mira Octopus — Strange Attractors.
class F0418GumowskiMiraOctopus extends AttractorModule {
  F0418GumowskiMiraOctopus()
      : super(
          id: 'f0418_gumowski_mira_octopus',
          shader: 'shaders/f0418_gumowski_mira_octopus_gpu.frag',
        );

  @override
  F0418GumowskiMiraOctopusMetadata get metadata => F0418GumowskiMiraOctopusMetadata.instance;

  @override
  List<F0418GumowskiMiraOctopusPreset> get presets => F0418GumowskiMiraOctopusPresets.all;

  @override
  List<F0418GumowskiMiraOctopusVariant> get variants => F0418GumowskiMiraOctopusVariants.all;

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
