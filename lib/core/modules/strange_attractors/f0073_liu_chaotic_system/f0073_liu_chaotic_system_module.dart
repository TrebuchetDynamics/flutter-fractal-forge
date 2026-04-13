// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0073_liu_chaotic_system_presets.dart';
import 'f0073_liu_chaotic_system_variants.dart';
import 'f0073_liu_chaotic_system_metadata.dart';

/// Liu Chaotic System — Strange Attractors.
class F0073LiuChaoticSystem extends AttractorModule {
  F0073LiuChaoticSystem()
      : super(
          id: 'f0073_liu_chaotic_system',
          shader: 'shaders/f0073_liu_chaotic_system_gpu.frag',
        );

  @override
  F0073LiuChaoticSystemMetadata get metadata => F0073LiuChaoticSystemMetadata.instance;

  @override
  List<F0073LiuChaoticSystemPreset> get presets => F0073LiuChaoticSystemPresets.all;

  @override
  List<F0073LiuChaoticSystemVariant> get variants => F0073LiuChaoticSystemVariants.all;

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
