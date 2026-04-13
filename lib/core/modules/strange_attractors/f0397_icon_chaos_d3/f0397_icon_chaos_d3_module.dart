// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0397_icon_chaos_d3_presets.dart';
import 'f0397_icon_chaos_d3_variants.dart';
import 'f0397_icon_chaos_d3_metadata.dart';

/// Icon — Chaos D3 — Strange Attractors.
class F0397IconChaosD3 extends AttractorModule {
  F0397IconChaosD3()
      : super(
          id: 'f0397_icon_chaos_d3',
          shader: 'shaders/f0397_icon_chaos_d3_gpu.frag',
        );

  @override
  F0397IconChaosD3Metadata get metadata => F0397IconChaosD3Metadata.instance;

  @override
  List<F0397IconChaosD3Preset> get presets => F0397IconChaosD3Presets.all;

  @override
  List<F0397IconChaosD3Variant> get variants => F0397IconChaosD3Variants.all;

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
