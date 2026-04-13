// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0403_icon_mayan_d8_presets.dart';
import 'f0403_icon_mayan_d8_variants.dart';
import 'f0403_icon_mayan_d8_metadata.dart';

/// Icon — Mayan D8 — Strange Attractors.
class F0403IconMayanD8 extends AttractorModule {
  F0403IconMayanD8()
      : super(
          id: 'f0403_icon_mayan_d8',
          shader: 'shaders/f0403_icon_mayan_d8_gpu.frag',
        );

  @override
  F0403IconMayanD8Metadata get metadata => F0403IconMayanD8Metadata.instance;

  @override
  List<F0403IconMayanD8Preset> get presets => F0403IconMayanD8Presets.all;

  @override
  List<F0403IconMayanD8Variant> get variants => F0403IconMayanD8Variants.all;

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
