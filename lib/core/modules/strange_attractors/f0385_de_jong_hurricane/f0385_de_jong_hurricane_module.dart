// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0385_de_jong_hurricane_presets.dart';
import 'f0385_de_jong_hurricane_variants.dart';
import 'f0385_de_jong_hurricane_metadata.dart';

/// de Jong Hurricane — Strange Attractors.
class F0385DeJongHurricane extends AttractorModule {
  F0385DeJongHurricane()
      : super(
          id: 'f0385_de_jong_hurricane',
          shader: 'shaders/f0385_de_jong_hurricane_gpu.frag',
        );

  @override
  F0385DeJongHurricaneMetadata get metadata => F0385DeJongHurricaneMetadata.instance;

  @override
  List<F0385DeJongHurricanePreset> get presets => F0385DeJongHurricanePresets.all;

  @override
  List<F0385DeJongHurricaneVariant> get variants => F0385DeJongHurricaneVariants.all;

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
