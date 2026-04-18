// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1174_orbit_trap_hypocycloid_3_cusp_presets.dart';
import 'f1174_orbit_trap_hypocycloid_3_cusp_variants.dart';
import 'f1174_orbit_trap_hypocycloid_3_cusp_metadata.dart';

/// Orbit Trap Hypocycloid (3-cusp) — Escape-Time (Complex Plane).
class F1174OrbitTrapHypocycloid3Cusp extends EscapeTimeModule {
  F1174OrbitTrapHypocycloid3Cusp()
      : super(
          id: 'f1174_orbit_trap_hypocycloid_3_cusp',
          shader: 'shaders/f1174_orbit_trap_hypocycloid_3_cusp_gpu.frag',
        );

  @override
  F1174OrbitTrapHypocycloid3CuspMetadata get metadata => F1174OrbitTrapHypocycloid3CuspMetadata.instance;

  @override
  List<F1174OrbitTrapHypocycloid3CuspPreset> get presets => F1174OrbitTrapHypocycloid3CuspPresets.all;

  @override
  List<F1174OrbitTrapHypocycloid3CuspVariant> get variants => F1174OrbitTrapHypocycloid3CuspVariants.all;

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
