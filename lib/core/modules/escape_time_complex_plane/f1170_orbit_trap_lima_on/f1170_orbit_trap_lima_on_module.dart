// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1170_orbit_trap_lima_on_presets.dart';
import 'f1170_orbit_trap_lima_on_variants.dart';
import 'f1170_orbit_trap_lima_on_metadata.dart';

/// Orbit Trap Limaçon — Escape-Time (Complex Plane).
class F1170OrbitTrapLimaOn extends EscapeTimeModule {
  F1170OrbitTrapLimaOn()
      : super(
          id: 'f1170_orbit_trap_lima_on',
          shader: 'shaders/f1170_orbit_trap_lima_on_gpu.frag',
        );

  @override
  F1170OrbitTrapLimaOnMetadata get metadata => F1170OrbitTrapLimaOnMetadata.instance;

  @override
  List<F1170OrbitTrapLimaOnPreset> get presets => F1170OrbitTrapLimaOnPresets.all;

  @override
  List<F1170OrbitTrapLimaOnVariant> get variants => F1170OrbitTrapLimaOnVariants.all;

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
