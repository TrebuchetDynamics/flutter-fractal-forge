// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0057_thomas_attractor_presets.dart';
import 'f0057_thomas_attractor_variants.dart';
import 'f0057_thomas_attractor_metadata.dart';

/// Thomas Attractor — Strange Attractors.
class F0057ThomasAttractor extends AttractorModule {
  F0057ThomasAttractor()
      : super(
          id: 'f0057_thomas_attractor',
          shader: 'shaders/f0057_thomas_attractor_gpu.frag',
        );

  @override
  F0057ThomasAttractorMetadata get metadata => F0057ThomasAttractorMetadata.instance;

  @override
  List<F0057ThomasAttractorPreset> get presets => F0057ThomasAttractorPresets.all;

  @override
  List<F0057ThomasAttractorVariant> get variants => F0057ThomasAttractorVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
