// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0024_sprott_k_presets.dart';
import 'f0024_sprott_k_variants.dart';
import 'f0024_sprott_k_metadata.dart';

/// Sprott K — Strange Attractors.
class F0024SprottK extends AttractorModule {
  F0024SprottK()
      : super(
          id: 'f0024_sprott_k',
          shader: 'shaders/f0024_sprott_k_gpu.frag',
        );

  @override
  F0024SprottKMetadata get metadata => F0024SprottKMetadata.instance;

  @override
  List<F0024SprottKPreset> get presets => F0024SprottKPresets.all;

  @override
  List<F0024SprottKVariant> get variants => F0024SprottKVariants.all;

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
