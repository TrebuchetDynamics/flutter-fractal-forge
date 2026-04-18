// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1064_tyler_vortex_presets.dart';
import 'f1064_tyler_vortex_variants.dart';
import 'f1064_tyler_vortex_metadata.dart';

/// Tyler Vortex — Strange Attractors.
class F1064TylerVortex extends AttractorModule {
  F1064TylerVortex()
      : super(
          id: 'f1064_tyler_vortex',
          shader: 'shaders/f1064_tyler_vortex_gpu.frag',
        );

  @override
  F1064TylerVortexMetadata get metadata => F1064TylerVortexMetadata.instance;

  @override
  List<F1064TylerVortexPreset> get presets => F1064TylerVortexPresets.all;

  @override
  List<F1064TylerVortexVariant> get variants => F1064TylerVortexVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
