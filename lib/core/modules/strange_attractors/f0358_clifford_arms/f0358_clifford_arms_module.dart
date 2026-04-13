// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0358_clifford_arms_presets.dart';
import 'f0358_clifford_arms_variants.dart';
import 'f0358_clifford_arms_metadata.dart';

/// Clifford Arms — Strange Attractors.
class F0358CliffordArms extends AttractorModule {
  F0358CliffordArms()
      : super(
          id: 'f0358_clifford_arms',
          shader: 'shaders/f0358_clifford_arms_gpu.frag',
        );

  @override
  F0358CliffordArmsMetadata get metadata => F0358CliffordArmsMetadata.instance;

  @override
  List<F0358CliffordArmsPreset> get presets => F0358CliffordArmsPresets.all;

  @override
  List<F0358CliffordArmsVariant> get variants => F0358CliffordArmsVariants.all;

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
