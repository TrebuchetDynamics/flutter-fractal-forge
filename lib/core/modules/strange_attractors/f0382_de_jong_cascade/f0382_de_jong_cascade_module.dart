// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0382_de_jong_cascade_presets.dart';
import 'f0382_de_jong_cascade_variants.dart';
import 'f0382_de_jong_cascade_metadata.dart';

/// de Jong Cascade — Strange Attractors.
class F0382DeJongCascade extends AttractorModule {
  F0382DeJongCascade()
      : super(
          id: 'f0382_de_jong_cascade',
          shader: 'shaders/f0382_de_jong_cascade_gpu.frag',
        );

  @override
  F0382DeJongCascadeMetadata get metadata => F0382DeJongCascadeMetadata.instance;

  @override
  List<F0382DeJongCascadePreset> get presets => F0382DeJongCascadePresets.all;

  @override
  List<F0382DeJongCascadeVariant> get variants => F0382DeJongCascadeVariants.all;

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
