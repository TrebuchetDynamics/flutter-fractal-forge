// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0363_clifford_moth_presets.dart';
import 'f0363_clifford_moth_variants.dart';
import 'f0363_clifford_moth_metadata.dart';

/// Clifford Moth — Strange Attractors.
class F0363CliffordMoth extends AttractorModule {
  F0363CliffordMoth()
      : super(
          id: 'f0363_clifford_moth',
          shader: 'shaders/f0363_clifford_moth_gpu.frag',
        );

  @override
  F0363CliffordMothMetadata get metadata => F0363CliffordMothMetadata.instance;

  @override
  List<F0363CliffordMothPreset> get presets => F0363CliffordMothPresets.all;

  @override
  List<F0363CliffordMothVariant> get variants => F0363CliffordMothVariants.all;

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
