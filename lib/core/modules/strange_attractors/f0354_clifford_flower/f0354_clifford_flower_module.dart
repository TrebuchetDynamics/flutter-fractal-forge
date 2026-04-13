// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0354_clifford_flower_presets.dart';
import 'f0354_clifford_flower_variants.dart';
import 'f0354_clifford_flower_metadata.dart';

/// Clifford Flower — Strange Attractors.
class F0354CliffordFlower extends AttractorModule {
  F0354CliffordFlower()
      : super(
          id: 'f0354_clifford_flower',
          shader: 'shaders/f0354_clifford_flower_gpu.frag',
        );

  @override
  F0354CliffordFlowerMetadata get metadata => F0354CliffordFlowerMetadata.instance;

  @override
  List<F0354CliffordFlowerPreset> get presets => F0354CliffordFlowerPresets.all;

  @override
  List<F0354CliffordFlowerVariant> get variants => F0354CliffordFlowerVariants.all;

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
