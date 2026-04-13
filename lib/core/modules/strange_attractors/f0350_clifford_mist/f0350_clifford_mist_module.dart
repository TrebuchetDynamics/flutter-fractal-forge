// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0350_clifford_mist_presets.dart';
import 'f0350_clifford_mist_variants.dart';
import 'f0350_clifford_mist_metadata.dart';

/// Clifford Mist — Strange Attractors.
class F0350CliffordMist extends AttractorModule {
  F0350CliffordMist()
      : super(
          id: 'f0350_clifford_mist',
          shader: 'shaders/f0350_clifford_mist_gpu.frag',
        );

  @override
  F0350CliffordMistMetadata get metadata => F0350CliffordMistMetadata.instance;

  @override
  List<F0350CliffordMistPreset> get presets => F0350CliffordMistPresets.all;

  @override
  List<F0350CliffordMistVariant> get variants => F0350CliffordMistVariants.all;

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
