// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0244_fractal_plant_canonical_presets.dart';
import 'f0244_fractal_plant_canonical_variants.dart';
import 'f0244_fractal_plant_canonical_metadata.dart';

/// Fractal Plant (Canonical) — L-Systems & Space-Filling.
class F0244FractalPlantCanonical extends LSystemModule {
  F0244FractalPlantCanonical()
      : super(
          id: 'f0244_fractal_plant_canonical',
          shader: 'shaders/f0244_fractal_plant_canonical_gpu.frag',
        );

  @override
  F0244FractalPlantCanonicalMetadata get metadata => F0244FractalPlantCanonicalMetadata.instance;

  @override
  List<F0244FractalPlantCanonicalPreset> get presets => F0244FractalPlantCanonicalPresets.all;

  @override
  List<F0244FractalPlantCanonicalVariant> get variants => F0244FractalPlantCanonicalVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
