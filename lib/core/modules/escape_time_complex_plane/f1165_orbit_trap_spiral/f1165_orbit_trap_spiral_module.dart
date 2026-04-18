// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1165_orbit_trap_spiral_presets.dart';
import 'f1165_orbit_trap_spiral_variants.dart';
import 'f1165_orbit_trap_spiral_metadata.dart';

/// Orbit Trap Spiral — Escape-Time (Complex Plane).
class F1165OrbitTrapSpiral extends EscapeTimeModule {
  F1165OrbitTrapSpiral()
      : super(
          id: 'f1165_orbit_trap_spiral',
          shader: 'shaders/f1165_orbit_trap_spiral_gpu.frag',
        );

  @override
  F1165OrbitTrapSpiralMetadata get metadata => F1165OrbitTrapSpiralMetadata.instance;

  @override
  List<F1165OrbitTrapSpiralPreset> get presets => F1165OrbitTrapSpiralPresets.all;

  @override
  List<F1165OrbitTrapSpiralVariant> get variants => F1165OrbitTrapSpiralVariants.all;

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
