// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1155_orbit_trap_circle_pickover_stalks_presets.dart';
import 'f1155_orbit_trap_circle_pickover_stalks_variants.dart';
import 'f1155_orbit_trap_circle_pickover_stalks_metadata.dart';

/// Orbit Trap Circle (Pickover Stalks) — Escape-Time (Complex Plane).
class F1155OrbitTrapCirclePickoverStalks extends EscapeTimeModule {
  F1155OrbitTrapCirclePickoverStalks()
      : super(
          id: 'f1155_orbit_trap_circle_pickover_stalks',
          shader: 'shaders/f1155_orbit_trap_circle_pickover_stalks_gpu.frag',
        );

  @override
  F1155OrbitTrapCirclePickoverStalksMetadata get metadata => F1155OrbitTrapCirclePickoverStalksMetadata.instance;

  @override
  List<F1155OrbitTrapCirclePickoverStalksPreset> get presets => F1155OrbitTrapCirclePickoverStalksPresets.all;

  @override
  List<F1155OrbitTrapCirclePickoverStalksVariant> get variants => F1155OrbitTrapCirclePickoverStalksVariants.all;

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
