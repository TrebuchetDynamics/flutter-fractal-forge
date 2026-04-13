// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0052_chua_s_circuit_double_scroll_presets.dart';
import 'f0052_chua_s_circuit_double_scroll_variants.dart';
import 'f0052_chua_s_circuit_double_scroll_metadata.dart';

/// Chua's Circuit (double scroll) — Strange Attractors.
class F0052ChuaSCircuitDoubleScroll extends AttractorModule {
  F0052ChuaSCircuitDoubleScroll()
      : super(
          id: 'f0052_chua_s_circuit_double_scroll',
          shader: 'shaders/f0052_chua_s_circuit_double_scroll_gpu.frag',
        );

  @override
  F0052ChuaSCircuitDoubleScrollMetadata get metadata => F0052ChuaSCircuitDoubleScrollMetadata.instance;

  @override
  List<F0052ChuaSCircuitDoubleScrollPreset> get presets => F0052ChuaSCircuitDoubleScrollPresets.all;

  @override
  List<F0052ChuaSCircuitDoubleScrollVariant> get variants => F0052ChuaSCircuitDoubleScrollVariants.all;

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
