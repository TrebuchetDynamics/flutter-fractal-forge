// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0049_lorenz_96_presets.dart';
import 'f0049_lorenz_96_variants.dart';
import 'f0049_lorenz_96_metadata.dart';

/// Lorenz-96 — Strange Attractors.
class F0049Lorenz96 extends AttractorModule {
  F0049Lorenz96()
      : super(
          id: 'f0049_lorenz_96',
          shader: 'shaders/f0049_lorenz_96_gpu.frag',
        );

  @override
  F0049Lorenz96Metadata get metadata => F0049Lorenz96Metadata.instance;

  @override
  List<F0049Lorenz96Preset> get presets => F0049Lorenz96Presets.all;

  @override
  List<F0049Lorenz96Variant> get variants => F0049Lorenz96Variants.all;

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
