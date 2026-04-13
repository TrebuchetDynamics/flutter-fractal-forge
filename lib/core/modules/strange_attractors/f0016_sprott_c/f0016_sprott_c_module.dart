// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0016_sprott_c_presets.dart';
import 'f0016_sprott_c_variants.dart';
import 'f0016_sprott_c_metadata.dart';

/// Sprott C — Strange Attractors.
class F0016SprottC extends AttractorModule {
  F0016SprottC()
      : super(
          id: 'f0016_sprott_c',
          shader: 'shaders/f0016_sprott_c_gpu.frag',
        );

  @override
  F0016SprottCMetadata get metadata => F0016SprottCMetadata.instance;

  @override
  List<F0016SprottCPreset> get presets => F0016SprottCPresets.all;

  @override
  List<F0016SprottCVariant> get variants => F0016SprottCVariants.all;

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
