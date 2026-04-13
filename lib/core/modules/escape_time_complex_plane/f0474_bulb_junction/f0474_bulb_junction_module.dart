// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0474_bulb_junction_presets.dart';
import 'f0474_bulb_junction_variants.dart';
import 'f0474_bulb_junction_metadata.dart';

/// Bulb Junction — Escape-Time (Complex Plane).
class F0474BulbJunction extends EscapeTimeModule {
  F0474BulbJunction()
      : super(
          id: 'f0474_bulb_junction',
          shader: 'shaders/f0474_bulb_junction_gpu.frag',
        );

  @override
  F0474BulbJunctionMetadata get metadata => F0474BulbJunctionMetadata.instance;

  @override
  List<F0474BulbJunctionPreset> get presets => F0474BulbJunctionPresets.all;

  @override
  List<F0474BulbJunctionVariant> get variants => F0474BulbJunctionVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 6000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
