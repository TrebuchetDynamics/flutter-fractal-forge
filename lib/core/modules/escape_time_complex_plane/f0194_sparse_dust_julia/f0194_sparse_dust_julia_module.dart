// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0194_sparse_dust_julia_presets.dart';
import 'f0194_sparse_dust_julia_variants.dart';
import 'f0194_sparse_dust_julia_metadata.dart';

/// Sparse Dust Julia — Escape-Time (Complex Plane).
class F0194SparseDustJulia extends EscapeTimeModule {
  F0194SparseDustJulia()
      : super(
          id: 'f0194_sparse_dust_julia',
          shader: 'shaders/f0194_sparse_dust_julia_gpu.frag',
        );

  @override
  F0194SparseDustJuliaMetadata get metadata => F0194SparseDustJuliaMetadata.instance;

  @override
  List<F0194SparseDustJuliaPreset> get presets => F0194SparseDustJuliaPresets.all;

  @override
  List<F0194SparseDustJuliaVariant> get variants => F0194SparseDustJuliaVariants.all;

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
