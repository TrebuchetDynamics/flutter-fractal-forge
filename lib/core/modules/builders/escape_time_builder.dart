import 'dart:ui' as ui;

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:flutter_fractals/core/services/rendering/palette_service.dart';
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
  final bool usesPaletteSampler;
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
    this.usesPaletteSampler = false,
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
  assert(
    config.extraParams.every((p) => p.defaultValue is num),
    'Escape-time extra parameters must have numeric defaults because they are written to float uniforms.',
  );

  final defaults = _resolveEscapeTimeDefaults(config);

  final parameters = [
    CommonFractalParams.iterations(
      defaultValue: defaults.iterations,
      max: config.maxIterations,
    ),
    CommonFractalParams.bailout(defaultValue: config.defaultBailout),
    CommonFractalParams.colorScheme64(defaultValue: config.defaultColorScheme),
    ...config.extraParams,
  ];

  final defaultParams = <String, Object>{
    'iterations': defaults.iterations,
    'bailout': config.defaultBailout,
    'colorScheme': config.defaultColorScheme,
  };
  for (final p in config.extraParams) {
    defaultParams[p.id] = p.defaultValue;
  }

  final defaultPreset = catalogPreset(
    id: '${config.id}-default',
    moduleId: config.id,
    name: 'Default',
    params: defaultParams,
    view: FractalViewState(
      pan: Vector2(defaults.centerX, defaults.centerY),
      zoom: defaults.zoom,
      rotation: Vector3.zero(),
    ),
  );

  return FractalModule(
    id: config.id,
    displayName: config.displayName ?? ((_) => config.name),
    dimension: FractalDimension.twoD,
    shaderAsset: config.shaderAsset,
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: buildBuiltInPresetList(
      moduleId: config.id,
      defaultPreset: defaultPreset,
      extraPresets: config.extraPresets,
    ),
    setUniforms: (shader, state, size, time) {
      shader.setFloat(EscapeTimeUniformSlots.time, time);
      shader.setFloat(EscapeTimeUniformSlots.resolutionX, size.width);
      shader.setFloat(EscapeTimeUniformSlots.resolutionY, size.height);
      shader.setFloat(EscapeTimeUniformSlots.centerX, state.view.pan.x);
      shader.setFloat(EscapeTimeUniformSlots.centerY, state.view.pan.y);
      shader.setFloat(EscapeTimeUniformSlots.zoom, state.view.zoom);
      shader.setFloat(EscapeTimeUniformSlots.iterations,
          readDouble(state.params, 'iterations', defaults.iterations));
      shader.setFloat(EscapeTimeUniformSlots.bailout,
          readDouble(state.params, 'bailout', config.defaultBailout));
      final colorScheme = readDouble(
        state.params,
        'colorScheme',
        config.defaultColorScheme.toDouble(),
      );
      shader.setFloat(EscapeTimeUniformSlots.colorScheme, colorScheme);
      shader.setFloat(EscapeTimeUniformSlots.transparentBackground,
          state.transparentBackground ? 1.0 : 0.0);
      if (config.usesPaletteSampler) {
        shader.setImageSampler(0, _paletteSamplerTexture(colorScheme.round()));
      }
      for (int i = 0; i < config.extraParams.length; i++) {
        final p = config.extraParams[i];
        shader.setFloat(EscapeTimeUniformSlots.extraStart + i,
            readDouble(state.params, p.id, (p.defaultValue as num).toDouble()));
      }
    },
  );
}

ui.Image? _fallbackPaletteSamplerTexture;

ui.Image _paletteSamplerTexture(int colorScheme) {
  try {
    final palette = PaletteService.instance.paletteAtIndex(colorScheme);
    return PaletteService.instance.paletteTexture(palette);
  } catch (_) {
    final cached = _fallbackPaletteSamplerTexture;
    if (cached != null) return cached;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 1, 1),
      ui.Paint()..color = const ui.Color(0xFF000000),
    );
    return _fallbackPaletteSamplerTexture =
        recorder.endRecording().toImageSync(1, 1);
  }
}

class _EscapeTimeDefaults {
  final double centerX;
  final double centerY;
  final double zoom;
  final double iterations;

  const _EscapeTimeDefaults({
    required this.centerX,
    required this.centerY,
    required this.zoom,
    required this.iterations,
  });
}

_EscapeTimeDefaults _resolveEscapeTimeDefaults(EscapeTimeConfig config) {
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
    final autoDefaults = _autoDefaultsForModule(config.id);
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

  return _EscapeTimeDefaults(
    centerX: effectiveCenterX,
    centerY: effectiveCenterY,
    zoom: effectiveZoom.clamp(0.2, 32.0),
    iterations:
        effectiveIterations.clamp(20.0, config.maxIterations.toDouble()),
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
