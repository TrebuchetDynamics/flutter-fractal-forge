// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0365_clifford_fan_presets.dart';
import 'f0365_clifford_fan_variants.dart';
import 'f0365_clifford_fan_metadata.dart';

/// Clifford Fan — Strange Attractors.
class F0365CliffordFan extends AttractorModule {
  F0365CliffordFan()
      : super(
          id: 'f0365_clifford_fan',
          shader: 'shaders/f0365_clifford_fan_gpu.frag',
        );

  @override
  F0365CliffordFanMetadata get metadata => F0365CliffordFanMetadata.instance;

  @override
  List<F0365CliffordFanPreset> get presets => F0365CliffordFanPresets.all;

  @override
  List<F0365CliffordFanVariant> get variants => F0365CliffordFanVariants.all;

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
