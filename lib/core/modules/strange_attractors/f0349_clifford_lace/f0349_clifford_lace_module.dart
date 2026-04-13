// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0349_clifford_lace_presets.dart';
import 'f0349_clifford_lace_variants.dart';
import 'f0349_clifford_lace_metadata.dart';

/// Clifford Lace — Strange Attractors.
class F0349CliffordLace extends AttractorModule {
  F0349CliffordLace()
      : super(
          id: 'f0349_clifford_lace',
          shader: 'shaders/f0349_clifford_lace_gpu.frag',
        );

  @override
  F0349CliffordLaceMetadata get metadata => F0349CliffordLaceMetadata.instance;

  @override
  List<F0349CliffordLacePreset> get presets => F0349CliffordLacePresets.all;

  @override
  List<F0349CliffordLaceVariant> get variants => F0349CliffordLaceVariants.all;

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
