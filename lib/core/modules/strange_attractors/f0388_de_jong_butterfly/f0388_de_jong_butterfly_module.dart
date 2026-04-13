// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0388_de_jong_butterfly_presets.dart';
import 'f0388_de_jong_butterfly_variants.dart';
import 'f0388_de_jong_butterfly_metadata.dart';

/// de Jong Butterfly — Strange Attractors.
class F0388DeJongButterfly extends AttractorModule {
  F0388DeJongButterfly()
      : super(
          id: 'f0388_de_jong_butterfly',
          shader: 'shaders/f0388_de_jong_butterfly_gpu.frag',
        );

  @override
  F0388DeJongButterflyMetadata get metadata => F0388DeJongButterflyMetadata.instance;

  @override
  List<F0388DeJongButterflyPreset> get presets => F0388DeJongButterflyPresets.all;

  @override
  List<F0388DeJongButterflyVariant> get variants => F0388DeJongButterflyVariants.all;

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
