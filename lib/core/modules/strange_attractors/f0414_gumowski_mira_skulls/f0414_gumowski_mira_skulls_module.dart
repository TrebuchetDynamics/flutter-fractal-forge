// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0414_gumowski_mira_skulls_presets.dart';
import 'f0414_gumowski_mira_skulls_variants.dart';
import 'f0414_gumowski_mira_skulls_metadata.dart';

/// Gumowski-Mira Skulls — Strange Attractors.
class F0414GumowskiMiraSkulls extends AttractorModule {
  F0414GumowskiMiraSkulls()
      : super(
          id: 'f0414_gumowski_mira_skulls',
          shader: 'shaders/f0414_gumowski_mira_skulls_gpu.frag',
        );

  @override
  F0414GumowskiMiraSkullsMetadata get metadata => F0414GumowskiMiraSkullsMetadata.instance;

  @override
  List<F0414GumowskiMiraSkullsPreset> get presets => F0414GumowskiMiraSkullsPresets.all;

  @override
  List<F0414GumowskiMiraSkullsVariant> get variants => F0414GumowskiMiraSkullsVariants.all;

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
