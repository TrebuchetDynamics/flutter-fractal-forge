// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1160_orbit_trap_line_real_axis_presets.dart';
import 'f1160_orbit_trap_line_real_axis_variants.dart';
import 'f1160_orbit_trap_line_real_axis_metadata.dart';

/// Orbit Trap Line (Real Axis) — Escape-Time (Complex Plane).
class F1160OrbitTrapLineRealAxis extends EscapeTimeModule {
  F1160OrbitTrapLineRealAxis()
      : super(
          id: 'f1160_orbit_trap_line_real_axis',
          shader: 'shaders/f1160_orbit_trap_line_real_axis_gpu.frag',
        );

  @override
  F1160OrbitTrapLineRealAxisMetadata get metadata => F1160OrbitTrapLineRealAxisMetadata.instance;

  @override
  List<F1160OrbitTrapLineRealAxisPreset> get presets => F1160OrbitTrapLineRealAxisPresets.all;

  @override
  List<F1160OrbitTrapLineRealAxisVariant> get variants => F1160OrbitTrapLineRealAxisVariants.all;

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
