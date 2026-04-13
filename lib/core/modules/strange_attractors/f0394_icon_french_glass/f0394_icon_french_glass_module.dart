// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0394_icon_french_glass_presets.dart';
import 'f0394_icon_french_glass_variants.dart';
import 'f0394_icon_french_glass_metadata.dart';

/// Icon — French Glass — Strange Attractors.
class F0394IconFrenchGlass extends AttractorModule {
  F0394IconFrenchGlass()
      : super(
          id: 'f0394_icon_french_glass',
          shader: 'shaders/f0394_icon_french_glass_gpu.frag',
        );

  @override
  F0394IconFrenchGlassMetadata get metadata => F0394IconFrenchGlassMetadata.instance;

  @override
  List<F0394IconFrenchGlassPreset> get presets => F0394IconFrenchGlassPresets.all;

  @override
  List<F0394IconFrenchGlassVariant> get variants => F0394IconFrenchGlassVariants.all;

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
