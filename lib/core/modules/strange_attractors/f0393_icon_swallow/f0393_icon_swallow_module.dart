// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0393_icon_swallow_presets.dart';
import 'f0393_icon_swallow_variants.dart';
import 'f0393_icon_swallow_metadata.dart';

/// Icon — Swallow — Strange Attractors.
class F0393IconSwallow extends AttractorModule {
  F0393IconSwallow()
      : super(
          id: 'f0393_icon_swallow',
          shader: 'shaders/f0393_icon_swallow_gpu.frag',
        );

  @override
  F0393IconSwallowMetadata get metadata => F0393IconSwallowMetadata.instance;

  @override
  List<F0393IconSwallowPreset> get presets => F0393IconSwallowPresets.all;

  @override
  List<F0393IconSwallowVariant> get variants => F0393IconSwallowVariants.all;

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
