// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0402_icon_clam_d5_presets.dart';
import 'f0402_icon_clam_d5_variants.dart';
import 'f0402_icon_clam_d5_metadata.dart';

/// Icon — Clam D5 — Strange Attractors.
class F0402IconClamD5 extends AttractorModule {
  F0402IconClamD5()
      : super(
          id: 'f0402_icon_clam_d5',
          shader: 'shaders/f0402_icon_clam_d5_gpu.frag',
        );

  @override
  F0402IconClamD5Metadata get metadata => F0402IconClamD5Metadata.instance;

  @override
  List<F0402IconClamD5Preset> get presets => F0402IconClamD5Presets.all;

  @override
  List<F0402IconClamD5Variant> get variants => F0402IconClamD5Variants.all;

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
