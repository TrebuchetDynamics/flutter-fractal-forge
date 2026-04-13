// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0347_clifford_web_presets.dart';
import 'f0347_clifford_web_variants.dart';
import 'f0347_clifford_web_metadata.dart';

/// Clifford Web — Strange Attractors.
class F0347CliffordWeb extends AttractorModule {
  F0347CliffordWeb()
      : super(
          id: 'f0347_clifford_web',
          shader: 'shaders/f0347_clifford_web_gpu.frag',
        );

  @override
  F0347CliffordWebMetadata get metadata => F0347CliffordWebMetadata.instance;

  @override
  List<F0347CliffordWebPreset> get presets => F0347CliffordWebPresets.all;

  @override
  List<F0347CliffordWebVariant> get variants => F0347CliffordWebVariants.all;

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
