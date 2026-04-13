// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0032_sprott_s_presets.dart';
import 'f0032_sprott_s_variants.dart';
import 'f0032_sprott_s_metadata.dart';

/// Sprott S — Strange Attractors.
class F0032SprottS extends AttractorModule {
  F0032SprottS()
      : super(
          id: 'f0032_sprott_s',
          shader: 'shaders/f0032_sprott_s_gpu.frag',
        );

  @override
  F0032SprottSMetadata get metadata => F0032SprottSMetadata.instance;

  @override
  List<F0032SprottSPreset> get presets => F0032SprottSPresets.all;

  @override
  List<F0032SprottSVariant> get variants => F0032SprottSVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
