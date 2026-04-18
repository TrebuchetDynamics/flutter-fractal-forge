// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1229_critical_orbit_map_presets.dart';
import 'f1229_critical_orbit_map_variants.dart';
import 'f1229_critical_orbit_map_metadata.dart';

/// Critical Orbit Map — Escape-Time (Complex Plane).
class F1229CriticalOrbitMap extends EscapeTimeModule {
  F1229CriticalOrbitMap()
      : super(
          id: 'f1229_critical_orbit_map',
          shader: 'shaders/f1229_critical_orbit_map_gpu.frag',
        );

  @override
  F1229CriticalOrbitMapMetadata get metadata => F1229CriticalOrbitMapMetadata.instance;

  @override
  List<F1229CriticalOrbitMapPreset> get presets => F1229CriticalOrbitMapPresets.all;

  @override
  List<F1229CriticalOrbitMapVariant> get variants => F1229CriticalOrbitMapVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 100.0;

  @override
  int get defaultIterations => 200;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
