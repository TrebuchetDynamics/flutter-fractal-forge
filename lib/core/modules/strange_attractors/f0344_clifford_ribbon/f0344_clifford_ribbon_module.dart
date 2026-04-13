// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0344_clifford_ribbon_presets.dart';
import 'f0344_clifford_ribbon_variants.dart';
import 'f0344_clifford_ribbon_metadata.dart';

/// Clifford Ribbon — Strange Attractors.
class F0344CliffordRibbon extends AttractorModule {
  F0344CliffordRibbon()
      : super(
          id: 'f0344_clifford_ribbon',
          shader: 'shaders/f0344_clifford_ribbon_gpu.frag',
        );

  @override
  F0344CliffordRibbonMetadata get metadata => F0344CliffordRibbonMetadata.instance;

  @override
  List<F0344CliffordRibbonPreset> get presets => F0344CliffordRibbonPresets.all;

  @override
  List<F0344CliffordRibbonVariant> get variants => F0344CliffordRibbonVariants.all;

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
