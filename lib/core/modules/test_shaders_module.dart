// Test modules for debugging GPU rendering on emulator (SwiftShader)
import 'dart:ui';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Test 1: Minimal shader - just outputs solid red, no uniforms
final FractalModule testMinimalModule = FractalModule(
  id: 'test_minimal',
  displayName: (AppLocalizations l10n) => 'Test: Minimal (Solid Red)',
  dimension: FractalDimension.twoD,
  shaderAsset: 'shaders/test_minimal.frag',
  parameters: const <FractalParameter>[],
  defaultPreset: const FractalPreset(
    id: 'test_minimal_default',
    name: 'Default',
    moduleId: 'test_minimal',
    params: {},
  ),
  builtInPresets: const [],
  setUniforms: (shader, state, size, time) {
    // No uniforms needed for minimal test
  },
);

/// Test 2: gl_FragCoord shader - uses standard GLSL gl_FragCoord
final FractalModule testGlFragCoordModule = FractalModule(
  id: 'test_gl_fragcoord',
  displayName: (AppLocalizations l10n) => 'Test: gl_FragCoord (UV Gradient)',
  dimension: FractalDimension.twoD,
  shaderAsset: 'shaders/test_gl_fragcoord.frag',
  parameters: const <FractalParameter>[],
  defaultPreset: const FractalPreset(
    id: 'test_gl_fragcoord_default',
    name: 'Default',
    moduleId: 'test_gl_fragcoord',
    params: {},
  ),
  builtInPresets: const [],
  setUniforms: (shader, state, size, time) {
    // Only set resolution uniform
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
  },
);

/// Test 3: FlutterFragCoord shader - uses Flutter's FlutterFragCoord() helper
final FractalModule testFlutterCoordModule = FractalModule(
  id: 'test_flutter_coord',
  displayName: (AppLocalizations l10n) => 'Test: FlutterFragCoord (UV Gradient)',
  dimension: FractalDimension.twoD,
  shaderAsset: 'shaders/test_flutter_coord.frag',
  parameters: const <FractalParameter>[],
  defaultPreset: const FractalPreset(
    id: 'test_flutter_coord_default',
    name: 'Default',
    moduleId: 'test_flutter_coord',
    params: {},
  ),
  builtInPresets: const [],
  setUniforms: (shader, state, size, time) {
    // Only set resolution uniform
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
  },
);
