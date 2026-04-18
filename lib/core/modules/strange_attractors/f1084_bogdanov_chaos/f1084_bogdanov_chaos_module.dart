// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1084_bogdanov_chaos_presets.dart';
import 'f1084_bogdanov_chaos_variants.dart';
import 'f1084_bogdanov_chaos_metadata.dart';

/// Bogdanov Chaos — Strange Attractors.
class F1084BogdanovChaos extends AttractorModule {
  F1084BogdanovChaos()
      : super(
          id: 'f1084_bogdanov_chaos',
          shader: 'shaders/f1084_bogdanov_chaos_gpu.frag',
        );

  @override
  F1084BogdanovChaosMetadata get metadata => F1084BogdanovChaosMetadata.instance;

  @override
  List<F1084BogdanovChaosPreset> get presets => F1084BogdanovChaosPresets.all;

  @override
  List<F1084BogdanovChaosVariant> get variants => F1084BogdanovChaosVariants.all;

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
