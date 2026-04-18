// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1161_orbit_trap_line_imaginary_axis_presets.dart';
import 'f1161_orbit_trap_line_imaginary_axis_variants.dart';
import 'f1161_orbit_trap_line_imaginary_axis_metadata.dart';

/// Orbit Trap Line (Imaginary Axis) — Escape-Time (Complex Plane).
class F1161OrbitTrapLineImaginaryAxis extends EscapeTimeModule {
  F1161OrbitTrapLineImaginaryAxis()
      : super(
          id: 'f1161_orbit_trap_line_imaginary_axis',
          shader: 'shaders/f1161_orbit_trap_line_imaginary_axis_gpu.frag',
        );

  @override
  F1161OrbitTrapLineImaginaryAxisMetadata get metadata => F1161OrbitTrapLineImaginaryAxisMetadata.instance;

  @override
  List<F1161OrbitTrapLineImaginaryAxisPreset> get presets => F1161OrbitTrapLineImaginaryAxisPresets.all;

  @override
  List<F1161OrbitTrapLineImaginaryAxisVariant> get variants => F1161OrbitTrapLineImaginaryAxisVariants.all;

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
