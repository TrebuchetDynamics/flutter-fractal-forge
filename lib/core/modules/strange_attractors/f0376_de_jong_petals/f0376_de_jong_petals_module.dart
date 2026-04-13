// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0376_de_jong_petals_presets.dart';
import 'f0376_de_jong_petals_variants.dart';
import 'f0376_de_jong_petals_metadata.dart';

/// de Jong Petals — Strange Attractors.
class F0376DeJongPetals extends AttractorModule {
  F0376DeJongPetals()
      : super(
          id: 'f0376_de_jong_petals',
          shader: 'shaders/f0376_de_jong_petals_gpu.frag',
        );

  @override
  F0376DeJongPetalsMetadata get metadata => F0376DeJongPetalsMetadata.instance;

  @override
  List<F0376DeJongPetalsPreset> get presets => F0376DeJongPetalsPresets.all;

  @override
  List<F0376DeJongPetalsVariant> get variants => F0376DeJongPetalsVariants.all;

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
