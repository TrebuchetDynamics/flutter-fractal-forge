// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0084_fitzhugh_nagumo_presets.dart';
import 'f0084_fitzhugh_nagumo_variants.dart';
import 'f0084_fitzhugh_nagumo_metadata.dart';

/// FitzHugh-Nagumo — Strange Attractors.
class F0084FitzhughNagumo extends AttractorModule {
  F0084FitzhughNagumo()
      : super(
          id: 'f0084_fitzhugh_nagumo',
          shader: 'shaders/f0084_fitzhugh_nagumo_gpu.frag',
        );

  @override
  F0084FitzhughNagumoMetadata get metadata => F0084FitzhughNagumoMetadata.instance;

  @override
  List<F0084FitzhughNagumoPreset> get presets => F0084FitzhughNagumoPresets.all;

  @override
  List<F0084FitzhughNagumoVariant> get variants => F0084FitzhughNagumoVariants.all;

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
