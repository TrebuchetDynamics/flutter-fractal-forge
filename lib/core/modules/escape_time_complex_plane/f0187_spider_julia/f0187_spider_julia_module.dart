// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0187_spider_julia_presets.dart';
import 'f0187_spider_julia_variants.dart';
import 'f0187_spider_julia_metadata.dart';

/// Spider Julia — Escape-Time (Complex Plane).
class F0187SpiderJulia extends EscapeTimeModule {
  F0187SpiderJulia()
      : super(
          id: 'f0187_spider_julia',
          shader: 'shaders/f0187_spider_julia_gpu.frag',
        );

  @override
  F0187SpiderJuliaMetadata get metadata => F0187SpiderJuliaMetadata.instance;

  @override
  List<F0187SpiderJuliaPreset> get presets => F0187SpiderJuliaPresets.all;

  @override
  List<F0187SpiderJuliaVariant> get variants => F0187SpiderJuliaVariants.all;

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
