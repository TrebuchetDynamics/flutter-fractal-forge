// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0405_icon_pentagon_d5_presets.dart';
import 'f0405_icon_pentagon_d5_variants.dart';
import 'f0405_icon_pentagon_d5_metadata.dart';

/// Icon — Pentagon D5 — Strange Attractors.
class F0405IconPentagonD5 extends AttractorModule {
  F0405IconPentagonD5()
      : super(
          id: 'f0405_icon_pentagon_d5',
          shader: 'shaders/f0405_icon_pentagon_d5_gpu.frag',
        );

  @override
  F0405IconPentagonD5Metadata get metadata => F0405IconPentagonD5Metadata.instance;

  @override
  List<F0405IconPentagonD5Preset> get presets => F0405IconPentagonD5Presets.all;

  @override
  List<F0405IconPentagonD5Variant> get variants => F0405IconPentagonD5Variants.all;

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
