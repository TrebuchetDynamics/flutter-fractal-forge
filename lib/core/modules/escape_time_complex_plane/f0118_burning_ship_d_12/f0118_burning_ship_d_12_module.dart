// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0118_burning_ship_d_12_presets.dart';
import 'f0118_burning_ship_d_12_variants.dart';
import 'f0118_burning_ship_d_12_metadata.dart';

/// Burning Ship d=12 — Escape-Time (Complex Plane).
class F0118BurningShipD12 extends EscapeTimeModule {
  F0118BurningShipD12()
      : super(
          id: 'f0118_burning_ship_d_12',
          shader: 'shaders/f0118_burning_ship_d_12_gpu.frag',
        );

  @override
  F0118BurningShipD12Metadata get metadata => F0118BurningShipD12Metadata.instance;

  @override
  List<F0118BurningShipD12Preset> get presets => F0118BurningShipD12Presets.all;

  @override
  List<F0118BurningShipD12Variant> get variants => F0118BurningShipD12Variants.all;

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
