// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0408_icon_mandala_d7_presets.dart';
import 'f0408_icon_mandala_d7_variants.dart';
import 'f0408_icon_mandala_d7_metadata.dart';

/// Icon — Mandala D7 — Strange Attractors.
class F0408IconMandalaD7 extends AttractorModule {
  F0408IconMandalaD7()
      : super(
          id: 'f0408_icon_mandala_d7',
          shader: 'shaders/f0408_icon_mandala_d7_gpu.frag',
        );

  @override
  F0408IconMandalaD7Metadata get metadata => F0408IconMandalaD7Metadata.instance;

  @override
  List<F0408IconMandalaD7Preset> get presets => F0408IconMandalaD7Presets.all;

  @override
  List<F0408IconMandalaD7Variant> get variants => F0408IconMandalaD7Variants.all;

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
