import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

typedef ModuleNameBuilder = String Function(AppLocalizations l10n);
typedef UniformSetter = void Function(
  FragmentShader shader,
  FractalRenderState state,
  Size size,
  double time,
);

enum FractalDimension { twoD, threeD }

@immutable
class FractalModule {
  final String id;
  final ModuleNameBuilder displayName;
  final FractalDimension dimension;
  final String shaderAsset;
  final List<FractalParameter> parameters;
  final FractalPreset defaultPreset;
  final List<FractalPreset> builtInPresets;
  final UniformSetter setUniforms;

  const FractalModule({
    required this.id,
    required this.displayName,
    required this.dimension,
    required this.shaderAsset,
    required this.parameters,
    required this.defaultPreset,
    required this.builtInPresets,
    required this.setUniforms,
  });
}

@immutable
class FractalRenderState {
  final Map<String, Object> params;
  final FractalViewState view;
  final bool transparentBackground;

  const FractalRenderState({
    required this.params,
    required this.view,
    required this.transparentBackground,
  });
}
