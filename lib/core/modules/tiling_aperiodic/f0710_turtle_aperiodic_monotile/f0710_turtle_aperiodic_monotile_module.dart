// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0710_turtle_aperiodic_monotile_presets.dart';
import 'f0710_turtle_aperiodic_monotile_variants.dart';
import 'f0710_turtle_aperiodic_monotile_metadata.dart';

/// Turtle Aperiodic Monotile — Tiling & Aperiodic.
class F0710TurtleAperiodicMonotile extends IFSModule {
  F0710TurtleAperiodicMonotile()
      : super(
          id: 'f0710_turtle_aperiodic_monotile',
          shader: 'shaders/f0710_turtle_aperiodic_monotile_gpu.frag',
        );

  @override
  F0710TurtleAperiodicMonotileMetadata get metadata => F0710TurtleAperiodicMonotileMetadata.instance;

  @override
  List<F0710TurtleAperiodicMonotilePreset> get presets => F0710TurtleAperiodicMonotilePresets.all;

  @override
  List<F0710TurtleAperiodicMonotileVariant> get variants => F0710TurtleAperiodicMonotileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
