// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0286_galaxy_spiral_ifs_presets.dart';
import 'f0286_galaxy_spiral_ifs_variants.dart';
import 'f0286_galaxy_spiral_ifs_metadata.dart';

/// Galaxy Spiral IFS — IFS & Geometric Construction.
class F0286GalaxySpiralIfs extends IFSModule {
  F0286GalaxySpiralIfs()
      : super(
          id: 'f0286_galaxy_spiral_ifs',
          shader: 'shaders/f0286_galaxy_spiral_ifs_gpu.frag',
        );

  @override
  F0286GalaxySpiralIfsMetadata get metadata => F0286GalaxySpiralIfsMetadata.instance;

  @override
  List<F0286GalaxySpiralIfsPreset> get presets => F0286GalaxySpiralIfsPresets.all;

  @override
  List<F0286GalaxySpiralIfsVariant> get variants => F0286GalaxySpiralIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
