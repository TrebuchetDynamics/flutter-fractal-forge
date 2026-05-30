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
  final autoDefaults = _autoDefaultsForModule(config.id);

  var effectiveIterations = config.defaultIterations;
  var effectiveCenterX = config.defaultCenterX;
  var effectiveCenterY = config.defaultCenterY;
  var effectiveZoom = config.defaultZoom;

  if (config.extraPresets.isNotEmpty) {
    // If the module has curated presets, use the first curated preset as
    // default framing/iterations so each fractal starts with a distinctive
    // initial state instead of generic (0,0,1,120).
    final curated = config.extraPresets.first;
    final it = curated.params['iterations'];
    if (it is num) {
      effectiveIterations = it.toDouble();
    }
    // Only use first preset's view if no explicit center/zoom was configured.
    final hasExplicitView = config.defaultCenterX != 0.0 ||
        config.defaultCenterY != 0.0 ||
        config.defaultZoom != 1.0;
    if (!hasExplicitView) {
      effectiveCenterX = curated.view.pan.x;
      effectiveCenterY = curated.view.pan.y;
      effectiveZoom = curated.view.zoom;
    }
  } else {
    // For modules that still use baseline constructor defaults, generate
    // deterministic per-module defaults from the module id.
    final usesBaseIterations = config.defaultIterations == 120;
    final usesBaseCenter =
        config.defaultCenterX == 0.0 && config.defaultCenterY == 0.0;
    final usesBaseZoom = config.defaultZoom == 1.0;

    if (usesBaseIterations) {
      effectiveIterations = autoDefaults.iterations;
    }
    if (usesBaseCenter) {
      effectiveCenterX = autoDefaults.centerX;
      effectiveCenterY = autoDefaults.centerY;
    }
    if (usesBaseZoom) {
      effectiveZoom = autoDefaults.zoom;
    }
  }

  effectiveIterations =
      effectiveIterations.clamp(20.0, config.maxIterations.toDouble());
  effectiveZoom = effectiveZoom.clamp(0.2, 32.0);

  final parameters = [
    CommonFractalParams.iterations(
      defaultValue: effectiveIterations,
      max: config.maxIterations,
    ),
    CommonFractalParams.bailout(defaultValue: config.defaultBailout),
    CommonFractalParams.colorScheme64(defaultValue: config.defaultColorScheme),
    ...config.extraParams,
  ];

  final defaultParams = <String, Object>{
    'iterations': effectiveIterations,
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
      pan: Vector2(effectiveCenterX, effectiveCenterY),
      zoom: effectiveZoom,
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
      shader.setFloat(6, _d(state.params, 'iterations', effectiveIterations));
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

class _AutoModuleDefaults {
  final double centerX;
  final double centerY;
  final double zoom;
  final double iterations;

  const _AutoModuleDefaults({
    required this.centerX,
    required this.centerY,
    required this.zoom,
    required this.iterations,
  });
}

_AutoModuleDefaults _autoDefaultsForModule(String moduleId) {
  final hash = _fnv1a32(moduleId);

  double unit(int shift) => ((hash >> shift) & 0xFF) / 255.0;

  // Keep defaults stable but non-generic per module:
  // - center around the classic Mandelbrot neighborhood
  // - moderate zoom that still shows structure
  // - varied iteration density for immediate detail diversity
  final centerX = -0.55 + (unit(0) - 0.5) * 0.5; // [-0.80, -0.30]
  final centerY = (unit(8) - 0.5) * 0.4; // [-0.20, 0.20]
  final zoom = 0.65 + unit(16) * 0.9; // [0.65, 1.55]
  final iterations = 110.0 + (hash % 131); // [110, 240]

  return _AutoModuleDefaults(
    centerX: centerX,
    centerY: centerY,
    zoom: zoom,
    iterations: iterations,
  );
}

int _fnv1a32(String text) {
  var hash = 0x811C9DC5;
  for (final codeUnit in text.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

double _d(Map<String, Object> p, String k, double f) {
  final v = p[k];
  if (v is int) return v.toDouble();
  if (v is double) return v;
  return f;
}
