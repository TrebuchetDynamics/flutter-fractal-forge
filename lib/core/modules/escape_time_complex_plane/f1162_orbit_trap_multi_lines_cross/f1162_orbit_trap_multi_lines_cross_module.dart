// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1162_orbit_trap_multi_lines_cross_presets.dart';
import 'f1162_orbit_trap_multi_lines_cross_variants.dart';
import 'f1162_orbit_trap_multi_lines_cross_metadata.dart';

/// Orbit Trap Multi-Lines (Cross) — Escape-Time (Complex Plane).
class F1162OrbitTrapMultiLinesCross extends EscapeTimeModule {
  F1162OrbitTrapMultiLinesCross()
      : super(
          id: 'f1162_orbit_trap_multi_lines_cross',
          shader: 'shaders/f1162_orbit_trap_multi_lines_cross_gpu.frag',
        );

  @override
  F1162OrbitTrapMultiLinesCrossMetadata get metadata => F1162OrbitTrapMultiLinesCrossMetadata.instance;

  @override
  List<F1162OrbitTrapMultiLinesCrossPreset> get presets => F1162OrbitTrapMultiLinesCrossPresets.all;

  @override
  List<F1162OrbitTrapMultiLinesCrossVariant> get variants => F1162OrbitTrapMultiLinesCrossVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1024;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
