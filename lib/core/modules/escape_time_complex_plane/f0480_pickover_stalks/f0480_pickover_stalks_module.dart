// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0480_pickover_stalks_presets.dart';
import 'f0480_pickover_stalks_variants.dart';
import 'f0480_pickover_stalks_metadata.dart';

/// Pickover Stalks — Escape-Time (Complex Plane).
class F0480PickoverStalks extends EscapeTimeModule {
  F0480PickoverStalks()
      : super(
          id: 'f0480_pickover_stalks',
          shader: 'shaders/f0480_pickover_stalks_gpu.frag',
        );

  @override
  F0480PickoverStalksMetadata get metadata => F0480PickoverStalksMetadata.instance;

  @override
  List<F0480PickoverStalksPreset> get presets => F0480PickoverStalksPresets.all;

  @override
  List<F0480PickoverStalksVariant> get variants => F0480PickoverStalksVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
