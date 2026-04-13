// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0081_hindmarsh_rose_presets.dart';
import 'f0081_hindmarsh_rose_variants.dart';
import 'f0081_hindmarsh_rose_metadata.dart';

/// Hindmarsh-Rose — Strange Attractors.
class F0081HindmarshRose extends AttractorModule {
  F0081HindmarshRose()
      : super(
          id: 'f0081_hindmarsh_rose',
          shader: 'shaders/f0081_hindmarsh_rose_gpu.frag',
        );

  @override
  F0081HindmarshRoseMetadata get metadata => F0081HindmarshRoseMetadata.instance;

  @override
  List<F0081HindmarshRosePreset> get presets => F0081HindmarshRosePresets.all;

  @override
  List<F0081HindmarshRoseVariant> get variants => F0081HindmarshRoseVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
