// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0115_burning_ship_d_9_presets.dart';
import 'f0115_burning_ship_d_9_variants.dart';
import 'f0115_burning_ship_d_9_metadata.dart';

/// Burning Ship d=9 — Escape-Time (Complex Plane).
class F0115BurningShipD9 extends EscapeTimeModule {
  F0115BurningShipD9()
      : super(
          id: 'f0115_burning_ship_d_9',
          shader: 'shaders/f0115_burning_ship_d_9_gpu.frag',
        );

  @override
  F0115BurningShipD9Metadata get metadata => F0115BurningShipD9Metadata.instance;

  @override
  List<F0115BurningShipD9Preset> get presets => F0115BurningShipD9Presets.all;

  @override
  List<F0115BurningShipD9Variant> get variants => F0115BurningShipD9Variants.all;

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
