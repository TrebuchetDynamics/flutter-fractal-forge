// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0288_heighway_dragon_boundary_presets.dart';
import 'f0288_heighway_dragon_boundary_variants.dart';
import 'f0288_heighway_dragon_boundary_metadata.dart';

/// Heighway Dragon Boundary — IFS & Geometric Construction.
class F0288HeighwayDragonBoundary extends IFSModule {
  F0288HeighwayDragonBoundary()
      : super(
          id: 'f0288_heighway_dragon_boundary',
          shader: 'shaders/f0288_heighway_dragon_boundary_gpu.frag',
        );

  @override
  F0288HeighwayDragonBoundaryMetadata get metadata => F0288HeighwayDragonBoundaryMetadata.instance;

  @override
  List<F0288HeighwayDragonBoundaryPreset> get presets => F0288HeighwayDragonBoundaryPresets.all;

  @override
  List<F0288HeighwayDragonBoundaryVariant> get variants => F0288HeighwayDragonBoundaryVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
