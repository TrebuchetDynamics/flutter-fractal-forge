// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0406_icon_vines_d6_presets.dart';
import 'f0406_icon_vines_d6_variants.dart';
import 'f0406_icon_vines_d6_metadata.dart';

/// Icon — Vines D6 — Strange Attractors.
class F0406IconVinesD6 extends AttractorModule {
  F0406IconVinesD6()
      : super(
          id: 'f0406_icon_vines_d6',
          shader: 'shaders/f0406_icon_vines_d6_gpu.frag',
        );

  @override
  F0406IconVinesD6Metadata get metadata => F0406IconVinesD6Metadata.instance;

  @override
  List<F0406IconVinesD6Preset> get presets => F0406IconVinesD6Presets.all;

  @override
  List<F0406IconVinesD6Variant> get variants => F0406IconVinesD6Variants.all;

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
