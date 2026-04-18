// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1069_tyler_coral_presets.dart';
import 'f1069_tyler_coral_variants.dart';
import 'f1069_tyler_coral_metadata.dart';

/// Tyler Coral — Strange Attractors.
class F1069TylerCoral extends AttractorModule {
  F1069TylerCoral()
      : super(
          id: 'f1069_tyler_coral',
          shader: 'shaders/f1069_tyler_coral_gpu.frag',
        );

  @override
  F1069TylerCoralMetadata get metadata => F1069TylerCoralMetadata.instance;

  @override
  List<F1069TylerCoralPreset> get presets => F1069TylerCoralPresets.all;

  @override
  List<F1069TylerCoralVariant> get variants => F1069TylerCoralVariants.all;

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
