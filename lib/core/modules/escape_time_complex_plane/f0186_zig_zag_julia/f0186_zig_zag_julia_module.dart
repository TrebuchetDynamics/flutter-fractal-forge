// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0186_zig_zag_julia_presets.dart';
import 'f0186_zig_zag_julia_variants.dart';
import 'f0186_zig_zag_julia_metadata.dart';

/// Zig-Zag Julia — Escape-Time (Complex Plane).
class F0186ZigZagJulia extends EscapeTimeModule {
  F0186ZigZagJulia()
      : super(
          id: 'f0186_zig_zag_julia',
          shader: 'shaders/f0186_zig_zag_julia_gpu.frag',
        );

  @override
  F0186ZigZagJuliaMetadata get metadata => F0186ZigZagJuliaMetadata.instance;

  @override
  List<F0186ZigZagJuliaPreset> get presets => F0186ZigZagJuliaPresets.all;

  @override
  List<F0186ZigZagJuliaVariant> get variants => F0186ZigZagJuliaVariants.all;

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
