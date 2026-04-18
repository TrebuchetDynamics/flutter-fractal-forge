// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1169_orbit_trap_rose_curve_presets.dart';
import 'f1169_orbit_trap_rose_curve_variants.dart';
import 'f1169_orbit_trap_rose_curve_metadata.dart';

/// Orbit Trap Rose Curve — Escape-Time (Complex Plane).
class F1169OrbitTrapRoseCurve extends EscapeTimeModule {
  F1169OrbitTrapRoseCurve()
      : super(
          id: 'f1169_orbit_trap_rose_curve',
          shader: 'shaders/f1169_orbit_trap_rose_curve_gpu.frag',
        );

  @override
  F1169OrbitTrapRoseCurveMetadata get metadata => F1169OrbitTrapRoseCurveMetadata.instance;

  @override
  List<F1169OrbitTrapRoseCurvePreset> get presets => F1169OrbitTrapRoseCurvePresets.all;

  @override
  List<F1169OrbitTrapRoseCurveVariant> get variants => F1169OrbitTrapRoseCurveVariants.all;

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
