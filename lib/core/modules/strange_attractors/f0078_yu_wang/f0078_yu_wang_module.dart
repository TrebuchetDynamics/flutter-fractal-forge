// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0078_yu_wang_presets.dart';
import 'f0078_yu_wang_variants.dart';
import 'f0078_yu_wang_metadata.dart';

/// Yu-Wang — Strange Attractors.
class F0078YuWang extends AttractorModule {
  F0078YuWang()
      : super(
          id: 'f0078_yu_wang',
          shader: 'shaders/f0078_yu_wang_gpu.frag',
        );

  @override
  F0078YuWangMetadata get metadata => F0078YuWangMetadata.instance;

  @override
  List<F0078YuWangPreset> get presets => F0078YuWangPresets.all;

  @override
  List<F0078YuWangVariant> get variants => F0078YuWangVariants.all;

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
