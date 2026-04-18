// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1156_orbit_trap_cross_presets.dart';
import 'f1156_orbit_trap_cross_variants.dart';
import 'f1156_orbit_trap_cross_metadata.dart';

/// Orbit Trap Cross — Escape-Time (Complex Plane).
class F1156OrbitTrapCross extends EscapeTimeModule {
  F1156OrbitTrapCross()
      : super(
          id: 'f1156_orbit_trap_cross',
          shader: 'shaders/f1156_orbit_trap_cross_gpu.frag',
        );

  @override
  F1156OrbitTrapCrossMetadata get metadata => F1156OrbitTrapCrossMetadata.instance;

  @override
  List<F1156OrbitTrapCrossPreset> get presets => F1156OrbitTrapCrossPresets.all;

  @override
  List<F1156OrbitTrapCrossVariant> get variants => F1156OrbitTrapCrossVariants.all;

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
