// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0353_clifford_rose_presets.dart';
import 'f0353_clifford_rose_variants.dart';
import 'f0353_clifford_rose_metadata.dart';

/// Clifford Rose — Strange Attractors.
class F0353CliffordRose extends AttractorModule {
  F0353CliffordRose()
      : super(
          id: 'f0353_clifford_rose',
          shader: 'shaders/f0353_clifford_rose_gpu.frag',
        );

  @override
  F0353CliffordRoseMetadata get metadata => F0353CliffordRoseMetadata.instance;

  @override
  List<F0353CliffordRosePreset> get presets => F0353CliffordRosePresets.all;

  @override
  List<F0353CliffordRoseVariant> get variants => F0353CliffordRoseVariants.all;

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
