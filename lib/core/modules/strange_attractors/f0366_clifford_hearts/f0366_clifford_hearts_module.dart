// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0366_clifford_hearts_presets.dart';
import 'f0366_clifford_hearts_variants.dart';
import 'f0366_clifford_hearts_metadata.dart';

/// Clifford Hearts — Strange Attractors.
class F0366CliffordHearts extends AttractorModule {
  F0366CliffordHearts()
      : super(
          id: 'f0366_clifford_hearts',
          shader: 'shaders/f0366_clifford_hearts_gpu.frag',
        );

  @override
  F0366CliffordHeartsMetadata get metadata => F0366CliffordHeartsMetadata.instance;

  @override
  List<F0366CliffordHeartsPreset> get presets => F0366CliffordHeartsPresets.all;

  @override
  List<F0366CliffordHeartsVariant> get variants => F0366CliffordHeartsVariants.all;

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
