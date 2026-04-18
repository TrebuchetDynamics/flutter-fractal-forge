// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1232_elliptic_function_julia_presets.dart';
import 'f1232_elliptic_function_julia_variants.dart';
import 'f1232_elliptic_function_julia_metadata.dart';

/// Elliptic Function Julia — Escape-Time (Complex Plane).
class F1232EllipticFunctionJulia extends EscapeTimeModule {
  F1232EllipticFunctionJulia()
      : super(
          id: 'f1232_elliptic_function_julia',
          shader: 'shaders/f1232_elliptic_function_julia_gpu.frag',
        );

  @override
  F1232EllipticFunctionJuliaMetadata get metadata => F1232EllipticFunctionJuliaMetadata.instance;

  @override
  List<F1232EllipticFunctionJuliaPreset> get presets => F1232EllipticFunctionJuliaPresets.all;

  @override
  List<F1232EllipticFunctionJuliaVariant> get variants => F1232EllipticFunctionJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 100.0;

  @override
  int get defaultIterations => 200;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
