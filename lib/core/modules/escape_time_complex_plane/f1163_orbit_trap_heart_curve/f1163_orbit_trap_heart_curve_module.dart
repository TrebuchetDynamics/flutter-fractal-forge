// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1163_orbit_trap_heart_curve_presets.dart';
import 'f1163_orbit_trap_heart_curve_variants.dart';
import 'f1163_orbit_trap_heart_curve_metadata.dart';

/// Orbit Trap Heart Curve — Escape-Time (Complex Plane).
class F1163OrbitTrapHeartCurve extends EscapeTimeModule {
  F1163OrbitTrapHeartCurve()
      : super(
          id: 'f1163_orbit_trap_heart_curve',
          shader: 'shaders/f1163_orbit_trap_heart_curve_gpu.frag',
        );

  @override
  F1163OrbitTrapHeartCurveMetadata get metadata => F1163OrbitTrapHeartCurveMetadata.instance;

  @override
  List<F1163OrbitTrapHeartCurvePreset> get presets => F1163OrbitTrapHeartCurvePresets.all;

  @override
  List<F1163OrbitTrapHeartCurveVariant> get variants => F1163OrbitTrapHeartCurveVariants.all;

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
