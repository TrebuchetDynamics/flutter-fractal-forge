// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0407_icon_fern_d3_presets.dart';
import 'f0407_icon_fern_d3_variants.dart';
import 'f0407_icon_fern_d3_metadata.dart';

/// Icon — Fern D3 — Strange Attractors.
class F0407IconFernD3 extends AttractorModule {
  F0407IconFernD3()
      : super(
          id: 'f0407_icon_fern_d3',
          shader: 'shaders/f0407_icon_fern_d3_gpu.frag',
        );

  @override
  F0407IconFernD3Metadata get metadata => F0407IconFernD3Metadata.instance;

  @override
  List<F0407IconFernD3Preset> get presets => F0407IconFernD3Presets.all;

  @override
  List<F0407IconFernD3Variant> get variants => F0407IconFernD3Variants.all;

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
