// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0165_unit_circle_presets.dart';
import 'f0165_unit_circle_variants.dart';
import 'f0165_unit_circle_metadata.dart';

/// Unit Circle — Escape-Time (Complex Plane).
class F0165UnitCircle extends EscapeTimeModule {
  F0165UnitCircle()
      : super(
          id: 'f0165_unit_circle',
          shader: 'shaders/f0165_unit_circle_gpu.frag',
        );

  @override
  F0165UnitCircleMetadata get metadata => F0165UnitCircleMetadata.instance;

  @override
  List<F0165UnitCirclePreset> get presets => F0165UnitCirclePresets.all;

  @override
  List<F0165UnitCircleVariant> get variants => F0165UnitCircleVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
