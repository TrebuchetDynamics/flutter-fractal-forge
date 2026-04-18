// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1177_orbit_trap_field_lines_presets.dart';
import 'f1177_orbit_trap_field_lines_variants.dart';
import 'f1177_orbit_trap_field_lines_metadata.dart';

/// Orbit Trap Field Lines — Escape-Time (Complex Plane).
class F1177OrbitTrapFieldLines extends EscapeTimeModule {
  F1177OrbitTrapFieldLines()
      : super(
          id: 'f1177_orbit_trap_field_lines',
          shader: 'shaders/f1177_orbit_trap_field_lines_gpu.frag',
        );

  @override
  F1177OrbitTrapFieldLinesMetadata get metadata => F1177OrbitTrapFieldLinesMetadata.instance;

  @override
  List<F1177OrbitTrapFieldLinesPreset> get presets => F1177OrbitTrapFieldLinesPresets.all;

  @override
  List<F1177OrbitTrapFieldLinesVariant> get variants => F1177OrbitTrapFieldLinesVariants.all;

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
