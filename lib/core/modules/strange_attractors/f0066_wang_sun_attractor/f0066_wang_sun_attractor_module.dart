// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0066_wang_sun_attractor_presets.dart';
import 'f0066_wang_sun_attractor_variants.dart';
import 'f0066_wang_sun_attractor_metadata.dart';

/// Wang-Sun Attractor — Strange Attractors.
class F0066WangSunAttractor extends AttractorModule {
  F0066WangSunAttractor()
      : super(
          id: 'f0066_wang_sun_attractor',
          shader: 'shaders/f0066_wang_sun_attractor_gpu.frag',
        );

  @override
  F0066WangSunAttractorMetadata get metadata => F0066WangSunAttractorMetadata.instance;

  @override
  List<F0066WangSunAttractorPreset> get presets => F0066WangSunAttractorPresets.all;

  @override
  List<F0066WangSunAttractorVariant> get variants => F0066WangSunAttractorVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
