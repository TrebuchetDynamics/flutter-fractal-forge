// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1172_orbit_trap_lemniscate_presets.dart';
import 'f1172_orbit_trap_lemniscate_variants.dart';
import 'f1172_orbit_trap_lemniscate_metadata.dart';

/// Orbit Trap Lemniscate — Escape-Time (Complex Plane).
class F1172OrbitTrapLemniscate extends EscapeTimeModule {
  F1172OrbitTrapLemniscate()
      : super(
          id: 'f1172_orbit_trap_lemniscate',
          shader:
              'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag',
        );

  @override
  F1172OrbitTrapLemniscateMetadata get metadata =>
      F1172OrbitTrapLemniscateMetadata.instance;

  @override
  List<F1172OrbitTrapLemniscatePreset> get presets =>
      F1172OrbitTrapLemniscatePresets.all;

  @override
  List<F1172OrbitTrapLemniscateVariant> get variants =>
      F1172OrbitTrapLemniscateVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.none;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
    p.setInt('trapMode', 17);
  }
}
