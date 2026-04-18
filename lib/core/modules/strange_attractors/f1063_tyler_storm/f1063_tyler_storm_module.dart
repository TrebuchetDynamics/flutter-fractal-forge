// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1063_tyler_storm_presets.dart';
import 'f1063_tyler_storm_variants.dart';
import 'f1063_tyler_storm_metadata.dart';

/// Tyler Storm — Strange Attractors.
class F1063TylerStorm extends AttractorModule {
  F1063TylerStorm()
      : super(
          id: 'f1063_tyler_storm',
          shader: 'shaders/f1063_tyler_storm_gpu.frag',
        );

  @override
  F1063TylerStormMetadata get metadata => F1063TylerStormMetadata.instance;

  @override
  List<F1063TylerStormPreset> get presets => F1063TylerStormPresets.all;

  @override
  List<F1063TylerStormVariant> get variants => F1063TylerStormVariants.all;

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
