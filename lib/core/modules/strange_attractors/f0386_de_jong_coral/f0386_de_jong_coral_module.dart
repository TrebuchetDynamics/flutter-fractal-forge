// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0386_de_jong_coral_presets.dart';
import 'f0386_de_jong_coral_variants.dart';
import 'f0386_de_jong_coral_metadata.dart';

/// de Jong Coral — Strange Attractors.
class F0386DeJongCoral extends AttractorModule {
  F0386DeJongCoral()
      : super(
          id: 'f0386_de_jong_coral',
          shader: 'shaders/f0386_de_jong_coral_gpu.frag',
        );

  @override
  F0386DeJongCoralMetadata get metadata => F0386DeJongCoralMetadata.instance;

  @override
  List<F0386DeJongCoralPreset> get presets => F0386DeJongCoralPresets.all;

  @override
  List<F0386DeJongCoralVariant> get variants => F0386DeJongCoralVariants.all;

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
