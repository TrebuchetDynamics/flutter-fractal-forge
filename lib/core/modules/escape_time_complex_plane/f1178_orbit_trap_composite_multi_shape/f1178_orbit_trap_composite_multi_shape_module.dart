// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1178_orbit_trap_composite_multi_shape_presets.dart';
import 'f1178_orbit_trap_composite_multi_shape_variants.dart';
import 'f1178_orbit_trap_composite_multi_shape_metadata.dart';

/// Orbit Trap Composite Multi-Shape — Escape-Time (Complex Plane).
class F1178OrbitTrapCompositeMultiShape extends EscapeTimeModule {
  F1178OrbitTrapCompositeMultiShape()
      : super(
          id: 'f1178_orbit_trap_composite_multi_shape',
          shader: 'shaders/f1178_orbit_trap_composite_multi_shape_gpu.frag',
        );

  @override
  F1178OrbitTrapCompositeMultiShapeMetadata get metadata => F1178OrbitTrapCompositeMultiShapeMetadata.instance;

  @override
  List<F1178OrbitTrapCompositeMultiShapePreset> get presets => F1178OrbitTrapCompositeMultiShapePresets.all;

  @override
  List<F1178OrbitTrapCompositeMultiShapeVariant> get variants => F1178OrbitTrapCompositeMultiShapeVariants.all;

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
