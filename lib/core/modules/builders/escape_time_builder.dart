import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

/// Declarative config for a standard 2D escape-time fractal.
///
/// Adding a new escape-time fractal = one [EscapeTimeConfig] + one .frag shader.
/// No Dart module file needed.
class EscapeTimeConfig {
  final String id;
  final String name;
  final ModuleNameBuilder? displayName;
  final String shaderAsset;
  final double defaultIterations;
  final double defaultBailout;
  final int defaultColorScheme;
  final double defaultCenterX;
  final double defaultCenterY;
  final double defaultZoom;
  final int maxIterations;
  final String category;
  final List<FractalParameter> extraParams;
  final List<FractalPreset> extraPresets;

  const EscapeTimeConfig({
    required this.id,
    required this.name,
    required this.shaderAsset,
    this.displayName,
    this.defaultIterations = 120,
    this.defaultBailout = 4.0,
    this.defaultColorScheme = 0,
    this.defaultCenterX = 0.0,
    this.defaultCenterY = 0.0,
    this.defaultZoom = 1.0,
    // Most runtime_effect escape-time shaders compile with a static loop cap of 500.
    // Keep the UI/params cap aligned with shader reality to avoid misleading controls.
    this.maxIterations = 500,
    this.category = 'Escape-Time',
    this.extraParams = const [],
    this.extraPresets = const [],
  });
}

/// Builds a [FractalModule] from a declarative [EscapeTimeConfig].
///
/// All standard escape-time fractals share the same uniform layout:
///   float 0: uTime
///   float 1-2: uResolution (vec2)
///   float 3-4: uCenter (vec2)
///   float 5: uZoom
///   float 6: uIterations
///   float 7: uBailout
///   float 8: uColorScheme
///   float 9: uTransparentBg
///   float 10+: extra params (in order)
///
/// This eliminates per-fractal Dart boilerplate.
FractalModule buildEscapeTimeModule(EscapeTimeConfig config) {
  final parameters = [
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 20,
      max: config.maxIterations.toDouble(),
      step: 1,
      defaultValue: config.defaultIterations,
    ),
    FractalParameter(
      id: 'bailout',
      label: (l10n) => l10n.paramBailout,
      type: FractalParamType.float,
      min: 2.0,
      max: 8.0,
      step: 0.1,
      defaultValue: config.defaultBailout,
    ),
    CommonFractalParams.colorScheme64(defaultValue: config.defaultColorScheme),
    ...config.extraParams,
  ];

  final defaultParams = <String, Object>{
    'iterations': config.defaultIterations,
    'bailout': config.defaultBailout,
    'colorScheme': config.defaultColorScheme,
  };
  for (final p in config.extraParams) {
    defaultParams[p.id] = p.defaultValue;
  }

  final defaultPreset = FractalPreset(
    id: '${config.id}-default',
    moduleId: config.id,
    name: 'Default',
    params: defaultParams,
    view: FractalViewState(
      pan: Vector2(config.defaultCenterX, config.defaultCenterY),
      zoom: config.defaultZoom,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: config.id,
    displayName: config.displayName ?? ((_) => config.name),
    dimension: FractalDimension.twoD,
    shaderAsset: config.shaderAsset,
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: '${config.id}-classic', name: 'Classic'),
      ...config.extraPresets,
    ],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(
          6, _d(state.params, 'iterations', config.defaultIterations));
      shader.setFloat(7, _d(state.params, 'bailout', config.defaultBailout));
      shader.setFloat(
          8,
          _d(state.params, 'colorScheme',
              config.defaultColorScheme.toDouble()));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      // Extra params start at index 10
      for (int i = 0; i < config.extraParams.length; i++) {
        final p = config.extraParams[i];
        shader.setFloat(
            10 + i, _d(state.params, p.id, (p.defaultValue as num).toDouble()));
      }
    },
  );
}

double _d(Map<String, Object> p, String k, double f) {
  final v = p[k];
  if (v is int) return v.toDouble();
  if (v is double) return v;
  return f;
}
